// GitHub PRs of Element-Logic: the viewer's open PRs, the PRs waiting for their review and the unread
// GitHub notifications. fetch.sh does the querying; this mod only schedules it, caches the result and draws it.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, appHome, run, theme, shared, setShared } from "herdr";

const INTERVAL_MS = 300000;
const FRESH_S = 60;
const TABS = [
  { id: "mine", label: "Open" },
  { id: "review", label: "Review" },
  { id: "notes", label: "Inbox" },
];
const CACHE_KEY = "prs.cache";
// A fixed green for "ok": the theme's ansi2 is pastel and looks washed out next to the saturated red of t.blocked.
const OK = "#3fd068";
// GitHub's own purple for "merged"; the theme has no color for it.
const MERGED = "#a371f7";
const BUSY_TTL_S = 120;
// The flag holds the start time, so a fetch killed by a reload or crash cannot block refreshes for good.
const busyNow = () => {
  const since = shared("prs.busy");
  return typeof since === "number" && Date.now() / 1000 - since < BUSY_TTL_S;
};
const OPEN_KEY = "prs.groups.open";
const SECTIONS_KEY = "prs.sections.closed";
const NOTES_KEY = "prs.notes.closed";
const SEEN_KEY = "prs.seen";
const keyOf = (pr) => pr.id ?? `${pr.repo}#${pr.number}`;
// Anything that should count as "something changed" for an item.
const sigOf = (pr) => [pr.updated, pr.decision, pr.ci, pr.unresolved, pr.merge_state, pr.state, pr.draft].join("|");
// What a tab lists. Notifications of merged PRs are done: they stay unread on GitHub but are left out here,
// so the Inbox only shows threads that still need a look. Undefined while the data has no such list yet.
const itemsOf = (data, id) => data?.[id]?.filter((x) => id !== "notes" || x.state !== "MERGED");
const isBot = (pr) => /renovate|dependabot|\[bot\]$/i.test(pr.author ?? "");
// Review tab: first match wins, across TOP_GROUPS and then BOTTOM_GROUPS, so "Assigned to me" beats every other
// group. "Renovate" skips Terraform and Ansible repos, which keep their own bot PRs.
// Repo groups start open because they hold PRs people review; the bot leftovers start closed.
// Order on screen: TOP_GROUPS, PRs without a group, BOTTOM_GROUPS. `flat` lists rows with their repo.
const TOP_GROUPS = [
  { id: "assigned", label: "Assigned to me", match: (pr) => pr.assigned, open: true, flat: true },
];
const BOTTOM_GROUPS = [
  { id: "ansible", label: "Ansible", match: (pr) => /ansible/i.test(pr.repo), open: true },
  { id: "renovate", label: "Renovate", match: (pr) => isBot(pr) && !/terraform|ansible/i.test(pr.repo), open: false },
  { id: "terraform", label: "Terraform", match: (pr) => /terraform/i.test(pr.repo), open: true },
];
// Open tab: the viewer's own PRs by what they need from the viewer.
const SECTIONS = [
  { id: "ready", label: "Ready to merge" },
  { id: "action", label: "Needs action" },
  { id: "waiting", label: "Waiting for review or checks" },
  { id: "drafts", label: "Your drafts" },
];

const ago = (iso) => {
  const s = Math.max(0, (Date.now() - Date.parse(iso)) / 1000);
  if (s < 3600) return `${Math.max(1, Math.round(s / 60))}m`;
  if (s < 86400) return `${Math.round(s / 3600)}h`;
  return `${Math.round(s / 86400)}d`;
};

export default class Prs extends View {
  init(_props, cx) {
    this.tab = "review";
    this.groupsOpen = {};
    try { this.groupsOpen = JSON.parse(localStorage.getItem(OPEN_KEY) ?? "{}"); } catch {}
    this.closedSections = new Set();
    try { this.closedSections = new Set(JSON.parse(localStorage.getItem(SECTIONS_KEY) ?? "[]")); } catch {}
    this.closedNotes = new Set();
    try { this.closedNotes = new Set(JSON.parse(localStorage.getItem(NOTES_KEY) ?? "[]")); } catch {}
    this.seen = {};
    try { this.seen = JSON.parse(localStorage.getItem(SEEN_KEY) ?? "{}"); } catch {}
    try {
      const cached = localStorage.getItem(CACHE_KEY);
      if (cached && !shared("prs.data")) setShared("prs.data", JSON.parse(cached));
    } catch {}
    this.publishChanged(shared("prs.data"));
    cx.timer.every(INTERVAL_MS, (cx) => this.refresh(cx, false));
    this.refresh(cx, false);
  }

