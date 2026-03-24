
{{ config(
    unique_key='id'
) }}

select distinct
    "actor"."id" AS "actor_id",
    "created_at" AS "created_at",
    "id" AS "id",
    "org"."id" AS "org_id",
    "payload"."action" AS "payload_action",
    "payload"."assignee"."id" AS "payload_assignee_id",
    "payload"."before" AS "payload_before",
    "payload"."comment"."id" AS "payload_comment_id",
    "payload"."description" AS "payload_description",
    "payload"."discussion"."id" AS "payload_discussion_id",
    "payload"."forkee"."id" AS "payload_forkee_id",
    "payload"."full_ref" AS "payload_full_ref",
    "payload"."head" AS "payload_head",
    "payload"."issue"."id" AS "payload_issue_id",
    "payload"."label"."id" AS "payload_label_id",
    "payload"."master_branch" AS "payload_master_branch",
    "payload"."member"."id" AS "payload_member_id",
    "payload"."number" AS "payload_number",
    "payload"."pull_request"."id" AS "payload_pull_request_id",
    "payload"."push_id" AS "payload_push_id",
    "payload"."pusher_type" AS "payload_pusher_type",
    "payload"."ref" AS "payload_ref",
    "payload"."ref_type" AS "payload_ref_type",
    "payload"."release"."id" AS "payload_release_id",
    "payload"."repository_id" AS "payload_repository_id",
    "payload"."review"."id" AS "payload_review_id",
    "public" AS "public",
    "repo"."id" AS "repo_id",
    "type" AS "type"
from {{ ref('raw_event') }}

