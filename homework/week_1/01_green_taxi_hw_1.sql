-- Question 3
select count(*) as num_trips
from trip_data
where lpep_pickup_datetime >= '2019-09-18'
  and lpep_dropoff_datetime < '2019-09-19';

-- Question 4
with trip_data_with_pickup_date as (select date(lpep_pickup_datetime) as pickup_date, trip_distance
                                    from trip_data)
select pickup_date, max(trip_distance) as max_distance
from trip_data_with_pickup_date
group by pickup_date
order by max_distance desc;

-- Question 5
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
order by sum_total_amount desc
limit 3;

-- Question 6
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
