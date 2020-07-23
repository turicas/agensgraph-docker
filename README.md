# Agensgraph Docker

This is a [Agensgraph](https://bitnine.net/agensgraph/) Docker image based on
the [official PostgreSQL Docker image](https://hub.docker.com/_/postgres) (not
on [Agensgraph's image](https://hub.docker.com/r/bitnine/agensgraph), which has
some issues). The current Agensgraph source is based on PostgreSQL 10.3.

## Building

```shell
git clone https://github.com/turicas/agensgraph-docker.git
docker build -t turicas/agensgraph:2.1.3 agensgraph-docker/10
```

## Running

To have a better experience, you may want to have a specific password, a
separate volume for data, change the shared memory size and publish the server
port into the host machine:

```shell
docker run \
	--name=myagens \
	--env POSTGRES_PASSWORD=myprecious \
	--env PGDATA=/var/lib/postgresql/data/pgdata \
	--volume $(pwd)/agens-data:/var/lib/postgresql/data \
	--shm-size=256MB \
	--publish 15432:5432 \
	--detach \
	turicas/agensgraph:2.1.3
```

You can then connect to the server from the host machine:

```shell
psql postgres://postgres:myprecious@localhost:15432/postgres
```

Check also the [official PostgreSQL Docker
image](https://hub.docker.com/_/postgres) documentation.