  // Both copies of the sidebar may run this: the shared flag keeps it to one fetch at a time.
  refresh(cx, force) {
    const data = shared("prs.data");
    const fresh = data && Date.now() / 1000 - data.fetchedAt < FRESH_S;
    if (busyNow() || (fresh && !force)) return;
    setShared("prs.busy", Date.now() / 1000);
    cx.spawn(async (cx) => {
      try {
        const r = await exec("bash", [`${appHome()}/mods/prs/fetch.sh`], { timeout: 90000 });
        if (r.code !== 0) throw new Error(r.stderr.trim().split("\n").pop() || `exit ${r.code}`);
        const parsed = JSON.parse(r.stdout);
        try { localStorage.setItem(CACHE_KEY, r.stdout); } catch {}
        setShared("prs.error", null);
        setShared("prs.data", parsed);
        this.publishChanged(parsed);
      } catch (e) {
        setShared("prs.error", String(e.message ?? e));
      }
      setShared("prs.busy", false);
      cx.notify();
    });
  }

  // Marks notification threads as read on GitHub and drops them from the list at once. A failed call is
  // shown in the footer, and the thread comes back with the next refresh.
  markRead(ids, cx) {
    const data = shared("prs.data");
    if (data) {
      const next = { ...data, notes: (data.notes ?? []).filter((n) => !ids.includes(n.id)) };
      setShared("prs.data", next);
      try { localStorage.setItem(CACHE_KEY, JSON.stringify(next)); } catch {}
    }
    setShared("prs.actionError", null);
    cx.notify();
    cx.spawn(async (cx) => {
      for (const id of ids) {
        try {
          const r = await exec("bash", ["-c", 'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"; exec gh "$@"', "gh", "api", "-X", "PATCH", `notifications/threads/${id}`], { timeout: 30000 });
          if (r.code !== 0) throw new Error(r.stderr.trim().split("\n").pop() || `exit ${r.code}`);
        } catch (e) {
          setShared("prs.actionError", `Could not mark as read: ${String(e.message ?? e)}`);
          cx.notify();
        }
      }
    });
  }

  // Several panel instances share the persisted state, so re-read it before reading or writing acknowledgements.
  loadSeen() {
    try { this.seen = JSON.parse(localStorage.getItem(SEEN_KEY) ?? "{}"); } catch {}
  }

  saveSeen() {
    try { localStorage.setItem(SEEN_KEY, JSON.stringify(this.seen)); } catch {}
  }

  markSeen(tabs, data) {
    this.loadSeen();
    for (const id of tabs) this.seen[id] = Object.fromEntries((itemsOf(data, id) ?? []).map((pr) => [keyOf(pr), sigOf(pr)]));
    this.saveSeen();
    this.publishChanged(data);
  }

  // Shared so other mods (e.g. the tab bar's PRs button) can show the indicator while the panel is collapsed.
  publishChanged(data) {
    const total = TABS.reduce((n, x) => n + this.changedCount(x.id, data), 0);
    if (shared("prs.changed") !== total) setShared("prs.changed", total);
  }

  isChanged(pr) {
    const seen = this.seen[this.tab];
    return Boolean(seen) && this.tab !== "notes" && seen[keyOf(pr)] !== sigOf(pr);
  }

  // Acknowledge a single item (clicked) without touching the rest of the tab.
  markSeenOne(pr) {
    this.loadSeen();
    if (!this.seen[this.tab]) return;
    this.seen[this.tab][keyOf(pr)] = sigOf(pr);
    this.saveSeen();
    this.publishChanged(shared("prs.data"));
  }

  // Items that are new or differ from what was last acknowledged; the first run only sets the baseline.
  changedCount(id, data) {
    const items = itemsOf(data, id);
    if (!items) return 0;
    if (!this.seen[id]) { this.markSeen([id], data); return 0; }
    return items.filter((pr) => this.seen[id][keyOf(pr)] !== sigOf(pr)).length;
  }

