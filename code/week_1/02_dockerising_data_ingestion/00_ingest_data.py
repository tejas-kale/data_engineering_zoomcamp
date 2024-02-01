"""
Ingest data from a CSV file into a Postgres database running in a Docker container.
"""

import argparse

import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


def ingest_data(
    username: str,
    password: str,
    hostname: str,
    port: int,
    db_name: str,
    table: str,
    url: str,
):
    """Ingest NY Taxi ride data in a Postgres table.

    :param username: Username of the Postgres server.
    :param password: Password of the Postgres server.
    :param hostname: Host address of the Postgres server.
    :param port:     Port of the Postgres server.
    :param db_name:  Name of the Postgres database to save data to.
    :param table:    Name of the table to save data to.
    :param url:      URL of the Parquet file to fetch data from.
    """
    dt_cols: list = ["tpep_pickup_datetime", "tpep_dropoff_datetime"]

    engine: Engine = create_engine(
        f"postgresql://{username}:{password}@{hostname}:{port}/{db_name}"
    )

    yellow_taxi_data: pd.DataFrame = pd.read_parquet(url)
    yellow_taxi_data.loc[:, dt_cols] = yellow_taxi_data[dt_cols].apply(pd.to_datetime)
    yellow_taxi_data.to_sql(name=table, con=engine, if_exists="append")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ingest CSV data to Postgres")
    parser.add_argument("--username", help="Username for Postgres container")
    parser.add_argument("--password", help="Password for Postgres container")
    parser.add_argument("--hostname", help="Name of the Postgres container")
    parser.add_argument("--port", type=int, help="Port of the Postgres container")
    parser.add_argument("--db_name", help="Name of the Postgres database")
    parser.add_argument("--table", help="Name of the table to add data to")
    parser.add_argument("--url", help="URL of the Parquet file")

    args: argparse.Namespace = parser.parse_args()
    ingest_data(**args.__dict__)
