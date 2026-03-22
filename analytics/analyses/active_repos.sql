select
    repo_name,
    count(*) as event_count
from activity_by_date
group by repo_name
order by event_count desc
limit 20