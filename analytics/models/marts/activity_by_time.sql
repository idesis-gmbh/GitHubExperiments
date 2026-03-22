select
    t.hour,
    t.am_pm,
    t.time_of_day,
    t.datetime,
    r.name as repo_name,
    e.type as event_type,
    a.login as actor_login,
    o.login as org_login,
    count(*) as event_count
from {{ ref('event') }} e
inner join {{ ref('time') }} t on cast(e.created_at as date) = t.datetime
left join {{ ref('repo') }} r on e.repo_id = r.id
left join {{ ref('actor') }} a on e.actor_id = a.id
left join {{ ref('org') }} o on e.org_id = o.id
group by all
