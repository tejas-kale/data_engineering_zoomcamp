## Add data to a Postgres table

In this section, we create two containers - one with Mage AI and the other with a Postgres database. Using Mage, we define and execute a pipeline that:
- Reads yellow taxi data (available [here](https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz))
- Removes rows with `passenger_count = 0`
- Adds the data to a Postgres table

## What happens after we start containers?

When we execute `docker compose up`, two containers are spawned - one running a Postgres database and the other running Mage. Both containers are configured with Postgres database variables defined in the `.env` file. Any additions or modifications done using the Mage UI are in the container and not in our local machine or Codespace. Hence, it is easier to do any Mage-related changes in the editors provided as part of Mage UI. 

For example, to test our connection to the Postgres server running another container, we can follow these steps in the UI:

- In the *Pipelines* section, click on *New* and *Standard (batch)*.
- In the *Edit* menu, click on *Pipeline settings,* change the pipeline name to `test_config`, and click on *Save pipeline settings*.
- Go to the *Edit pipeline* area, click on *Data loader* followed by *SQL*.
- In the SQL editor that shows up, modify the connection name to *PostgreSQL* and the profile to *dev*.
- Enter `SELECT 1;` in the editor and run the block. Verify the output is a single row consisting of the value `1`.