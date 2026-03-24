
{{ config(
    unique_key='id'
) }}

select distinct on (id) *
from (
select distinct
    org."avatar_url" AS "avatar_url",
    org."gravatar_id" AS "gravatar_id",
    org."id" AS "id",
    org."login" AS "login",
    org."url" AS "url"
from {{ ref('raw_event') }}
where org."id" is not null
)
order by all

