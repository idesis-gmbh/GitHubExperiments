select distinct
    date_trunc('hour', created_at) as datetime,
    date_part('hour', created_at) as hour,
    case when date_part('hour', created_at) < 12 then 'AM' else 'PM' end as am_pm,
    case
        when date_part('hour', created_at) between 6 and 11 then 'Morning'
        when date_part('hour', created_at) between 12 and 17 then 'Afternoon'
        when date_part('hour', created_at) between 18 and 22 then 'Evening'
        else 'Night'
    end as time_of_day
from {{ ref('event') }}