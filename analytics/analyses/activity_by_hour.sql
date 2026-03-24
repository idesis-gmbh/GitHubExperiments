select
    hour,
    time_of_day,
    sum(event_count) as event_count
from activity_by_time
group by hour, time_of_day
order by hour;