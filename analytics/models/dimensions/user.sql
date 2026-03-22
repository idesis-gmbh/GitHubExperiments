
select distinct on (id) *
from (
select distinct
    payload.assignee."avatar_url" AS "avatar_url",
    payload.assignee."events_url" AS "events_url",
    payload.assignee."followers_url" AS "followers_url",
    payload.assignee."following_url" AS "following_url",
    payload.assignee."gists_url" AS "gists_url",
    payload.assignee."gravatar_id" AS "gravatar_id",
    payload.assignee."html_url" AS "html_url",
    payload.assignee."id" AS "id",
    payload.assignee."login" AS "login",
    payload.assignee."node_id" AS "node_id",
    payload.assignee."organizations_url" AS "organizations_url",
    payload.assignee."received_events_url" AS "received_events_url",
    payload.assignee."repos_url" AS "repos_url",
    payload.assignee."site_admin" AS "site_admin",
    payload.assignee."starred_url" AS "starred_url",
    payload.assignee."subscriptions_url" AS "subscriptions_url",
    payload.assignee."type" AS "type",
    payload.assignee."url" AS "url",
    payload.assignee."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.assignee."id" is not null
union all
select distinct
    payload.comment.user."avatar_url" AS "avatar_url",
    payload.comment.user."events_url" AS "events_url",
    payload.comment.user."followers_url" AS "followers_url",
    payload.comment.user."following_url" AS "following_url",
    payload.comment.user."gists_url" AS "gists_url",
    payload.comment.user."gravatar_id" AS "gravatar_id",
    payload.comment.user."html_url" AS "html_url",
    payload.comment.user."id" AS "id",
    payload.comment.user."login" AS "login",
    payload.comment.user."node_id" AS "node_id",
    payload.comment.user."organizations_url" AS "organizations_url",
    payload.comment.user."received_events_url" AS "received_events_url",
    payload.comment.user."repos_url" AS "repos_url",
    payload.comment.user."site_admin" AS "site_admin",
    payload.comment.user."starred_url" AS "starred_url",
    payload.comment.user."subscriptions_url" AS "subscriptions_url",
    payload.comment.user."type" AS "type",
    payload.comment.user."url" AS "url",
    payload.comment.user."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.comment.user."id" is not null
union all
select distinct
    payload.discussion.user."avatar_url" AS "avatar_url",
    payload.discussion.user."events_url" AS "events_url",
    payload.discussion.user."followers_url" AS "followers_url",
    payload.discussion.user."following_url" AS "following_url",
    payload.discussion.user."gists_url" AS "gists_url",
    payload.discussion.user."gravatar_id" AS "gravatar_id",
    payload.discussion.user."html_url" AS "html_url",
    payload.discussion.user."id" AS "id",
    payload.discussion.user."login" AS "login",
    payload.discussion.user."node_id" AS "node_id",
    payload.discussion.user."organizations_url" AS "organizations_url",
    payload.discussion.user."received_events_url" AS "received_events_url",
    payload.discussion.user."repos_url" AS "repos_url",
    payload.discussion.user."site_admin" AS "site_admin",
    payload.discussion.user."starred_url" AS "starred_url",
    payload.discussion.user."subscriptions_url" AS "subscriptions_url",
    payload.discussion.user."type" AS "type",
    payload.discussion.user."url" AS "url",
    payload.discussion.user."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.discussion.user."id" is not null
union all
select distinct
    payload.forkee.owner."avatar_url" AS "avatar_url",
    payload.forkee.owner."events_url" AS "events_url",
    payload.forkee.owner."followers_url" AS "followers_url",
    payload.forkee.owner."following_url" AS "following_url",
    payload.forkee.owner."gists_url" AS "gists_url",
    payload.forkee.owner."gravatar_id" AS "gravatar_id",
    payload.forkee.owner."html_url" AS "html_url",
    payload.forkee.owner."id" AS "id",
    payload.forkee.owner."login" AS "login",
    payload.forkee.owner."node_id" AS "node_id",
    payload.forkee.owner."organizations_url" AS "organizations_url",
    payload.forkee.owner."received_events_url" AS "received_events_url",
    payload.forkee.owner."repos_url" AS "repos_url",
    payload.forkee.owner."site_admin" AS "site_admin",
    payload.forkee.owner."starred_url" AS "starred_url",
    payload.forkee.owner."subscriptions_url" AS "subscriptions_url",
    payload.forkee.owner."type" AS "type",
    payload.forkee.owner."url" AS "url",
    payload.forkee.owner."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.forkee.owner."id" is not null
union all
select distinct
    payload.issue.assignee."avatar_url" AS "avatar_url",
    payload.issue.assignee."events_url" AS "events_url",
    payload.issue.assignee."followers_url" AS "followers_url",
    payload.issue.assignee."following_url" AS "following_url",
    payload.issue.assignee."gists_url" AS "gists_url",
    payload.issue.assignee."gravatar_id" AS "gravatar_id",
    payload.issue.assignee."html_url" AS "html_url",
    payload.issue.assignee."id" AS "id",
    payload.issue.assignee."login" AS "login",
    payload.issue.assignee."node_id" AS "node_id",
    payload.issue.assignee."organizations_url" AS "organizations_url",
    payload.issue.assignee."received_events_url" AS "received_events_url",
    payload.issue.assignee."repos_url" AS "repos_url",
    payload.issue.assignee."site_admin" AS "site_admin",
    payload.issue.assignee."starred_url" AS "starred_url",
    payload.issue.assignee."subscriptions_url" AS "subscriptions_url",
    payload.issue.assignee."type" AS "type",
    payload.issue.assignee."url" AS "url",
    payload.issue.assignee."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.issue.assignee."id" is not null
union all
select distinct
    payload.issue.milestone.creator."avatar_url" AS "avatar_url",
    payload.issue.milestone.creator."events_url" AS "events_url",
    payload.issue.milestone.creator."followers_url" AS "followers_url",
    payload.issue.milestone.creator."following_url" AS "following_url",
    payload.issue.milestone.creator."gists_url" AS "gists_url",
    payload.issue.milestone.creator."gravatar_id" AS "gravatar_id",
    payload.issue.milestone.creator."html_url" AS "html_url",
    payload.issue.milestone.creator."id" AS "id",
    payload.issue.milestone.creator."login" AS "login",
    payload.issue.milestone.creator."node_id" AS "node_id",
    payload.issue.milestone.creator."organizations_url" AS "organizations_url",
    payload.issue.milestone.creator."received_events_url" AS "received_events_url",
    payload.issue.milestone.creator."repos_url" AS "repos_url",
    payload.issue.milestone.creator."site_admin" AS "site_admin",
    payload.issue.milestone.creator."starred_url" AS "starred_url",
    payload.issue.milestone.creator."subscriptions_url" AS "subscriptions_url",
    payload.issue.milestone.creator."type" AS "type",
    payload.issue.milestone.creator."url" AS "url",
    payload.issue.milestone.creator."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.issue.milestone.creator."id" is not null
union all
select distinct
    payload.issue.user."avatar_url" AS "avatar_url",
    payload.issue.user."events_url" AS "events_url",
    payload.issue.user."followers_url" AS "followers_url",
    payload.issue.user."following_url" AS "following_url",
    payload.issue.user."gists_url" AS "gists_url",
    payload.issue.user."gravatar_id" AS "gravatar_id",
    payload.issue.user."html_url" AS "html_url",
    payload.issue.user."id" AS "id",
    payload.issue.user."login" AS "login",
    payload.issue.user."node_id" AS "node_id",
    payload.issue.user."organizations_url" AS "organizations_url",
    payload.issue.user."received_events_url" AS "received_events_url",
    payload.issue.user."repos_url" AS "repos_url",
    payload.issue.user."site_admin" AS "site_admin",
    payload.issue.user."starred_url" AS "starred_url",
    payload.issue.user."subscriptions_url" AS "subscriptions_url",
    payload.issue.user."type" AS "type",
    payload.issue.user."url" AS "url",
    payload.issue.user."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.issue.user."id" is not null
union all
select distinct
    payload.member."avatar_url" AS "avatar_url",
    payload.member."events_url" AS "events_url",
    payload.member."followers_url" AS "followers_url",
    payload.member."following_url" AS "following_url",
    payload.member."gists_url" AS "gists_url",
    payload.member."gravatar_id" AS "gravatar_id",
    payload.member."html_url" AS "html_url",
    payload.member."id" AS "id",
    payload.member."login" AS "login",
    payload.member."node_id" AS "node_id",
    payload.member."organizations_url" AS "organizations_url",
    payload.member."received_events_url" AS "received_events_url",
    payload.member."repos_url" AS "repos_url",
    payload.member."site_admin" AS "site_admin",
    payload.member."starred_url" AS "starred_url",
    payload.member."subscriptions_url" AS "subscriptions_url",
    payload.member."type" AS "type",
    payload.member."url" AS "url",
    payload.member."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.member."id" is not null
union all
select distinct
    payload.release.author."avatar_url" AS "avatar_url",
    payload.release.author."events_url" AS "events_url",
    payload.release.author."followers_url" AS "followers_url",
    payload.release.author."following_url" AS "following_url",
    payload.release.author."gists_url" AS "gists_url",
    payload.release.author."gravatar_id" AS "gravatar_id",
    payload.release.author."html_url" AS "html_url",
    payload.release.author."id" AS "id",
    payload.release.author."login" AS "login",
    payload.release.author."node_id" AS "node_id",
    payload.release.author."organizations_url" AS "organizations_url",
    payload.release.author."received_events_url" AS "received_events_url",
    payload.release.author."repos_url" AS "repos_url",
    payload.release.author."site_admin" AS "site_admin",
    payload.release.author."starred_url" AS "starred_url",
    payload.release.author."subscriptions_url" AS "subscriptions_url",
    payload.release.author."type" AS "type",
    payload.release.author."url" AS "url",
    payload.release.author."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.release.author."id" is not null
union all
select distinct
    payload.review.user."avatar_url" AS "avatar_url",
    payload.review.user."events_url" AS "events_url",
    payload.review.user."followers_url" AS "followers_url",
    payload.review.user."following_url" AS "following_url",
    payload.review.user."gists_url" AS "gists_url",
    payload.review.user."gravatar_id" AS "gravatar_id",
    payload.review.user."html_url" AS "html_url",
    payload.review.user."id" AS "id",
    payload.review.user."login" AS "login",
    payload.review.user."node_id" AS "node_id",
    payload.review.user."organizations_url" AS "organizations_url",
    payload.review.user."received_events_url" AS "received_events_url",
    payload.review.user."repos_url" AS "repos_url",
    payload.review.user."site_admin" AS "site_admin",
    payload.review.user."starred_url" AS "starred_url",
    payload.review.user."subscriptions_url" AS "subscriptions_url",
    payload.review.user."type" AS "type",
    payload.review.user."url" AS "url",
    payload.review.user."user_view_type" AS "user_view_type"
from {{ ref('raw_event') }}
where payload.review.user."id" is not null
)
order by all

