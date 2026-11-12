#!/usr/bin/env bash
# Prints one JSON document with the viewer's open PRs, the PRs awaiting their review or assigned
# to them (Element-Logic only) and their unread GitHub notifications. Called by the prs mod; needs an
# authenticated `gh`.
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
  number title url isDraft mergeable mergeStateStatus createdAt updatedAt reviewDecision headRefOid
  author { login }
  assignees(first: 20) { nodes { login } }
  repository { name }
  commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
  latestReviews(first: 30) { nodes { state author { login } commit { oid } } }
  reviewThreads(first: 100) { nodes { isResolved } }
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

# Claude limits are written by ~/.claude/statusline.sh while Claude Code runs. Without the
# file (or with invalid JSON) `claude` stays null and the my-status footer shows nothing.
CLAUDE="$(cat "$HOME/.claude/state/rate-limits.json" 2>/dev/null || echo null)"
echo "$CLAUDE" | jq -e . >/dev/null 2>&1 || CLAUDE=null

# Appends one failure to the same log as the PR query, with the same cap.
log_failure() {
  mkdir -p "$LOGDIR"
  { date '+%F %T'; echo "$1"; cat "$ERR"; echo; } >>"$LOGDIR/errors.log"
  tail -c 20000 "$LOGDIR/errors.log" >"$LOGDIR/errors.log.tmp" && mv "$LOGDIR/errors.log.tmp" "$LOGDIR/errors.log"
}

# Unread notifications of all orgs for the Inbox tab. They are optional: a failure must not take down the
# PR lists, but it is logged and handed to the Inbox, so an empty list is not mistaken for "all read".
NOTES='[]'
NOTES_ERROR=null
if raw_notes="$(gh api 'notifications?per_page=50' 2>"$ERR")" && jq -e 'type == "array"' >/dev/null 2>&1 <<<"$raw_notes"; then
  NOTES="$(jq '[.[] | {
    id, repo: .repository.name, title: .subject.title, updated: .updated_at, reason, type: .subject.type,
    number: ((.subject.url // "") | capture("/(?<n>[0-9]+)$").n? // null | if . then tonumber else null end),
    url: ((.subject.url // "") | sub("api.github.com/repos/"; "github.com/") | sub("/pulls/"; "/pull/")
          | if startswith("https://github.com/") then . else "https://github.com/notifications" end)
  }]' <<<"$raw_notes")"
else
  NOTES_ERROR="$(printf '%s %s' "$(printf '%s' "$raw_notes" | head -c 120)" "$(tail -n1 "$ERR" | cut -c1-120)" | jq -Rs .)"
  log_failure "notifications request failed, stdout: $(printf '%s' "$raw_notes" | head -c 500)"
fi

# GitHub's notifications carry no PR or issue state, so look it up in one batched query. gh exits non-zero
# when a single alias cannot be resolved but still prints the rest, so judge by the body. Without states the
# rows just show no state badge; a failed lookup is only logged.
NSTATE='{}'
NQ="$(jq -r '[to_entries[] | select(.value.type == "PullRequest" or .value.type == "Issue") | select(.value.url | startswith("https://github.com/"))
  | "n\(.key): resource(url: \"\(.value.url)\") { ... on PullRequest { state isDraft } ... on Issue { state stateReason } }"] | join("\n")' <<<"$NOTES")"
if [ -n "$NQ" ]; then
  state_raw="$(gh api graphql -f query="query { $NQ }" 2>"$ERR" || true)"
  if jq -e '.data' >/dev/null 2>&1 <<<"$state_raw"; then
    NSTATE="$(jq -c '.data' <<<"$state_raw")"
  else
    log_failure "notification state lookup failed, stdout: $(printf '%s' "$state_raw" | head -c 500)"
  fi
fi
NOTES="$(jq -c --argjson st "$NSTATE" 'to_entries | map(.value + {state: (($st["n\(.key)"] // {}) | if .state == "OPEN" and .isDraft then "DRAFT" elif .stateReason == "NOT_PLANNED" then "NOT_PLANNED" else .state end)})' <<<"$NOTES")"

jq --arg login "$LOGIN" --argjson claude "$CLAUDE" --argjson notes "$NOTES" --argjson notesError "$NOTES_ERROR" '
  def pr: {
    number, title, url, draft: .isDraft, created: .createdAt, updated: .updatedAt,
    repo: .repository.name, author: .author.login, decision: .reviewDecision,
    ci: (.commits.nodes[0].commit.statusCheckRollup.state // null),
    mergeable, merge_state: .mergeStateStatus,
    unresolved: ([.reviewThreads.nodes[]? | select(.isResolved | not)] | length),
    assigned: any(.assignees.nodes[]?; .login == $login)
  };
  # A review of the current head commit by the viewer counts as "already reviewed".
  def reviewed: any(.latestReviews.nodes[]?; .author.login == $login and .commit.oid == .headRefOid);
  {
    login: $login,
    fetchedAt: (now | floor),
    claude: $claude,
    notes: $notes,
    notesError: $notesError,
    mine: [.data.mine.nodes[] | select(. != null) | pr],
    # Assigned PRs of other people join the review list even without a review request or after the
    # viewer reviewed them, so the "Assigned to me" group is complete. A PR in both searches counts once.
    review: (
      ([.data.review.nodes[] | select(. != null) | select(reviewed | not) | pr]
       + [.data.assigned.nodes[] | select(. != null) | select(.author.login != $login) | pr])
      | unique_by(.url) | sort_by(.updated) | reverse
    )
  }' <<<"$raw"
