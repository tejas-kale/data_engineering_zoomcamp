-- Create external table
create or replace external table ` august-cirrus-399913.ny_taxi.ext_green_taxi_2022 `
    options (
    format = 'PARQUET',
    uris = [
        'gs://green_taxi_data_august-cirrus-399913/green_tripdata_2022-*.parquet'
        ]
    );

-- Check if the external table is created correctly
select *
from `august-cirrus-399913.ny_taxi.ext_green_taxi_2022`
limit 10;

-- Create a BigQuery table
create or replace table ` august-cirrus-399913.ny_taxi.green_taxi_2022 ` as
    (select *
     from `august-cirrus-399913.ny_taxi.ext_green_taxi_2022`);

-- Check if the BigQuery table is created correctly
select *
from `august-cirrus-399913.ny_taxi.green_taxi_2022`
limit 10;

-- Count of records
select count(1)
from `august-cirrus-399913.ny_taxi.green_taxi_2022`;

-- Check PU location data usage
select count(distinct PULocationID)
from `august-cirrus-399913.ny_taxi.ext_green_taxi_2022`;
select count(distinct PULocationID)
from `august-cirrus-399913.ny_taxi.green_taxi_2022`;

-- Fare amount of 0
select count(1)
from `august-cirrus-399913.ny_taxi.green_taxi_2022`
where fare_amount = 0;

-- Partition and cluster table
create or replace table `august-cirrus-399913.ny_taxi.green_taxi_2022_partitioned`
    partition by date (lpep_pickup_datetime)
    cluster by PULocationID
as
select *
from `august-cirrus-399913.ny_taxi.green_taxi_2022`;

-- Distinct PULocationID between dates
select count(distinct PULocationID)
from `august-cirrus-399913.ny_taxi.green_taxi_2022`
where lpep_pickup_datetime between '2022-06-01' and '2022-06-30';

select count(distinct PULocationID)
from `august-cirrus-399913.ny_taxi.green_taxi_2022_partitioned`
where lpep_pickup_datetime between '2022-06-01' and '2022-06-30';

-- Data usage of materialised table
select count(*)
from `august-cirrus-399913.ny_taxi.green_taxi_2022`
