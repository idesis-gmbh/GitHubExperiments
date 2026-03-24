select
    case when org_login is null then 'Personal' else 'Organisation' end as repo_type,
    sum(event_count) as event_count,
    round(100.0 * sum(event_count) / sum(sum(event_count)) over (), 2) as pct
from activity_by_date
group by repo_type
order by event_count desc;