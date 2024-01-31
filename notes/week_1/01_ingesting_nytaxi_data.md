# Ingesting NY Taxi Data to Postgres

## Postgres

Postgres is a type of database that can hold tabular data. We can query this database using Structured Query Language (SQL). An official Docker image of this database is available which makes it easy to run the database inside a container in our machine.

## Creating a Postgres container

In order to create a Postgres container, we run the following command:

```bash
docker run -it \\
	-e POSTGRES_USER="root" \\
    -e POSTGRES_PASSWORD="root" \\
    -e POSTGRES_DB="ny_taxi" \\
    -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \\
    -p 5432:5432 \\
    postgres:13

```

In this command, we are creating a container running version 13 of the database. Each Postgres database needs to have a name and user credentials. These are Docker environment variables which we specify with the `-e` argument.

When we run a Postgres container, the data added to the database is stored in the form of special files in `/var/lib/postgresql/data`. But this path is only valid for the lifetime of the container and the data gets deleted after the container is stopped. This is problematic as we need to import the data into the database every time we start a container. Hence, using the `-v` argument, we map the path to database files inside the container to a path on our machine. This helps preserve the database files regardless of the state of the container. `$(pwd)/ny_taxi_postgres_data` means that a directory named `ny_taxi_postgres_data` should be present in the directory from which we execute this command.

When we start a Postgres Docker container, we are executing a Postgres server which listens to port `5432` of the container. Using the `-p` argument, we map the container port to the port `5432` of our machine so that we query results from the database.

If the container runs properly, the expected output is as follows:

```bash
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.utf8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /var/lib/postgresql/data ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... Etc/UTC
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

initdb: warning: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    pg_ctl -D /var/lib/postgresql/data -l logfile start

waiting for server to start....2022-01-22 20:34:57.959 UTC [50] LOG:  starting PostgreSQL 13.5 (Debian 13.5-1.pgdg110+1) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2022-01-22 20:34:57.977 UTC [50] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2022-01-22 20:34:58.010 UTC [51] LOG:  database system was shut down at 2022-01-22 20:34:56 UTC
2022-01-22 20:34:58.032 UTC [50] LOG:  database system is ready to accept connections
 done

```

## `pgcli`

We can now connect to this Postgres database in two ways. First is through a Python-based command line program called `pgcli` which we can install via `pip` as follows:

```bash
pip install pgcli

```

We can then connect to the database with the following command:

```bash
pgcli -h localhost -p 5432 -U root -d ny_taxi

```

We then need to enter the password for this container. The result log might contain an error saying `paycopg2.errors.UndefinedColumn: column def.adsrc does not exist`. We can ignore it and press `Return` to enter the SQL console.

```bash
Version: 1.9.0
Chat: <https://gitter.im/dbcli/pgcli>
Mail: <https://groups.google.com/forum/#!forum/pgcli>
Home: <http://pgcli.com>
root@localhost:ny_taxi> Exception in thread completion_refresh:
Traceback (most recent call last):
  File "/Users/tejaskale/opt/anaconda3/envs/revise_data_science/lib/python3.8/threading.py", line 932, in _bootstrap_inner
    self.run()
  File "/Users/tejaskale/opt/anaconda3/envs/revise_data_science/lib/python3.8/threading.py", line 870, in run
    self._target(*self._args, **self._kwargs)
  File "/Users/tejaskale/opt/anaconda3/envs/revise_data_science/lib/python3.8/site-packages/pgcli/completion_refresher.py", line 68, in _bg_refresh
    refresher(completer, executor)
  File "/Users/tejaskale/opt/anaconda3/envs/revise_data_science/lib/python3.8/site-packages/pgcli/completion_refresher.py", line 110, in refresh_tables
    completer.extend_columns(executor.table_columns(), kind='tables')
  File "/Users/tejaskale/opt/anaconda3/envs/revise_data_science/lib/python3.8/site-packages/pgcli/pgcompleter.py", line 204, in extend_columns
    for schema, relname, colname, datatype, has_default, default in column_data:
  File "/Users/tejaskale/opt/anaconda3/envs/revise_data_science/lib/python3.8/site-packages/pgcli/pgexecute.py", line 483, in table_columns
    for row in self._columns(kinds=['r']):
  File "/Users/tejaskale/opt/anaconda3/envs/revise_data_science/lib/python3.8/site-packages/pgcli/pgexecute.py", line 478, in _columns
    cur.execute(sql)
psycopg2.errors.UndefinedColumn: column def.adsrc does not exist
LINE 7:                         def.adsrc as default

```