  ci(pr, t) {
    const color = { SUCCESS: OK, FAILURE: t.blocked, ERROR: t.blocked, PENDING: t.working, EXPECTED: t.working }[pr.ci];
    return color ? div().size(7).rounded(4).flex_none().bg(color) : div().size(7).flex_none();
  }

  badge(text, color, t) {
    return div().px(5).rounded(4).text_size(10).flex_none().text_color(color).border(1).border_color(color).child(text);
  }

  row(pr, t, showRepo = true) {
    const status = [];
    const ci = { SUCCESS: ["CI ok", OK], FAILURE: ["CI failed", t.blocked], ERROR: ["CI error", t.blocked], PENDING: ["CI running", t.working], EXPECTED: ["CI waiting", t.working] }[pr.ci];
    if (ci) status.push(this.badge(ci[0], ci[1], t));
    if (this.tab === "mine") {
      if (this.isReady(pr)) status.push(this.badge("ready to merge", OK, t));
      else if (pr.mergeable === "CONFLICTING") status.push(this.badge("conflicts", t.blocked, t));
      else if (pr.decision === "REVIEW_REQUIRED") status.push(this.badge("needs review", t.working, t));
    }
    // Notifications only: the state of the PR or issue behind the thread, and why GitHub sent it.
    const st = { MERGED: ["merged", MERGED], CLOSED: ["closed", t.blocked], OPEN: ["open", OK], DRAFT: ["draft", t.muted], NOT_PLANNED: ["not planned", t.muted] }[pr.state];
    if (st && pr.id) status.push(this.badge(st[0], st[1], t));
    if (pr.reason) status.push(this.badge(pr.reason.replace(/_/g, " "), t.muted, t));
    if (pr.unresolved > 0) status.push(this.badge(`${pr.unresolved} open`, t.blocked, t));
    if (pr.draft) status.push(this.badge("draft", t.muted, t));
    if (pr.decision === "APPROVED") status.push(this.badge("approved", OK, t));
    if (pr.decision === "CHANGES_REQUESTED") status.push(this.badge("changes", t.blocked, t));
    // A notification has its own id and gets the mark-as-read check where a PR has its CI dot.
    const lead = pr.id
      ? div().id(`read-${pr.id}`).px(4).rounded(4).text_size(12).text_color(t.muted).flex_none()
          .hover((s) => s.bg(t.hover).text_color(OK))
          .on_click((_e, cx) => { cx.stop_propagation(); this.markRead([pr.id], cx); })
          .child("✓")
      : div().pt(5).child(this.ci(pr, t));
    return v_flex().id(pr.id ? `note-${pr.id}` : `pr-${pr.repo}-${pr.number}`).px(10).py(6).gap(2)
      .hover((s) => s.bg(t.hover))
      .on_click((_e, cx) => { this.markSeenOne(pr); cx.notify(); exec("open", [pr.url]); })
      .child(h_flex().gap(6).items_start()
        .child(lead)
        .child(div().flex_1().min_w(0).whitespace_normal().text_size(13).text_color(t.foreground).child(pr.title))
        // At the end of the title, not in front of it: the second line is indented to the title past the CI dot.
        .when(this.isChanged(pr), (el) => el.child(div().text_size(12).text_color(t.working).flex_none().child("●"))))
      .child(h_flex().gap(6).items_center().pl(pr.id ? 0 : 13)
        .child(div().flex_1().min_w(0).truncate().text_size(11).text_color(t.dim)
          .child(`${showRepo ? `${pr.repo} ` : ""}${pr.number ? `#${pr.number} · ` : ""}${this.tab === "review" && !isBot(pr) ? `${pr.author} · ` : ""}${ago(pr.updated)}`))
        .children(status));
  }

  // A collapsible group, sub-grouped by repo once opened. People's PRs come before bot PRs per repo.
  group(g, prs, t) {
    const on = this.groupsOpen[g.id] ?? g.open;
    const byRepo = new Map();
    for (const pr of prs) byRepo.set(pr.repo, [...(byRepo.get(pr.repo) ?? []), pr]);
    return v_flex()
      .child(h_flex().id(`group-head-${g.id}`).px(10).py(6).gap(6).items_center()
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => {
          this.groupsOpen = { ...this.groupsOpen, [g.id]: !on };
          try { localStorage.setItem(OPEN_KEY, JSON.stringify(this.groupsOpen)); } catch {}
          cx.notify();
        })
        .child(div().w(10).text_size(10).text_color(t.dim).child(on ? "▾" : "▸"))
        .child(div().flex_1().text_size(12).font_semibold().text_color(t.muted).child(g.label))
        .child(div().text_size(11).text_color(t.dim).child(g.flat ? `${prs.length}` : `${prs.length} in ${byRepo.size} ${byRepo.size === 1 ? "repo" : "repos"}`)))
      .when(on && g.flat, (el) => el.children(prs.map((pr) => this.row(pr, t))))
      .when(on && !g.flat, (el) => el.children([...byRepo].map(([repo, list]) =>
        v_flex()
          .child(div().px(10).pl(26).pt(4).text_size(11).text_color(t.dim).truncate().child(repo))
          .children([...list].sort((a, b) => Number(isBot(a)) - Number(isBot(b))).map((pr) => this.row(pr, t, false))))));
  }

  isReady(pr) {
    return !pr.draft && pr.merge_state === "CLEAN" && !(pr.unresolved > 0) && pr.decision !== "REVIEW_REQUIRED" && pr.decision !== "CHANGES_REQUESTED";
  }

  // Own PRs by what they need from you: drafts, merge-ready, blocked-on-you, everything else.
  sectionOf(pr) {
    if (pr.draft) return "drafts";
    if (this.isReady(pr)) return "ready";
    if (pr.decision === "CHANGES_REQUESTED" || pr.mergeable === "CONFLICTING" || pr.ci === "FAILURE" || pr.ci === "ERROR" || pr.unresolved > 0) return "action";
    return "waiting";
  }

  sections(list, t) {
    return v_flex().children(SECTIONS.map((s) => {
      const items = list.filter((pr) => this.sectionOf(pr) === s.id);
      if (items.length === 0) return div();
      const open = !this.closedSections.has(s.id);
      return v_flex()
        .child(h_flex().id(`sec-${s.id}`).px(10).py(6).gap(6).items_center()
          .hover((s2) => s2.bg(t.hover))
          .on_click((_e, cx) => {
            if (open) this.closedSections.add(s.id); else this.closedSections.delete(s.id);
            try { localStorage.setItem(SECTIONS_KEY, JSON.stringify([...this.closedSections])); } catch {}
            cx.notify();
          })
          .child(div().w(10).text_size(10).text_color(t.dim).child(open ? "▾" : "▸"))
          .child(div().flex_1().min_w(0).truncate().text_size(12).font_semibold().text_color(t.muted).child(s.label))
          .child(div().text_size(11).text_color(t.dim).child(`${items.length}`)))
        .when(open, (e) => e.children(items.map((pr) => this.row(pr, t))));
    }));
  }

  // Inbox: unread notifications by repo; the check on a repo marks all its threads as read.
  notesGroup(list, t) {
    const byRepo = new Map();
    for (const n of list) byRepo.set(n.repo, [...(byRepo.get(n.repo) ?? []), n]);
    return v_flex().children([...byRepo].map(([repo, items]) => {
      const open = !this.closedNotes.has(repo);
      return v_flex()
        .child(h_flex().id(`notes-repo-${repo}`).px(10).py(6).gap(6).items_center()
          .hover((s) => s.bg(t.hover))
          .on_click((_e, cx) => {
            if (open) this.closedNotes.add(repo); else this.closedNotes.delete(repo);
            try { localStorage.setItem(NOTES_KEY, JSON.stringify([...this.closedNotes])); } catch {}
            cx.notify();
          })
          .child(div().w(10).text_size(10).text_color(t.dim).child(open ? "▾" : "▸"))
          .child(div().flex_1().min_w(0).truncate().text_size(12).font_semibold().text_color(t.muted).child(repo))
          .child(div().text_size(11).text_color(t.dim).child(`${items.length}`))
          .child(div().id(`readall-${repo}`).px(4).rounded(4).text_size(12).text_color(t.muted)
            .hover((s) => s.bg(t.hover).text_color(OK))
            .on_click((_e, cx) => { cx.stop_propagation(); this.markRead(items.map((n) => n.id), cx); })
            .child("✓")))
        .when(open, (e) => e.children(items.map((n) => this.row(n, t, false))));
    }));
  }

  render(cx) {
    const t = theme();
    const data = shared("prs.data");
    const error = shared("prs.error");
    const actionError = shared("prs.actionError");
    const busy = busyNow();
    this.loadSeen();
    const list = itemsOf(data, this.tab) ?? [];
    const hidden = this.tab === "notes" ? (data?.notes?.length ?? 0) - list.length : 0;

    const changes = Object.fromEntries(TABS.map((x) => [x.id, this.changedCount(x.id, data)]));
    const totalChanged = Object.values(changes).reduce((a, b) => a + b, 0);
    const tabs = h_flex().px(8).pt(8).pb(4).gap(4).items_center()
      .children(TABS.map((x) => {
        const n = itemsOf(data, x.id)?.length;
        const on = x.id === this.tab;
        return div().id(`tab-${x.id}`).px(8).py(3).rounded(6).text_size(12)
          .text_color(on ? t.foreground : t.muted).bg(on ? t.selected : "#00000000")
          .hover((s) => s.bg(on ? t.selected : t.hover))
          .on_click((_e, cx) => { this.tab = x.id; if (x.id === "notes") this.markSeen([x.id], data); cx.notify(); })
          .child(`${n === undefined ? x.label : `${x.label} ${n}`}${changes[x.id] > 0 ? " ●" : ""}`);
      }))
      .child(div().flex_1())
      .when(totalChanged > 0, (el) => el.child(div().id("changed").px(6).py(3).rounded(6).text_size(11).text_color(t.working)
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => { this.markSeen(TABS.map((x) => x.id), data); cx.notify(); })
        .child(`● ${totalChanged} changed`)))
      .child(div().id("refresh").px(6).py(3).rounded(6).text_size(11).text_color(t.dim)
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.refresh(cx, true))
        .child(busy ? "…" : "↻"));

