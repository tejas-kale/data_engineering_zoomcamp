## Homework 2

1. Once the dataset is loaded, what's the shape of the data?
    
    *Answer*: 266,855 rows x 20 columns
    
2. Upon filtering the dataset where the passenger count is greater than 0 *and* the trip distance is greater than zero, how many rows are left?
    
    *Answer*: 139370
    
3. Which of the following creates a new column `lpep_pickup_date` by converting `lpep_pickup_datetime` to a date?
    
    *Answer*: `data["lpep_pickup_date"] = data["lpep_pickup_datetime"].dt.date` 
    
4. What are the existing values of `VendorID` in the dataset?
    
    *Steps*: 
    
    - Create a new *Data loader* SQL block and connect it to the transformer block.
    - Execute the query `select distinct vendor_id from {{ df_1 }}` .
    
    *Answer*: 1 or 2
    
5. How many columns need to be renamed to snake case?
    
    *Answer*: 4
    
6. Once exported, how many partitions (folders) are present in Google Cloud?
    
    *Answer*: 96 (while I only have 95 partitions)

### Note
All answers come from running the pipeline in Mage. To start Mage:
1. Create a `.env` file containing the following variable:
    - `PROJECT_NAME`
    - `POSTGRES_DBNAME`
    - `POSTGRES_SCHEMA`
    - `POSTGRES_USER`
    - `POSTGRES_PASSWORD`
    - `POSTGRES_HOST`
    - `POSTGRES_PORT`
2. Execute `docker compose up` to start the Mage and Postgres containers.
3. Go to `localhost:6789` in the browser.

The pipeline is named `green_taxi_etl` and in the *Edit pipeline*, we can see
the code written for the data loading, transformation, and export steps.

In order to write the output of the transformation step to a Postgres table, the
Postgres variables defined in `.env` should be added to `io_config.yaml` in the
Mage container. 

For writing the data to GCS, we first need to create a GCS bucket using the
Terraform scripts (`main.tf` and `variables.tf`). To do so, we need the service
account credentials as a JSON file. Export this JSON file as the environment
variable `GOOGLE_APPLICATION_CREDENTIALS` using the following command:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=<path_to_JSON>
```

Then, the GCS bucket can be executed using the commands:

```bash
terraform init
terraform plan
terraform apply
```
