
{{ config(
    unique_key='id'
) }}

select distinct on (id) *
from (
select distinct
    actor."avatar_url" AS "avatar_url",
    actor."display_login" AS "display_login",
    actor."gravatar_id" AS "gravatar_id",
    actor."id" AS "id",
    actor."login" AS "login",
    actor."url" AS "url"
from {{ ref('raw_event') }}
where actor."id" is not null
)
order by all

