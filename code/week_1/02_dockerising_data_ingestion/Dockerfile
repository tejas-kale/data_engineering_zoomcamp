FROM python:3.10

RUN pip install numpy pandas sqlalchemy psycopg2 pyarrow

WORKDIR /app
COPY 00_ingest_data.py 00_ingest_data.py

ENTRYPOINT ["python", "00_ingest_data.py", "--username", "root", "--password", "root", "--hostname", "localhost", "--port", "5432", "--db", "ny_taxi", "--table", "yellow_taxi_data_may", "--url", "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-05.parquet"]