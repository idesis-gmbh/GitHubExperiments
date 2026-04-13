select
    type as event_type,
    count(*) as event_count,
    round(100.0 * count(*) / sum(count(*)) over (), 2) as pct
from event
group by event_type
order by event_count desc;