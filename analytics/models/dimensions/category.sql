
select distinct on (id) *
from (
select distinct
    payload.discussion.category."created_at" AS "created_at",
    payload.discussion.category."description" AS "description",
    payload.discussion.category."emoji" AS "emoji",
    payload.discussion.category."id" AS "id",
    payload.discussion.category."is_answerable" AS "is_answerable",
    payload.discussion.category."name" AS "name",
    payload.discussion.category."node_id" AS "node_id",
    payload.discussion.category."repository_id" AS "repository_id",
    payload.discussion.category."slug" AS "slug",
    payload.discussion.category."updated_at" AS "updated_at"
from {{ ref('raw_event') }}
where payload.discussion.category."id" is not null
)
order by all

