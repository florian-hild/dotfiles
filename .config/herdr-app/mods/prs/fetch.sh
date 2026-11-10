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

LOGDIR="${XDG_CACHE_HOME:-$HOME/.cache}/herdr-prs"
ERR="$(mktemp)"
trap 'rm -f "$ERR"' EXIT

# gh prints the response body to stdout even for failed requests, and feeding that to jq only
# shows "jq: parse error", which hides what GitHub answered. Check the body first, retry
# transient failures and log every failed attempt to $LOGDIR/errors.log, even when a retry works.
ok=0
raw=""
for attempt in 1 2 3; do
  if raw="$(gh api graphql \
      -f query="$QUERY" \
      -f mine="org:$ORG is:pr is:open archived:false author:$LOGIN sort:updated-desc" \
      -f review="org:$ORG is:pr is:open archived:false draft:false review-requested:$LOGIN sort:updated-desc" \
      -f assigned="org:$ORG is:pr is:open archived:false assignee:$LOGIN sort:updated-desc" \
      2>"$ERR")" && jq -e '.data.mine' >/dev/null 2>&1 <<<"$raw"; then
    ok=1
    break
  fi
  mkdir -p "$LOGDIR"
  { date '+%F %T'; echo "attempt $attempt, stdout:"; printf '%s\n' "$raw" | head -c 2000; echo "stderr:"; cat "$ERR"; echo; } >>"$LOGDIR/errors.log"
  # Keep only the tail so a flaky network cannot grow the log without bound.
  tail -c 20000 "$LOGDIR/errors.log" >"$LOGDIR/errors.log.tmp" && mv "$LOGDIR/errors.log.tmp" "$LOGDIR/errors.log"
  sleep 2
done
if [ "$ok" != 1 ]; then
  echo "gh api graphql failed: $(printf '%s' "$raw" | head -n1 | cut -c1-120) $(tail -n1 "$ERR" | cut -c1-120)" >&2
  exit 1
fi

jq --arg login "$LOGIN" '
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
  }' <<<"$raw"
