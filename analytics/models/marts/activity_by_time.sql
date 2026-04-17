select
    t.hour,
    t.am_pm,
    t.time_of_day,
    t.datetime,
    r.name as repo_name,
    e.type as event_type,
    a.login as actor_login,
    au.type as actor_type,
    o.login as org_login,
    ou.type as org_type,
    count(*) as event_count
from {{ ref('event') }} e
inner join {{ ref('time') }} t on e.created_hour = t.datetime
left join {{ ref('repo') }} r on e.repo_id = r.id
left join {{ ref('actor') }} a on e.actor_id = a.id
left join {{ ref('user') }} au on a.id = au.id
left join {{ ref('org') }} o on e.org_id = o.id
left join {{ ref('user') }} ou on o.id = ou.id
group by all
