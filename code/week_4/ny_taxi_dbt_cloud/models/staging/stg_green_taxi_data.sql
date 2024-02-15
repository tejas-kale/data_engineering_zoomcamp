{{
    config(
        materialized='view'
    )
}}

with tripdata as
(
    -- Look for duplicates over vendor ID and pickup datetime as these columns are
    -- used to generate a unique hash for each row.
    select *,
        row_number() over(partition by vendorid, lpep_pickup_datetime) as rn
    from {{ source('staging', 'green_taxi_dbt') }}
    where vendorid is not null
)
select
    -- Create a unique hash for each row
    {{ dbt_utils.generate_surrogate_key(['vendorid', 'lpep_pickup_datetime']) }} as tripid,
    -- Cast specific columns to integers
    {{ dbt.safe_cast("vendorid", api.Column.translate_type("integer")) }} as vendorid,
    -- Cast timestamp columns to datetime
    cast(lpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,
    -- Trip information
    store_and_fwd_flag,
    {{ dbt.safe_cast("ratecodeid", api.Column.translate_type("integer")) }} as ratecodeid,
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,
    {{ dbt.safe_cast("passenger_count", api.Column.translate_type("integer")) }} as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    {{ dbt.safe_cast("trip_type", api.Column.translate_type("integer")) }} as trip_type,
    -- Payment information
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    -- Removing ehail_fee as loading data from an external table causes
    -- an error as the column is defined as a double in certain Parquet
    -- files while it is expected as an integer by the model.
    -- cast(ehail_fee as decimal) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    cast(congestion_surcharge as numeric) as congestion_surcharge,
    coalesce({{ dbt.safe_cast("payment_type", api.Column.translate_type("integer")) }}, 0) as payment_type,
    {{ get_payment_type_description('payment_type') }} as payment_type_description,
from tripdata
where rn = 1

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}
    limit 100
{% endif %}