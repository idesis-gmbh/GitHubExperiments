
select distinct on (id) *
from (
select distinct
    payload.label."color" AS "color",
    payload.label."default" AS "default",
    payload.label."description" AS "description",
    payload.label."id" AS "id",
    payload.label."name" AS "name",
    payload.label."node_id" AS "node_id",
    payload.label."url" AS "url"
from {{ ref('raw_event') }}
where payload.label."id" is not null
)
order by all