## IntelliJ

Another convenient way to connect to this Postgres database is through the database plugin of IntelliJ IDEA. Go to `File -> New -> Data Source -> PostgreSQL` and ensure the following parameters:

> Host: localhost
Port: 5432
User: root
Password: root
Database: ny_taxi
> 

If IntelliJ shows a warning about missing drivers, install them. Using the `Test Connection` link, we can check if the database is accessible. Once that check returns OK, we can click on `Apply` and `OK`.

## NY taxi data

Let us now import some data into our new Postgres database. We will add a section of the [data](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page) that captures information on taxi rides in New York City. To be specific, we will get the `Yellow Taxi Trip Records` for the month of January, 2021 which is available as a CSV file. A description of the column in the CSV file can be found [here](https://www1.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf).

After downloading this data, let us load it in a Jupyter notebook using the Pandas library.

```python
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from time import time

import pandas as pd

```

```python
data_fn: str = "./data/yellow_tripdata_2021_01.csv"

```

```python
yellow_taxi: pd.DataFrame = pd.read_csv(data_fn)
yellow_taxi

```

```python
         VendorID tpep_pickup_datetime tpep_dropoff_datetime  passenger_count  \\
0             1.0  2021-01-01 00:30:10   2021-01-01 00:36:12              1.0
1             1.0  2021-01-01 00:51:20   2021-01-01 00:52:19              1.0
2             1.0  2021-01-01 00:43:30   2021-01-01 01:11:06              1.0
3             1.0  2021-01-01 00:15:48   2021-01-01 00:31:01              0.0
4             2.0  2021-01-01 00:31:49   2021-01-01 00:48:21              1.0
...           ...                  ...                   ...              ...
1369760       NaN  2021-01-25 08:32:04   2021-01-25 08:49:32              NaN
1369761       NaN  2021-01-25 08:34:00   2021-01-25 09:04:00              NaN
1369762       NaN  2021-01-25 08:37:00   2021-01-25 08:53:00              NaN
1369763       NaN  2021-01-25 08:28:00   2021-01-25 08:50:00              NaN
1369764       NaN  2021-01-25 08:38:00   2021-01-25 08:50:00              NaN

         trip_distance  RatecodeID store_and_fwd_flag  PULocationID  \\
0                 2.10         1.0                  N           142
1                 0.20         1.0                  N           238
2                14.70         1.0                  N           132
3                10.60         1.0                  N           138
4                 4.94         1.0                  N            68
...                ...         ...                ...           ...
1369760           8.80         NaN                NaN           135
1369761           5.86         NaN                NaN            42
1369762           4.45         NaN                NaN            14
1369763          10.04         NaN                NaN           175
1369764           4.93         NaN                NaN           248

         DOLocationID  payment_type  fare_amount  extra  mta_tax  tip_amount  \\
0                  43           2.0         8.00   3.00      0.5        0.00
1                 151           2.0         3.00   0.50      0.5        0.00
2                 165           1.0        42.00   0.50      0.5        8.65
3                 132           1.0        29.00   0.50      0.5        6.05
4                  33           1.0        16.50   0.50      0.5        4.06
...               ...           ...          ...    ...      ...         ...
1369760            82           NaN        21.84   2.75      0.5        0.00
1369761           161           NaN        26.67   2.75      0.5        0.00
1369762           106           NaN        25.29   2.75      0.5        0.00
1369763           216           NaN        28.24   2.75      0.5        0.00
1369764           168           NaN        20.76   2.75      0.5        0.00

         tolls_amount  improvement_surcharge  total_amount  \\
0                 0.0                    0.3         11.80
1                 0.0                    0.3          4.30
2                 0.0                    0.3         51.95
3                 0.0                    0.3         36.35
4                 0.0                    0.3         24.36
...               ...                    ...           ...
1369760           0.0                    0.3         25.39
1369761           0.0                    0.3         30.22
1369762           0.0                    0.3         28.84
1369763           0.0                    0.3         31.79
1369764           0.0                    0.3         24.31

         congestion_surcharge
0                         2.5
1                         0.0
2                         0.0
3                         0.0
4                         2.5
...                       ...
1369760                   0.0
1369761                   0.0
1369762                   0.0
1369763                   0.0
1369764                   0.0

[1369765 rows x 18 columns]

```

The data consists of 1,369,765 rows and 18 columns. The columns showing pick-up and drop-off timings are strings when they should be date times. Let us correct the types.

```python
dt_cols: list = ["tpep_pickup_datetime", "tpep_dropoff_datetime"]
yellow_taxi.loc[:, dt_cols] = yellow_taxi[dt_cols].apply(pd.to_datetime)

```

Before we add this data as a table to our Postgres database, we need to define its schema i.e. column names and types. Pandas provides a convenient `get_schema()` method to construct the schema of a data frame.

```python
pd.io.sql.get_schema(yellow_taxi, name="yellow_taxi_data")

```

```python
CREATE TABLE "yellow_taxi_data" (
"VendorID" REAL,
  "tpep_pickup_datetime" TIMESTAMP,
  "tpep_dropoff_datetime" TIMESTAMP,
  "passenger_count" REAL,
  "trip_distance" REAL,
  "RatecodeID" REAL,
  "store_and_fwd_flag" TEXT,
  "PULocationID" INTEGER,
  "DOLocationID" INTEGER,
  "payment_type" REAL,
  "fare_amount" REAL,
  "extra" REAL,
  "mta_tax" REAL,
  "tip_amount" REAL,
  "tolls_amount" REAL,
  "improvement_surcharge" REAL,
  "total_amount" REAL,
  "congestion_surcharge" REAL
)

```

The schema is written in *Database Definition Language* (DDL). While the data types of each column are correct, they are not optimal but that is a concern for later.

## SQLAlchemy

In order to interact with a database from Python, Pandas using a library called *SQLAlchemy*. The `get_schema()` method in Pandas creates the schema for SQLite by default. If we want to see the schema for Postgres, we need to add a SQLAlchemy connection to our Postgres database. First, we need to install the package using either of the following two commands:

```bash
pip install sqlalchemy
# conda install sqlalchemy

```

Next, we need to create a connection, formally called an *engine*, to our database.

```python
engine: Engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
engine.connect()

```

As we are connecting to a Postgres database, the path to it starts with `postgresql://`. Then we specify the username and password separated by a colon. An `@` is added after it to specify the IP address and port of the database which is turn is followed by the database name after the `/`. To verify if we have specified the correct information to connect to our database, we execute the `engine.connect()` command. If the connection is successful, we should get an output like the one below:

```python
<sqlalchemy.engine.base.Connection at 0x7fbb4a4e8460>

```

Then, while generating the schema from Pandas, we can specify the SQLAlchemy engine so that Pandas creates a schema for the right database type.

```python
print(pd.io.sql.get_schema(yellow_taxi, name='yellow_taxi_data'))

```

```python
CREATE TABLE yellow_taxi_data (
	"VendorID" FLOAT(53),
	tpep_pickup_datetime TIMESTAMP WITHOUT TIME ZONE,
	tpep_dropoff_datetime TIMESTAMP WITHOUT TIME ZONE,
	passenger_count FLOAT(53),
	trip_distance FLOAT(53),
	"RatecodeID" FLOAT(53),
	store_and_fwd_flag TEXT,
	"PULocationID" BIGINT,
	"DOLocationID" BIGINT,
	payment_type FLOAT(53),
	fare_amount FLOAT(53),
	extra FLOAT(53),
	mta_tax FLOAT(53),
	tip_amount FLOAT(53),
	tolls_amount FLOAT(53),
	improvement_surcharge FLOAT(53),
	total_amount FLOAT(53),
	congestion_surcharge FLOAT(53)
)

```

## Adding data to the database

Finally, let us add this data on yellow taxi trips to the database. Since this data is large, we can load it incrementally with Pandas and the add it to our database. We can create an iterator to our data CSV file in Pandas as follows:

```python
yellow_taxi_iter = pd.read_csv(data_fn, iterator=True, chunksize=100000)

```

After specifying `iterator` to be `True`, `chunksize` lets us control the number of rows to read from the CSV file in each iteration. We can now get the first chunk of 100,000 rows using the `next()` function.

```python
yellow_taxi_first_chunk: pd.DataFrame = next(yellow_taxi_iter)
yellow_taxi_first_chunk

```

```python
       VendorID tpep_pickup_datetime tpep_dropoff_datetime  passenger_count  \\
0             1  2021-01-01 00:30:10   2021-01-01 00:36:12                1
1             1  2021-01-01 00:51:20   2021-01-01 00:52:19                1
2             1  2021-01-01 00:43:30   2021-01-01 01:11:06                1
3             1  2021-01-01 00:15:48   2021-01-01 00:31:01                0
4             2  2021-01-01 00:31:49   2021-01-01 00:48:21                1
...         ...                  ...                   ...              ...
99995         1  2021-01-04 14:04:31   2021-01-04 14:08:52                3
99996         1  2021-01-04 14:18:46   2021-01-04 14:35:45                2
99997         1  2021-01-04 14:42:41   2021-01-04 14:59:22                2
99998         2  2021-01-04 14:39:02   2021-01-04 15:09:37                2
99999         2  2021-01-04 14:49:36   2021-01-04 14:54:44                5

       trip_distance  RatecodeID store_and_fwd_flag  PULocationID  \\
0               2.10           1                  N           142
1               0.20           1                  N           238
2              14.70           1                  N           132
3              10.60           1                  N           138
4               4.94           1                  N            68
...              ...         ...                ...           ...
99995           0.70           1                  N           234
99996           3.30           1                  N           234
99997           4.70           1                  N           236
99998          17.95           2                  N           132
99999           0.37           1                  N           236

       DOLocationID  payment_type  fare_amount  extra  mta_tax  tip_amount  \\
0                43             2          8.0    3.0      0.5        0.00
1               151             2          3.0    0.5      0.5        0.00
2               165             1         42.0    0.5      0.5        8.65
3               132             1         29.0    0.5      0.5        6.05
4                33             1         16.5    0.5      0.5        4.06
...             ...           ...          ...    ...      ...         ...
99995           224             2          5.0    2.5      0.5        0.00
99996           236             1         14.5    2.5      0.5        3.55
99997            79             1         17.0    2.5      0.5        4.05
99998           148             1         52.0    0.0      0.5        5.00
99999           236             2          5.0    0.0      0.5        0.00

       tolls_amount  improvement_surcharge  total_amount  congestion_surcharge
0               0.0                    0.3         11.80                   2.5
1               0.0                    0.3          4.30                   0.0
2               0.0                    0.3         51.95                   0.0
3               0.0                    0.3         36.35                   0.0
4               0.0                    0.3         24.36                   2.5
...             ...                    ...           ...                   ...
99995           0.0                    0.3          8.30                   2.5
99996           0.0                    0.3         21.35                   2.5
99997           0.0                    0.3         24.35                   2.5
99998           0.0                    0.3         60.30                   2.5
99999           0.0                    0.3          8.30                   2.5

[100000 rows x 18 columns]

```

Pandas provides a convenient `to_sql()` method which makes it easy to add a data frame to a database. Let us start doing that by first creating a database table with just the column names and types.

```python
yellow_taxi_first_chunk.head(n=0).to_sql(name='yellow_taxi_data', con=engine, if_exists='replace')

```

If a table by this name exists, we specify through the `if_exists` argument to replace it. To check if the table has been created in `pgcli`, we can run the following command:

```bash
\\dt

```

It should return a list of tables with `yellow_taxi_data` in it.

```bash
+--------+------------------+-------+-------+
| Schema | Name             | Type  | Owner |
|--------+------------------+-------+-------|
| public | yellow_taxi_data | table | root  |
+--------+------------------+-------+-------+

```

In IntelliJ IDEA, right click on the database name (`ny_taxi` here), and click on `Jump to Query Console -> Default Console`. Here, in the top right of the console, click on the `Switch current schema` dropdown and select `nytaxi.schema`. In the `Database` section, we should see a table called `yellow_taxi_data` under `PostgreSQL - ny_taxi@localhost -> ny_taxi -> public -> tables`.

![Untitled](images/Untitled.png)

Now, let us iterate over the data frame and add chunks to Postgres.

```python
yellow_taxi_iter = pd.read_csv(data_fn, iterator=True, chunksize=100000)
while True:
    iter_start: float = time()
    df: pd.DataFrame = next(yellow_taxi_iter)
    df.loc[:, dt_cols] = df[dt_cols].apply(pd.to_datetime)
    df.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')
    iter_end: float = time()
    print(f'Added another chunk in {iter_end - iter_start} seconds.')

```

As we already used the iterator previously to add schema to the database table, we recreate the iterator so that we do not skip inserting the first chunk. While adding the data in this loop, we set `if_exists` as `True` in the `to_sql()` method. Each chunk is inserted in 15-20 seconds. After the loop completes, we can check the count of records in our database table (`yellow_taxi_data`) with the following command:

```sql
select count(1) from ny_taxi.public.yellow_taxi_data;

```

The expected output is `1,369,765`.

## References

- [DE Zoomcamp 1.2.2 - Ingesting NY Taxi Data to Postgres](https://www.youtube.com/watch?v=2JM-ziJt0WI&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=6)