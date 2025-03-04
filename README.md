# Agensgraph Docker

This is a [Agensgraph](https://bitnine.net/agensgraph/) Docker image based on the [official PostgreSQL Docker
image](https://hub.docker.com/_/postgres) (not on [Agensgraph's image](https://hub.docker.com/r/bitnine/agensgraph),
which has some issues). The current Agensgraph source is based on PostgreSQL 14.

## Building

```shell
git clone https://github.com/turicas/agensgraph-docker.git
cd agensgraph-docker
# Replace 'VERSION' with the latest one and 'PG_VERSION' with postgres target version
git checkout -b feature/agensgraph-VERSION origin/feature/agensgraph-VERSION
docker build -t turicas/agensgraph:VERSION PG_VERSION/bookworm
```

## Running

To have a better experience, you may want to have a specific password, a separate volume for data, change the shared
memory size and publish the server port into the host machine:

```shell
docker run \
	--name=myagens \
	--env POSTGRES_PASSWORD=myprecious \
	--env PGDATA=/var/lib/postgresql/data/pgdata \
	--env GRAPH_DB=agens \
	--volume $(pwd)/agens-data:/var/lib/postgresql/data \
	--shm-size=256MB \
	--publish 15432:5432 \
	--detach \
	turicas/agensgraph:VERSION
```

> Note: `agens` is the default graph name and you don't need to pass `GRAPH_DB` if you don't want to change it.

You can then connect to the server from the host machine:

```shell
psql postgres://postgres:myprecious@localhost:15432/postgres
# then: SET graph_path = agens; ...
```

Check also the [official PostgreSQL Docker image](https://hub.docker.com/_/postgres) documentation.


## Transforming postgres into agensgraph

This is the step by step guide followed by me to transform the original postgres Docker repository into this:

1. Clone the original repository and create a new branch off of lastest `master`:

```shell
git clone https://github.com/docker-library/postgres agensgraph-docker
cd agensgraph-docker
git checkout -b feature/agensgraph-XXX origin/master  # Replace XXX with the version
```

2. Add `build-agensgraph.sh` script and change `apply-templates.sh`:

```shell
cat > build-agensgraph.sh <<'EOF'
#!/bin/bash

set -e

AGENS_VERSION="2.14.1" # CHANGE HERE!
PG_MAJOR="14" # CHANGE HERE!
source_path="/usr/src/agensgraph"
APT_PACKAGES="
  bison
  build-essential
  ca-certificates
  flex
  libreadline-dev
  libssl-dev
  libxml2-dev
  libxml2-utils
  libxslt1-dev
  wget
  xsltproc
  zlib1g-dev
"
# libssl is required by postgres to run
APT_REMOVE_PACKAGES=$(echo "$APT_PACKAGES" | grep -v 'libssl-dev')

# Install system packages
apt update
apt upgrade -y
apt install -y --no-install-recommends $APT_PACKAGES

# Download source
mkdir -p "$source_path"
cd $source_path
url="https://github.com/bitnine-oss/agensgraph/archive/refs/tags/v${AGENS_VERSION}.tar.gz"
wget "$url"
tar xfz $(basename "$url")
rm $(basename "$url")

# Compile, install and remove source
cd "agensgraph-${AGENS_VERSION}"
./configure --with-openssl --prefix=/usr/lib/postgresql/${PG_MAJOR} --datarootdir=/usr/share/postgresql/${PG_MAJOR}
make
make install
sed -i "s/^#listen_addresses =.*/listen_addresses = '*'/" /usr/share/postgresql/${PG_MAJOR}/postgresql.conf.sample
cd /
rm -rf /usr/src/agensgraph

# Cleanup apt packages
apt remove -y $APT_REMOVE_PACKAGES
apt autoremove -y
apt clean
rm -rf /var/lib/apt/lists/*
EOF
chmod +x build-agensgraph.sh
sed 's/cp -a /cp -a build-agensgraph.sh /' -i apply-templates.sh
```

Edit `build-agensgraph.sh` and change agensgraph and postgres target versions.

Then, commit:

```shell
git add build-agensgraph.sh apply-templates.sh
git commit -m "Add agensgraph build script"
```

3. Manually edit `Dockerfile-debian.template` and `docker-entrypoint.sh`:

Editing `Dockerfile-debian.template`:

- Remove `RUN` which setups keys (`key=...`, `gpg --batch ..`)
- Replace `RUN` responsible for building with code below (it's the one which has `apt-get source ...`)

```dockerfile
# [START] Custom Agensgraph installation
ADD build-agensgraph.sh /opt/
RUN /opt/build-agensgraph.sh
# [END] Custom Agensgraph installation
```

- Remove `RUN` commented as "make the sample config easier to munge"

Editing `docker-entrypoint.sh`:

Add this function just after `docker_setup_db` definition:

```bash
# create initial graph inside default database
# uses environment variables for input: GRAPH_DB
docker_setup_graph() {
	export GRAPH_DB=${GRAPH_DB:-agens}
	echo "CREATE GRAPH ${GRAPH_DB};" | docker_process_sql --dbname "$POSTGRES_DB"
}
```

Add `docker_setup_graph` in the line just after `docker_setup_db` call (not the definition).

Then, commit:

```shell
git add Dockerfile-debian.template docker-entrypoint.sh
git commit -m "Add new Dockerfile template"
```

4. Create Dockerfile for target version

Manually edit `versions.json` and remove everything that is not the latest Debian and the agensgraph postgres version.

```shell
vim versions.json
git add versions.json
git commit -m "Clean up versions file"
```

Remove all built Dockerfiles and build just the one we need:

```shell
git rm -rf --ignore-unmatch 11 12 13 14 15 16 17
./apply-templates.sh
git add VERSION  # Replace 'VERSION' with the postgres target version
git commit -m "Apply template to agensgraph/postgres target version"
```

Update documentation:

```shell
echo -e "Docker Agensgraph Authors\n\nÁlvaro Justen <alvarojusten@gmail.com>\n\n" > AUTHORS.tmp
cat AUTHORS >> AUTHORS.tmp
mv AUTHORS.tmp AUTHORS
rm README.md
wget -O "README.md" "https://gist.githubusercontent.com/turicas/273f220cac91242956f39df7c36ec8c5/raw/README.md"
git add AUTHORS README.md
git commit -m "Update documentation"
```
