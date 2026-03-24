
{{ config(
    unique_key='id'
) }}

select distinct on (id) *
from (
select distinct
    payload.issue.type."color" AS "color",
    payload.issue.type."created_at" AS "created_at",
    payload.issue.type."description" AS "description",
    payload.issue.type."id" AS "id",
    payload.issue.type."is_enabled" AS "is_enabled",
    payload.issue.type."name" AS "name",
    payload.issue.type."node_id" AS "node_id",
    payload.issue.type."updated_at" AS "updated_at"
from {{ ref('raw_event') }}
where payload.issue.type."id" is not null
)
order by all

