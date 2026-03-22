
select distinct on (id) *
from (
select distinct
    payload.comment."_links"."html"."href" AS "_links_html_href",
    payload.comment."_links"."pull_request"."href" AS "_links_pull_request_href",
    payload.comment."_links"."self"."href" AS "_links_self_href",
    payload.comment."body" AS "body",
    payload.comment."commit_id" AS "commit_id",
    payload.comment."created_at" AS "created_at",
    payload.comment."diff_hunk" AS "diff_hunk",
    payload.comment."html_url" AS "html_url",
    payload.comment."id" AS "id",
    payload.comment."in_reply_to_id" AS "in_reply_to_id",
    payload.comment."issue_url" AS "issue_url",
    payload.comment."line" AS "line",
    payload.comment."node_id" AS "node_id",
    payload.comment."original_commit_id" AS "original_commit_id",
    payload.comment."original_position" AS "original_position",
    payload.comment."path" AS "path",
    payload.comment."pin" AS "pin",
    payload.comment."position" AS "position",
    payload.comment."pull_request_review_id" AS "pull_request_review_id",
    payload.comment."pull_request_url" AS "pull_request_url",
    payload.comment."reactions"."+1" AS "reactions_+1",
    payload.comment."reactions"."-1" AS "reactions_-1",
    payload.comment."reactions"."confused" AS "reactions_confused",
    payload.comment."reactions"."eyes" AS "reactions_eyes",
    payload.comment."reactions"."heart" AS "reactions_heart",
    payload.comment."reactions"."hooray" AS "reactions_hooray",
    payload.comment."reactions"."laugh" AS "reactions_laugh",
    payload.comment."reactions"."rocket" AS "reactions_rocket",
    payload.comment."reactions"."total_count" AS "reactions_total_count",
    payload.comment."reactions"."url" AS "reactions_url",
    payload.comment."subject_type" AS "subject_type",
    payload.comment."updated_at" AS "updated_at",
    payload.comment."url" AS "url",
    payload.comment."user"."id" AS "user_id"
from {{ ref('raw_event') }}
where payload.comment."id" is not null
)
order by all

