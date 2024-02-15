{{
    config(
        materialized='table'
    )
}}

with tripsdata as (
    select * from {{ ref('fact_trips') }}
)
select 
    -- Revenue grouping
    pickup_zone as revenue_zone,
    -- This is a cross-database macro that automatically generates the appropriate
    -- SQL code based on the underlying database or data warehouse.
    {{ dbt.date_trunc("month", "pickup_datetime") }} as revenue_month,
    service_type,
    -- Revenue calculation
    sum(fare_amount) as revenue_monthly_fare,
    sum(extra) as revenue_monthly_extra,
    sum(mta_tax) as revenue_monthly_mta_tax,
    sum(tip_amount) as revenue_monthly_tip_amount,
    sum(tolls_amount) as revenue_monthly_tolls_amount,
    -- Removing ehail_fee as loading data from an external table causes
    -- an error as the column is defined as a double in certain Parquet
    -- files while it is expected as an integer by the model.
    -- sum(ehail_fee) as revenue_monthly_ehail_fee,
    sum(improvement_surcharge) as revenue_monthly_improvement_surcharge,
    sum(total_amount) as revenue_monthly_total_amount,
    -- Additional calculations
    count(tripid) as total_monthly_trips,
    avg(passenger_count) as avg_monthly_passenger_count,
    avg(trip_distance) as avg_monthly_trip_distance
from tripsdata
group by 1, 2, 3