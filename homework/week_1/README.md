# Homework 1

1. Which option of `docker run` means *Automatically remove the container when it exits*?
    
    *Steps*: `docker run --help` (in the terminal)
    
    *Answer*: `rm`
    
2. What is the version of the package `wheel` in the default `python:3.9` image.
    
    *Steps*:
    
    1. `docker run -it python:3.9 /bin/bash`
    2. `python` 
    3. `import wheel; wheel.__version__;`
    
    *Answer:* `0.42.0`
    
3. How many taxi trips were made on September 18, 2019?
    
    *Steps*:
    
    ```sql
    select count(*) as num_trips
    from trip_data
    where lpep_pickup_datetime >= '2019-09-18' and lpep_dropoff_datetime < '2019-09-19';
    ```
    
    *Answer*: `15612`
    
4. Which was the day with the largest trip distance?
    
    *Steps*:
    
    ```sql
    with trip_data_with_pickup_date as (
        select date(lpep_pickup_datetime) as pickup_date, trip_distance
        from trip_data
    )
    select pickup_date, max(trip_distance) as max_distance
    from trip_data_with_pickup_date
    group by pickup_date
    order by max_distance desc;
    ```
    
    *Answer*: `2019-09-26`
    
5. On September 18, 2019, which were the 3 pick-up boroughs (excluding Unknown) with the total fare greater than 50,000?
    
    *Steps*:
    
    ```sql
    with trip_data_with_boroughs as (select td.PULocationID, td.total_amount, tz.Borough, date(lpep_pickup_datetime) as pickup_date
                                     from trip_data td
                                              join (select LocationID, Borough
                                                    from zone_lookup) as tz
                                                   on td.PULocationID = tz.LocationID),
         borough_total_amount as (select Borough, sum(total_amount) as sum_total_amount
                                  from trip_data_with_boroughs
                                  where pickup_date = '2019-09-18'
                                  group by Borough)
    select Borough, sum_total_amount
    from borough_total_amount
    where sum_total_amount > 50000 and Borough != 'Unknown'
    order by sum_total_amount desc;
    ```
    
    *Answer*: `Brooklyn, Manhattan, Queens`
    
6. Name the drop-off zone with the largest tip where the pick up zone was Astoria.
    
    *Steps*:
    
    ```sql
    with trip_data_with_pu_zone as (select td.PULocationID, td.DOLocationId, td.tip_amount, tz.Zone as pu_zone
                                         from trip_data td
                                                  join (select LocationID, Zone
                                                        from zone_lookup) as tz
                                                       on td.PULocationID = tz.LocationID),
        trip_data_with_do_zone as (select td.PULocationID, td.DOLocationId, td.tip_amount, td.pu_zone, tz.Zone as do_zone
                                         from trip_data_with_pu_zone td
                                                  join (select LocationID, Zone
                                                        from zone_lookup) as tz
                                                       on td.DOLocationId = tz.LocationID),
        trip_data_from_astoria as (select do_zone, tip_amount
                                   from trip_data_with_do_zone
                                   where pu_zone = 'Astoria')
    select do_zone, max(tip_amount) as max_tip_amount
    from trip_data_from_astoria
    group by do_zone
    order by max_tip_amount desc
    limit 1;
    ```
    
    *Answer*: `JFK Airport`
    
7. Output of `terraform apply`
    
    *Steps*:
    
    ```bash
    terraform init
    terraform plan
    terraform apply
    ```
    
    *Answer*: 
    
    ```bash
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
      + create
    
    Terraform will perform the following actions:
    
      # google_bigquery_dataset.dataset will be created
      + resource "google_bigquery_dataset" "dataset" {
          + creation_time              = (known after apply)
          + dataset_id                 = "trips_data_all"
          + default_collation          = (known after apply)
          + delete_contents_on_destroy = false
          + effective_labels           = (known after apply)
          + etag                       = (known after apply)
          + id                         = (known after apply)
          + is_case_insensitive        = (known after apply)
          + last_modified_time         = (known after apply)
          + location                   = "europe-west4"
          + max_time_travel_hours      = (known after apply)
          + project                    = "august-cirrus-399913"
          + self_link                  = (known after apply)
          + storage_billing_model      = (known after apply)
          + terraform_labels           = (known after apply)
        }
    
      # google_storage_bucket.data-lake-bucket will be created
      + resource "google_storage_bucket" "data-lake-bucket" {
          + effective_labels            = (known after apply)
          + force_destroy               = true
          + id                          = (known after apply)
          + location                    = "EUROPE-WEST4"
          + name                        = "dez_data_lake_august-cirrus-399913"
          + project                     = (known after apply)
          + public_access_prevention    = (known after apply)
          + rpo                         = (known after apply)
          + self_link                   = (known after apply)
          + storage_class               = "STANDARD"
          + terraform_labels            = (known after apply)
          + uniform_bucket_level_access = true
          + url                         = (known after apply)
    
          + lifecycle_rule {
              + action {
                  + type = "Delete"
                }
              + condition {
                  + age                   = 30
                  + matches_prefix        = []
                  + matches_storage_class = []
                  + matches_suffix        = []
                  + with_state            = (known after apply)
                }
            }
    
          + versioning {
              + enabled = true
            }
        }
    
    Plan: 2 to add, 0 to change, 0 to destroy.
    
    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.
    
      Enter a value: yes
    
    google_bigquery_dataset.dataset: Creating...
    google_storage_bucket.data-lake-bucket: Creating...
    google_bigquery_dataset.dataset: Creation complete after 2s [id=projects/august-cirrus-399913/datasets/trips_data_all]
    google_storage_bucket.data-lake-bucket: Creation complete after 3s [id=dez_data_lake_august-cirrus-399913]
    
    Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
    ```
    

**Preparation for questions 3-6**:

- Download the [Green Taxi trip data](https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2019-09.parquet) and [Taxi Zone data](https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv).
- Specify the location of `sqlite` file to add the data.
- Load both the datasets as Pandas dataframes.
- Add the dataframes as separate tables to the SQLite database using the `sqlite3` package.

**Note**:

The intention of questions 3-6 is to start a Postgres database server using a Docker file and then import the data (trip and zone codes) into the database either using a Jupyter notebook or a pipeline. The latter option consists of using a collection of Docker containers (Postgres + Trip data ingestion + Zone code ingestion) and executing them using `docker run` or `docker-compose` while ensuring that they all share the same network (which happens by default using `docker-compose`).

While trying to execute this intention, the biggest hurdle I faced was that my Macbook Air slowed down significantly on using Docker. Even when I could use Docker, I had trouble in passing arguments to my data ingestion using `docker-compose` and I did not wish to spend a lot of time debugging it due to paucity of time. Hence, I have opted for loading the data in a local SQLite database instead.