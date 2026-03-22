select distinct
    cast(created_at as date) as date,
    date_part('year', created_at) as year,
    date_part('quarter', created_at) as quarter,
    date_part('month', created_at) as month,
    date_part('week', created_at) as week,
    date_part('day', created_at) as day,
    cast(date_trunc('month', created_at) as date) as month_start,
    cast(date_trunc('week', created_at) as date)  as week_start
from {{ ref('event') }}