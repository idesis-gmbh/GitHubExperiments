
select distinct on (id) *
from (
select distinct
    payload.pull_request."base"."ref" AS "base_ref",
    payload.pull_request."base"."repo"."id" AS "base_repo_id",
    payload.pull_request."base"."sha" AS "base_sha",
    payload.pull_request."head"."ref" AS "head_ref",
    payload.pull_request."head"."repo"."id" AS "head_repo_id",
    payload.pull_request."head"."sha" AS "head_sha",
    payload.pull_request."id" AS "id",
    payload.pull_request."number" AS "number",
    payload.pull_request."url" AS "url"
from {{ ref('raw_event') }}
where payload.pull_request."id" is not null
)
order by all

