
{{ config(
    unique_key='id'
) }}

select distinct on (id) *
from (
select distinct
    payload.discussion."answer_chosen_at" AS "answer_chosen_at",
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
    payload.discussion."reactions"."+1" AS "reactions_+1",
    payload.discussion."reactions"."-1" AS "reactions_-1",
    payload.discussion."reactions"."confused" AS "reactions_confused",
    payload.discussion."reactions"."eyes" AS "reactions_eyes",
    payload.discussion."reactions"."heart" AS "reactions_heart",
    payload.discussion."reactions"."hooray" AS "reactions_hooray",
    payload.discussion."reactions"."laugh" AS "reactions_laugh",
    payload.discussion."reactions"."rocket" AS "reactions_rocket",
    payload.discussion."reactions"."total_count" AS "reactions_total_count",
    payload.discussion."reactions"."url" AS "reactions_url",
    payload.discussion."repository_url" AS "repository_url",
    payload.discussion."state" AS "state",
    payload.discussion."timeline_url" AS "timeline_url",
    payload.discussion."title" AS "title",
    payload.discussion."updated_at" AS "updated_at",
    payload.discussion."user"."id" AS "user_id"
from {{ ref('raw_event') }}
where payload.discussion."id" is not null
)
order by all

