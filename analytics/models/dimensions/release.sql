
{{ config(
    unique_key='id'
) }}

select distinct on (id) *
from (
select distinct
    payload.release."assets_url" AS "assets_url",
    payload.release."author"."id" AS "author_id",
    payload.release."body" AS "body",
    payload.release."created_at" AS "created_at",
    payload.release."draft" AS "draft",
    payload.release."html_url" AS "html_url",
    payload.release."id" AS "id",
    payload.release."immutable" AS "immutable",
    payload.release."is_short_description_html_truncated" AS "is_short_description_html_truncated",
    payload.release."mentions_count" AS "mentions_count",
    payload.release."name" AS "name",
    payload.release."node_id" AS "node_id",
    payload.release."prerelease" AS "prerelease",
    payload.release."published_at" AS "published_at",
    payload.release."short_description_html" AS "short_description_html",
    payload.release."tag_name" AS "tag_name",
    payload.release."tarball_url" AS "tarball_url",
    payload.release."target_commitish" AS "target_commitish",
    payload.release."updated_at" AS "updated_at",
    payload.release."upload_url" AS "upload_url",
    payload.release."url" AS "url",
    payload.release."zipball_url" AS "zipball_url"
from {{ ref('raw_event') }}
where payload.release."id" is not null
)
order by all

