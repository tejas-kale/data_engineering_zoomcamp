## Adding data to GCS

In this section, we create a Mage container in which we define a pipeline that:
- Reads yellow taxi data (available [here](https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz))
- Removes rows with `passenger_count = 0`
- Adds the data to our Google Cloud Storage bucket in Parquet format

We create 2 data exporter blocks:
- Export the data to storage bucket as a single Parquet file
- Using PyArrow, add data to storage bucket partitioned by pickup date in the data

Partitioning is essential for large datasets (as a rule of thumb with more than a million rows) as it improves the query execution speed.

*Note*: While we create a Postgres database container in this section using the same `docker-compose.yml` file as in the earlier sections, this database is not used and is thus redundant.
