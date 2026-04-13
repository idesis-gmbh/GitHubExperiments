select
    actor_login,
    sum(event_count) as event_count
from activity_by_date
where actor_type = 'Bot'
group by actor_login
order by event_count desc
limit 20;

select
    actor_login,
    sum(event_count) as event_count
from activity_by_date
where actor_type = 'User'
group by actor_login
order by event_count desc
limit 20;

/* select
    actor_login,
    sum(event_count) as event_count
from activity_by_date
where actor_type = 'Mannequin'
group by actor_login
order by event_count desc
limit 20; */

