{{ config(
    unique_key='datetime'
) }}

with timestamps as (
    select cast(created_at as timestamp) as timestamp
    from {{ ref('event') }} 
)
select distinct
    date_trunc('hour', timestamp) as datetime,
    date_part('hour', timestamp) as hour,
    case when date_part('hour', timestamp) < 12 then 'AM' else 'PM' end as am_pm,
    case
        when date_part('hour', timestamp) between 6 and 11 then 'Morning'
        when date_part('hour', timestamp) between 12 and 17 then 'Afternoon'
        when date_part('hour', timestamp) between 18 and 22 then 'Evening'
        else 'Night'
    end as time_of_day
from timestamps