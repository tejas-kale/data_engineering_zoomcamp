# Week 3 Homework

## Setup

- Create an external table using the Green Taxi Trip Records Data for 2022.
    
    ```sql
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
    ```
    
- Create a table in BQ using the Green Taxi Trip Records for 2022 (do not partition or cluster this table).
    
    ```sql
    -- Create a BigQuery table
    create or replace table ` august-cirrus-399913.ny_taxi.green_taxi_2022 ` as
        (select *
         from `august-cirrus-399913.ny_taxi.ext_green_taxi_2022`);
    
    -- Check if the BigQuery table is created correctly
    select *
    from `august-cirrus-399913.ny_taxi.green_taxi_2022`
    limit 10;
    ```
    

## Questions

1. What is count of records for the 2022 Green Taxi Data?
    
    *Steps*:
    
    ```sql
    -- Count of records
    select count(1) from `august-cirrus-399913.ny_taxi.green_taxi_2022`;
    ```
    
    *Answer*: 840,402
    
2. Write a query to count the distinct number of `PULocationID`s for the entire dataset on both the tables. What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?
    
    *Steps*:
    
    ```sql
    select count(distinct PULocationID) from `august-cirrus-399913.ny_taxi.ext_green_taxi_2022`;
    select count(distinct PULocationID) from `august-cirrus-399913.ny_taxi.green_taxi_2022`;
    ```
    
    *Answer*: 0MB for external table and 6.41MB for BigQuery table
    
3. How many records have a `fare_amount` of 0?
    
    *Steps*:
    
    ```sql
    select count(1)
    from `august-cirrus-399913.ny_taxi.green_taxi_2022`
    where fare_amount = 0;
    ```
    
    *Answer*: 1622
    
4. What is the best strategy to make an optimised table in Big Query if your query will always order the results by `PUlocationID` and filter based on `lpep_pickup_datetime`? (Create a new table with this strategy)
    
    *Steps*:
    
    ```sql
    create or replace table `august-cirrus-399913.ny_taxi.green_taxi_2022_partitioned`
        partition by date (lpep_pickup_datetime)
        cluster by PULocationID
    as
    select *
    from `august-cirrus-399913.ny_taxi.green_taxi_2022`;
    ```
    
    *Answer*: Partition by `lpep_pickup_datetime` and cluster by `PULocationID`
    
5. Write a query to retrieve the distinct `PULocationID` between `lpep_pickup_datetime` 06/01/2022 and 06/30/2022 (inclusive). Use the materialised table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values?
    
    *Steps*:
    
    ```sql
    -- Distinct PULocationID between dates
    select count(distinct PULocationID)
    from `august-cirrus-399913.ny_taxi.green_taxi_2022`
    where lpep_pickup_datetime between '2022-06-01' and '2022-06-30';
    
    select count(distinct PULocationID)
    from `august-cirrus-399913.ny_taxi.green_taxi_2022_partitioned`
    where lpep_pickup_datetime between '2022-06-01' and '2022-06-30';
    ```
    
    *Answer*: 12.82MB for non-partitioned data and 1.12MB for partitioned data
    
6. Where is the data stored in the External Table you created?
    
    *Answer*: GCP Bucket
    
7. It is best practice in Big Query to always cluster your data:
    
    *Answer*: False
    
8. Write a `SELECT count(*)` query FROM the materialised table you created. How many bytes does it estimate will be read? Why?

   *Answer*: The number of rows in a table is stored in the table metadata by BigQuery. Hence, the query select count(*) does not incur any cost and we see the message This query will process 0B when run. If we add a where clause to the query then BigQuery will need to scan the whole table or a segment of it (based on partitioning and clustering) and hence the query won’t be free.
