
{{ config(
    unique_key='id'
) }}

select distinct on (id) *
from (
select distinct
    payload.discussion."active_lock_reason" AS "active_lock_reason",
    payload.discussion."answer_chosen_at" AS "answer_chosen_at",
    payload.discussion."answer_chosen_by" AS "answer_chosen_by",
    payload.discussion."answer_html_url" AS "answer_html_url",
    payload.discussion."body" AS "body",
    payload.discussion."category"."id" AS "category_id",
    payload.discussion."comments" AS "comments",
    payload.discussion."created_at" AS "created_at",
    payload.discussion."html_url" AS "html_url",
    payload.discussion."id" AS "id",
    payload.discussion."locked" AS "locked",
    payload.discussion."node_id" AS "node_id",
    payload.discussion."number" AS "number",
    payload.discussion."repository_url" AS "repository_url",
    payload.discussion."state" AS "state",
    payload.discussion."state_reason" AS "state_reason",
    payload.discussion."timeline_url" AS "timeline_url",
    payload.discussion."title" AS "title",
    payload.discussion."updated_at" AS "updated_at",
    payload.discussion."user"."id" AS "user_id"
from {{ ref('raw_event') }}
where payload.discussion."id" is not null
)
order by all

