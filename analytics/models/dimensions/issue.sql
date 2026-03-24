
{{ config(
    unique_key='id'
) }}

select distinct on (id) *
from (
select distinct
    payload.issue."active_lock_reason" AS "active_lock_reason",
    payload.issue."assignee"."id" AS "assignee_id",
    payload.issue."body" AS "body",
    payload.issue."closed_at" AS "closed_at",
    payload.issue."comments" AS "comments",
    payload.issue."comments_url" AS "comments_url",
    payload.issue."created_at" AS "created_at",
    payload.issue."draft" AS "draft",
    payload.issue."events_url" AS "events_url",
    payload.issue."html_url" AS "html_url",
    payload.issue."id" AS "id",
    payload.issue."issue_dependencies_summary"."blocked_by" AS "issue_dependencies_summary_blocked_by",
    payload.issue."issue_dependencies_summary"."blocking" AS "issue_dependencies_summary_blocking",
    payload.issue."issue_dependencies_summary"."total_blocked_by" AS "issue_dependencies_summary_total_blocked_by",
    payload.issue."issue_dependencies_summary"."total_blocking" AS "issue_dependencies_summary_total_blocking",
    payload.issue."labels_url" AS "labels_url",
    payload.issue."locked" AS "locked",
    payload.issue."milestone"."id" AS "milestone_id",
    payload.issue."node_id" AS "node_id",
    payload.issue."number" AS "number",
    payload.issue."parent_issue_url" AS "parent_issue_url",
    payload.issue."pinned_comment" AS "pinned_comment",
    payload.issue."pull_request"."diff_url" AS "pull_request_diff_url",
    payload.issue."pull_request"."html_url" AS "pull_request_html_url",
    payload.issue."pull_request"."merged_at" AS "pull_request_merged_at",
    payload.issue."pull_request"."patch_url" AS "pull_request_patch_url",
    payload.issue."pull_request"."url" AS "pull_request_url",
    payload.issue."repository_url" AS "repository_url",
    payload.issue."state" AS "state",
    payload.issue."state_reason" AS "state_reason",
    payload.issue."sub_issues_summary"."completed" AS "sub_issues_summary_completed",
    payload.issue."sub_issues_summary"."percent_completed" AS "sub_issues_summary_percent_completed",
    payload.issue."sub_issues_summary"."total" AS "sub_issues_summary_total",
    payload.issue."timeline_url" AS "timeline_url",
    payload.issue."title" AS "title",
    payload.issue."type"."id" AS "type_id",
    payload.issue."updated_at" AS "updated_at",
    payload.issue."url" AS "url",
    payload.issue."user"."id" AS "user_id"
from {{ ref('raw_event') }}
where payload.issue."id" is not null
)
order by all

