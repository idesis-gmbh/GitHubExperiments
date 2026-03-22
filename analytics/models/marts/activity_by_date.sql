select
    d.year,
    d.month,
    d.week,
    d.day,
    d.date,
    r.name as repo_name,
    e.type as event_type,
    a.login as actor_login,
    o.login as org_login,
    count(*) as event_count
from {{ ref('event') }} e
inner join {{ ref('date') }} d on cast(e.created_at as date) = d.date
left join {{ ref('repo') }} r on e.repo_id = r.id
left join {{ ref('actor') }} a on e.actor_id = a.id
left join {{ ref('org') }} o on e.org_id = o.id
group by all