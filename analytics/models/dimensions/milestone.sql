
select distinct on (id) *
from (
select distinct
    payload.issue.milestone."closed_at" AS "closed_at",
    payload.issue.milestone."closed_issues" AS "closed_issues",
    payload.issue.milestone."created_at" AS "created_at",
    payload.issue.milestone."creator"."id" AS "creator_id",
    payload.issue.milestone."description" AS "description",
    payload.issue.milestone."due_on" AS "due_on",
    payload.issue.milestone."html_url" AS "html_url",
    payload.issue.milestone."id" AS "id",
    payload.issue.milestone."labels_url" AS "labels_url",
    payload.issue.milestone."node_id" AS "node_id",
    payload.issue.milestone."number" AS "number",
    payload.issue.milestone."open_issues" AS "open_issues",
    payload.issue.milestone."state" AS "state",
    payload.issue.milestone."title" AS "title",
    payload.issue.milestone."updated_at" AS "updated_at",
    payload.issue.milestone."url" AS "url"
from {{ ref('raw_event') }}
where payload.issue.milestone."id" is not null
)
order by all