    // The cache of an older version has no notes yet; the first fetch fills them in.
    const body = !data || (this.tab === "notes" && data.notes === undefined)
      ? div().p(12).text_size(12).text_color(t.muted).child(error && !data ? `Error: ${error}` : "Loading…")
      : list.length === 0
        ? this.tab === "notes" && data.notesError
          ? div().p(12).text_size(12).text_color(t.blocked).child(`Notifications unavailable: ${data.notesError}`)
          : div().p(12).text_size(12).text_color(t.muted).child({ review: "Nothing to review", notes: hidden > 0 ? `No open notifications · ${hidden} merged hidden` : "No unread notifications", mine: "No open PRs" }[this.tab])
        : this.tab === "notes"
          ? v_flex().child(this.notesGroup(list, t))
              .when(hidden > 0, (e) => e.child(div().px(10).py(6).text_size(11).text_color(t.dim).child(`${hidden} merged hidden`)))
        : this.tab === "mine" ? this.sections(list, t)
        : (() => {
            const groups = [...TOP_GROUPS, ...BOTTOM_GROUPS].map((g) => ({ g, prs: [] }));
            const loose = [];
            for (const pr of list) (groups.find(({ g }) => g.match(pr))?.prs ?? loose).push(pr);
            const draw = (which) => groups
              .filter(({ g, prs }) => which.includes(g) && prs.length > 0)
              .map(({ g, prs }) => this.group(g, prs, t));
            return v_flex().children(draw(TOP_GROUPS))
              .children(loose.map((pr) => this.row(pr, t)))
              .children(draw(BOTTOM_GROUPS));
          })();

    return v_flex().size_full().bg(t.chrome)
      .child(tabs)
      .child(v_flex().id("prs-list").flex_1().min_h(0).overflow_y_scrollbar().child(body))
      .when(error && data, (el) => el.child(div().px(10).py(4).text_size(11).text_color(t.blocked).truncate().child(`Last refresh failed: ${error}`)))
      .when(actionError, (el) => el.child(div().px(10).py(4).text_size(11).text_color(t.blocked).truncate().child(actionError)));
  }
}
