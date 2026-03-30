select
    org_login,
    count(*) as event_count
from activity_by_date
where org_type = 'Organization'
group by org_login
order by event_count desc
limit 20;
