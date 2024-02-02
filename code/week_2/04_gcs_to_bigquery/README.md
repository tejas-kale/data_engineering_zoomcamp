## Adding data from GCS to BigQuery

In this section, having stored the yellow taxi data in a storage bucket, we:
- Read the data
- Normalise the column names
    - Replace whitespace with underscore
    - Make lowercase
- Write the data to BigQuery (directly using a SQL block!)

*Note*: While we create a Postgres database container in this section using the same `docker-compose.yml` file as in the earlier sections, this database is not used and is thus redundant.