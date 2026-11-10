#!/usr/bin/env bash
# Prints one JSON document with the viewer's open PRs and the PRs awaiting their review or
# assigned to them (Element-Logic only). Called by the prs mod; needs an authenticated `gh`.
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

ORG="${PRS_ORG:-Element-Logic}"
LOGIN="$(gh api user --jq .login)"

QUERY='
query($mine: String!, $review: String!, $assigned: String!) {
  mine: search(query: $mine, type: ISSUE, first: 50) { nodes { ...PR } }
  review: search(query: $review, type: ISSUE, first: 50) { nodes { ...PR } }
  assigned: search(query: $assigned, type: ISSUE, first: 50) { nodes { ...PR } }
}
fragment PR on PullRequest {
  number title url isDraft createdAt updatedAt reviewDecision headRefOid
  author { login }
  assignees(first: 20) { nodes { login } }
  repository { name }
  commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
  latestReviews(first: 30) { nodes { state author { login } commit { oid } } }
}'

gh api graphql \
  -f query="$QUERY" \
  -f mine="org:$ORG is:pr is:open archived:false author:$LOGIN sort:updated-desc" \
  -f review="org:$ORG is:pr is:open archived:false draft:false review-requested:$LOGIN sort:updated-desc" \
  -f assigned="org:$ORG is:pr is:open archived:false assignee:$LOGIN sort:updated-desc" \
| jq --arg login "$LOGIN" '
  def pr: {
    number, title, url, draft: .isDraft, created: .createdAt, updated: .updatedAt,
    repo: .repository.name, author: .author.login, decision: .reviewDecision,
    ci: (.commits.nodes[0].commit.statusCheckRollup.state // null),
    assigned: any(.assignees.nodes[]?; .login == $login)
  };
  # A review of the current head commit by the viewer counts as "already reviewed".
  def reviewed: any(.latestReviews.nodes[]?; .author.login == $login and .commit.oid == .headRefOid);
  {
    login: $login,
    fetchedAt: (now | floor),
    mine: [.data.mine.nodes[] | select(. != null) | pr],
    # Assigned PRs of other people join the review list even without a review request or after the
    # viewer reviewed them, so the "Assigned to me" group is complete. A PR in both searches counts once.
    review: (
      ([.data.review.nodes[] | select(. != null) | select(reviewed | not) | pr]
       + [.data.assigned.nodes[] | select(. != null) | select(.author.login != $login) | pr])
      | unique_by(.url) | sort_by(.updated) | reverse
    )
  }'
