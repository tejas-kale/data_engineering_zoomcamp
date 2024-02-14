{{
    config(
        materialized='table'
    )
}}

with green_taxi_data as (
    select *,
        'green' as service_type
    from {{ ref('stg_green_taxi_data') }}
),
yellow_taxi_data as (
    select *,
        'yellow' as service_type
    from {{ ref('stg_yellow_taxi_data') }}
),
taxi_data as (
    select *
    from green_taxi_data
    union all
    select *
    from yellow_taxi_data
),
dim_zones as (
    select *
    from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select 
    t.tripid,
    t.vendorid,
    t.service_type,
    t.ratecodeid,
    t.pickup_locationid,
    pickup_zone.borough as pickup_borough,
    pickup_zone.zone as pickup_zone,
    t.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough,
    dropoff_zone.zone as dropoff_zone,
    t.pickup_datetime,
    t.dropoff_datetime,
    t.store_and_fwd_flag,
    t.passenger_count,
    t.trip_distance,
    t.trip_type,
    t.fare_amount,
    t.extra,
    t.mta_tax,
    t.tip_amount,
    t.tolls_amount,
    -- Removing ehail_fee as loading data from an external table causes
    -- an error as the column is defined as a double in certain Parquet
    -- files while it is expected as an integer by the model.
    -- t.ehail_fee,
    t.improvement_surcharge,
    t.total_amount,
    t.payment_type,
    t.payment_type_description
from taxi_data t
inner join dim_zones as pickup_zone
on t.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on t.dropoff_locationid = dropoff_zone.locationid