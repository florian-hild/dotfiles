// GitHub PRs of Element-Logic: the viewer's open PRs and the PRs waiting for their review.
// fetch.sh does the querying; this mod only schedules it, caches the result and draws it.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, appHome, run, theme, shared, setShared } from "herdr";

const INTERVAL_MS = 300000;
const FRESH_S = 60;
const TABS = [
  { id: "mine", label: "Open" },
  { id: "review", label: "Review" },
];
const CACHE_KEY = "prs.cache";
const BUSY_TTL_S = 120;
// The flag holds the start time, so a fetch killed by a reload or crash cannot block refreshes for good.
const busyNow = () => {
  const since = shared("prs.busy");
  return typeof since === "number" && Date.now() / 1000 - since < BUSY_TTL_S;
};
const OPEN_KEY = "prs.groups.open";
const isBot = (pr) => /renovate|dependabot|\[bot\]$/i.test(pr.author ?? "");
// First match wins, across TOP_GROUPS and then BOTTOM_GROUPS, so "Assigned to me" beats every other
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
    try {
      const cached = localStorage.getItem(CACHE_KEY);
      if (cached && !shared("prs.data")) setShared("prs.data", JSON.parse(cached));
    } catch {}
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
      } catch (e) {
        setShared("prs.error", String(e.message ?? e));
      }
      setShared("prs.busy", false);
      cx.notify();
    });
  }

  ci(pr, t) {
    const color = { SUCCESS: t.done, FAILURE: t.blocked, ERROR: t.blocked, PENDING: t.working, EXPECTED: t.working }[pr.ci];
    return color ? div().size(7).rounded(4).flex_none().bg(color) : div().size(7).flex_none();
  }

  badge(text, color, t) {
    return div().px(5).rounded(4).text_size(10).flex_none().text_color(color).border(1).border_color(color).child(text);
  }

  row(pr, t, showRepo = true) {
    const status = [];
    if (pr.draft) status.push(this.badge("draft", t.dim, t));
    if (pr.decision === "APPROVED") status.push(this.badge("approved", t.done, t));
    if (pr.decision === "CHANGES_REQUESTED") status.push(this.badge("changes", t.blocked, t));
    return v_flex().id(`pr-${pr.repo}-${pr.number}`).px(10).py(6).gap(2)
      .hover((s) => s.bg(t.hover))
      .on_click(() => exec("open", [pr.url]))
      .child(h_flex().gap(6).items_start()
        .child(div().pt(5).child(this.ci(pr, t)))
        .child(div().flex_1().min_w(0).whitespace_normal().text_size(13).text_color(t.foreground).child(pr.title)))
      .child(h_flex().gap(6).items_center().pl(13)
        .child(div().flex_1().min_w(0).truncate().text_size(11).text_color(t.dim)
          .child(`${showRepo ? `${pr.repo} ` : ""}#${pr.number} · ${this.tab === "review" && !isBot(pr) ? `${pr.author} · ` : ""}${ago(pr.updated)}`))
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

  render(cx) {
    const t = theme();
    const data = shared("prs.data");
    const error = shared("prs.error");
    const busy = busyNow();
    const list = data?.[this.tab] ?? [];

    const tabs = h_flex().px(8).pt(8).pb(4).gap(4).items_center()
      .children(TABS.map((x) => {
        const n = data?.[x.id]?.length;
        const on = x.id === this.tab;
        return div().id(`tab-${x.id}`).px(8).py(3).rounded(6).text_size(12)
          .text_color(on ? t.foreground : t.muted).bg(on ? t.selected : "#00000000")
          .hover((s) => s.bg(on ? t.selected : t.hover))
          .on_click((_e, cx) => { this.tab = x.id; cx.notify(); })
          .child(n === undefined ? x.label : `${x.label} ${n}`);
      }))
      .child(div().flex_1())
      .child(div().id("refresh").px(6).py(3).rounded(6).text_size(11).text_color(t.dim)
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.refresh(cx, true))
        .child(busy ? "…" : "↻"));

    const body = !data
      ? div().p(12).text_size(12).text_color(t.muted).child(error ? `Error: ${error}` : "Loading…")
      : list.length === 0
        ? div().p(12).text_size(12).text_color(t.muted).child(this.tab === "review" ? "Nothing to review" : "No open PRs")
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
      .when(error && data, (el) => el.child(div().px(10).py(4).text_size(11).text_color(t.blocked).truncate().child(`Last refresh failed: ${error}`)));
  }
}
