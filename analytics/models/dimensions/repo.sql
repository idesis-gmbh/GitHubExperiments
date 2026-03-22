
select distinct on (id) *
from (
select distinct
    repo."id" AS "id",
    repo."name" AS "name",
    repo."url" AS "url"
from {{ ref('raw_event') }}
where repo."id" is not null
union all
select distinct
    payload.pull_request.head.repo."id" AS "id",
    payload.pull_request.head.repo."name" AS "name",
    payload.pull_request.head.repo."url" AS "url"
from {{ ref('raw_event') }}
where payload.pull_request.head.repo."id" is not null
union all
select distinct
    payload.pull_request.base.repo."id" AS "id",
    payload.pull_request.base.repo."name" AS "name",
    payload.pull_request.base.repo."url" AS "url"
from {{ ref('raw_event') }}
where payload.pull_request.base.repo."id" is not null
)
order by all

