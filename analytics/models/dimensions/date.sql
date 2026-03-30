{{ config(
    unique_key='date'
) }}

with timestamps as (
    select cast(created_at as timestamp) as timestamp
    from {{ ref('event') }} 
)
select distinct
    cast(timestamp as date) as date,
    date_part('year', timestamp) as year,
    date_part('quarter', timestamp) as quarter,
    date_part('month', timestamp) as month,
    date_part('week', timestamp) as week,
    date_part('day', timestamp) as day,
    cast(date_trunc('month', timestamp) as date) as month_start,
    cast(date_trunc('week', timestamp) as date)  as week_start
from timestamps