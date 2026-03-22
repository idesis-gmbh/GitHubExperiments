
select distinct on (id) *
from (
select distinct
    payload.review."_links"."html"."href" AS "_links_html_href",
    payload.review."_links"."pull_request"."href" AS "_links_pull_request_href",
    payload.review."body" AS "body",
    payload.review."commit_id" AS "commit_id",
    payload.review."html_url" AS "html_url",
    payload.review."id" AS "id",
    payload.review."node_id" AS "node_id",
    payload.review."pull_request_url" AS "pull_request_url",
    payload.review."state" AS "state",
    payload.review."submitted_at" AS "submitted_at",
    payload.review."updated_at" AS "updated_at",
    payload.review."user"."id" AS "user_id"
from {{ ref('raw_event') }}
where payload.review."id" is not null
)
order by all

