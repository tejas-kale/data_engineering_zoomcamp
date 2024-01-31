# Dockerising Ingestion of NY Taxi Data to Postgres

## About

In [Ingesting NY Taxi Data to Postgres](Ingesting%20NY%20Taxi%20Data%20to%20Postgres%203ceb9b73e2fd40e3b787538f8827d894.md) , we through the steps to ingest data from a CSV file into a Postgres database running in a Docker container. A bottleneck in that approach is that we need to perform all the steps (data download, creating a Postgres table, etc.) manually. A more efficient approach is to convert the note (which is a Jupyter notebook) into a script and then execute the script inside a Docker container.

## Script

The first step to dockerising ingestion of NY taxi data is to convert the Jupyter notebook into a script (`ingest_data.py`). When doing so, the following information is accepted as script arguments:

- Username of the Postgres container
- Password of the Postgres container
- Hostname of the Postgres container
- Port of the Postgres container
- Name of the Postgres database
- Name of the table to add data to
- URL of the CSV file

```python
"""
Ingest data from a CSV file into a Postgres database running in a Docker container.
"""

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from time import time

import argparse
import pandas as pd

def ingest_data(username: str, password: str, hostname: str, port: int, db: str, table: str, url: str):
    dt_cols: list = ['tpep_pickup_datetime', 'tpep_dropoff_datetime']

    engine: Engine = create_engine(f'postgresql://{username}:{password}@{hostname}:{port}/{db}')

    yellow_taxi_iter = pd.read_csv(url, iterator=True, chunksize=100000, verbose=True)
    yellow_taxi_first_chunk: pd.DataFrame = next(yellow_taxi_iter)
    yellow_taxi_first_chunk.head(n=0).to_sql(name=table, con=engine, if_exists='replace')
    yellow_taxi_first_chunk.to_sql(name=table, con=engine, if_exists='append')

    while True:
        try:
            iter_start: float = time()
            df: pd.DataFrame = next(yellow_taxi_iter)
            df.loc[:, dt_cols] = df[dt_cols].apply(pd.to_datetime)
            df.to_sql(name=table, con=engine, if_exists='append')
            iter_end: float = time()
            print(f'Added another chunk in {iter_end - iter_start} seconds.')
        except StopIteration:
            exit(0)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')
    parser.add_argument('--username', help='Username for Postgres container')
    parser.add_argument('--password', help='Password for Postgres container')
    parser.add_argument('--hostname', help='Name of the Postgres container')
    parser.add_argument('--port', type=int, help='Port of the Postgres container')
    parser.add_argument('--db', help='Name of the Postgres database')
    parser.add_argument('--table', help='Name of the table to add data to')
    parser.add_argument('--url', help='URL of the CSV file')

    args: argparse.Namespace = parser.parse_args()
    ingest_data(**args.__dict__)

```

## Dockerfile

The next step is to create a Dockerfile that install the required packages and then executes this script.

```
FROM python:3.8

RUN pip install numpy pandas sqlalchemy psycopg2

WORKDIR /app
COPY ingest_data.py ingest_data.py

ENTRYPOINT ["python", "ingest_data.py"]

```

## Build an image

Next, let us build a Docker image with the command:

```bash
docker build -t taxi_ingest:v001 .

```

## Run container

Finally, let us run the container to execute our Python script. A point to keep in mind is that we need to use the same Docker network while running this container as our Postgres container otherwise the container will not be able to find the database with host name as `pg-db` which is the name we gave to the Postgres container..

```bash
docker run -it \\
  --network=pg-network \\
  dataengineeringzoomcamp:latest \\
  --username=root \\
  --password=root \\
  --hostname=pg-db \\
  --port=5432 \\
  --db=ny_taxi \\
  --table=yellow_taxi_data \\
  --url=https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-06.parquet

```

```bash
docker run -it \\
  --env POSTGRES_USER="root" \\
  --env POSTGRES_PASSWORD="root" \\
  --env POSTGRES_DB="ny_taxi" \\
  --volume $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \\
  --network=pg-network \\
  --port 5432:5432 \\
  postgres:13

```

### `http.server`

In case our internet connection is slow and we want to use a local file to test this container, we can start a simple HTTP server with Python in the directory that contains the data file.

```bash
python -m http.server

```

We can get the IP address of our machine using the `ifconfig` command. Then, we can navigate to the HTTP server in our browser using our machine’s IP, copy the URL to the file, and then use it while running the container.

## References

- [DE Zoomcamp 1.2.4 - Dockerizing the Ingestion Script](https://www.youtube.com/watch?v=B1WwATwf-vY&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=7)