# Running Postgres and pgAdmin with Docker Compose

## Motivation

In previous videos, we learnt how to run three containers:

1. [Ingesting NY Taxi Data to Postgres](Ingesting%20NY%20Taxi%20Data%20to%20Postgres%203ceb9b73e2fd40e3b787538f8827d894.md) 
2. [pgAdmin and Postgres](pgAdmin%20and%20Postgres%205054964b64a3409797582d00e6568509.md) 
3. [Dockerising Ingestion of NY Taxi Data to Postgres](Dockerising%20Ingestion%20of%20NY%20Taxi%20Data%20to%20Postgres%20230fd6611ee3495e9b601ed4956f4914.md) 

It can be cumbersome and error-prone to execute and kill multiple Docker containers manually. *Docker Compose* is a “tool for defining and running multi-container Docker applications”. With this tool, we only need to create a configuration of our application’s services using YAML. Docker Compose then takes care of launching and running the services with specified configuration with a single command.

## Create a Docker Compose YAML

Here is the Docker Compose YAML to run the Postgres database and pgAdmin containers with a single command:

```yaml
services:
  pg-database:
    image: postgres:13
    environment:
      - POSTGRES_USER=root
      - POSTGRES_PASSWORD=root
      - POSTGRES_DB=ny_taxi
    volumes:
      - "./ny_taxi_postgres_data:/var/lib/postgresql/data"
    ports:
      - "5432:5432"
  pg-admin:
    image: dpage/pgadmin4
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    ports:
      - "8080:80"

```

In the YAML file, the `services` key lists all the services we need to run our application. The key of each service is also the container’s name i.e. its host name. In this example, the Postgres database has the name `pg-database` and pgAdmin has the name `pg-admin`.

When we run services with Docker Compose, they all share the same network. Hence, we do not need to manually specify any network configuration.

For every service, we specify the image to use for spinning up a container. The environment variables like username, password, etc. are specified as list items inside the `environment` key.

Port mappings are also specified as list items within the `ports` key in `<host port>:<container port>` format. The port specification needs to be a string.

The same rules apply for volume mapping in the `volumes` key. The syntax is `<host_path>:<container_path>` and this mapping should also be specified as a string.

We can then run the two containers using Docker Compose and this configuration file as follows:

```bash
# Assumes that you are in the same directory as the YAML file.
docker-compose up

```

We can then access the pgAdmin UI by noting down the IP of our machine (`localhost` if running on our laptop) and accessing the UI using a web browser. Once we connect to the Postgres database container by putting in the right name (`pg-database` in this example) and credentials, we can run the following query to check if the data is accessible:

```sql
select count(1) from yellow_taxi_data;

```

If we wish to run the containers in the background, we need to add the `-d` flag.

```bash
docker-compose up -d

```

In this case, we can stop the containers using the `down` command.

```bash
docker-compose down

```

## References

- [DE Zoomcamp 1.2.5 - Running Postgres and pgAdmin with Docker-Compose](https://www.youtube.com/watch?v=hKI6PkPhpa0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=9)