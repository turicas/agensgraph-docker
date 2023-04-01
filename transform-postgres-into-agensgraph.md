# Transforming postgres into agensgraph

Update repository and create a new branch off of lastest `master`:

```shell
git clone https://github.com/docker-library/postgres agensgraph-docker
cd agensgraph-docker
git checkout -b feature/agensgraph-vXXX origin/master
```

Remove unused postgres versions and alpine:

```shell
git rm -rf 11 12 14 15 Dockerfile-alpine.template 13/alpine
git commit -m "Remove unused postgres versions"
```

Change Dockerfile-debian template:

```shell
# TODO: manually edit Dockerfile-debian.template apply-templates.sh versions.json
git add Dockerfile-debian.template apply-templates.sh versions.json
git commit -m "Change Dockerfile Debian template"
```

Apply the template and add build script:

```shell
./apply-templates.sh
cp build-agensgraph.sh 13/bullseye/
git add 13/bullseye
git commit -m "Add Agensgraph build script"
```

Update documentation:

```shell
echo -e "Docker Agensgraph Authors\n\nÁlvaro Justen <alvarojusten@gmail.com>\n\n" > AUTHORS.tmp
cat AUTHORS >> AUTHORS.tmp
mv AUTHORS.tmp AUTHORS
git add AUTHORS
# TODO: manually update README.md
git commit -m "Update documentation"
```
