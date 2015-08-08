# ip_overlap_pg
PostgreSQL-based IP overlap

# Usage

Clone this repository:

```bash
$ git clone https://github.com/pshevtsov/ip_overlap_pg.git
$ cd ip_overlap_pg
```

After that you need to download [net_combined.csv](https://s3.amazonaws.com/idb.io/net_combined.csv) into the current directory:

```bash
$ wget https://s3.amazonaws.com/idb.io/net_combined.csv
```

Then use one of the following ways:

1. Docker containers
2. Local environment

## Docker containers

### Requirements

1. [Docker](https://docs.docker.com/docker/installation/)
2. [Docker Compose](https://docs.docker.com/compose/install/)
3. [pgloader](http://pgloader.io/download.html)

### Usage

First of all you need to buid the necessary containers:

```bash
$ docker-compose build
```

After that you need to start the database container instance:

```bash
$ docker-compose up -d db
```

Then you need to run CSV processing application:

```bash
$ docker-compose run app
```

After the processing finishes you can get the final CSV output:

```bash
$ docker run -it --link $(docker-compose ps -q db):postgres --rm postgres sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres -d postgres -c "COPY ( SELECT * FROM net_flat ORDER BY s ) TO STDOUT WITH CSV"' > output.csv
```

The file `output.csv` will contain the processed data.

## Local environment

### Requirements

1. [pgloader](http://pgloader.io/download.html)
2. [PostgreSQL](http://www.postgresql.org/)

### Usage

First of all you need to load CSV data into PostgreSQL database table:

```bash
$ POSTGRES_URL=postgresql://postgres@localhost:5432/postgres?net_combined pgloader command.load
```
Set `POSTGRES_URL` to the [correct connection string](http://pgloader.io/howto/pgloader.1.html). Note: the table name must be `net_combined`.

After that you can get the processed output:

```bash
$ psql -h localhost -p 5432 -U postgres -d postgres -c "COPY ( SELECT * FROM net_flat ORDER BY s ) TO STDOUT WITH CSV"' > output.csv
```

Set the correct parameters for `psql` command. The file `output.csv` will contain the processed data.
