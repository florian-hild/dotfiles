// A pane's header, for layouts that frame their panes:
//   { "tab": "active", "pane": { "header": { "content": { "mod": "my-pane" } } } }
// Shows the program's icon (the app's program table), the agent's name or
// the terminal's title, the folder, and the agent's status; buttons split, zoom and close
// this pane. Props from the app: { pane, terminal }. Click: focus the pane.
// While an ssh client runs in the pane, its target replaces the name, as typed
// (user@host or host), so the pane says which system it is on.

import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, theme, home, hc, exec } from "herdr";

const SSH_POLL_MS = 2000;
// ssh options that take a value as the next word; same list as ~/.tmux/scripts/userhost.sh.
const SSH_VALUE_OPTIONS = new Set("bcDEeFIiJLlmOoPpQRSWw".split(""));

// One process table per tick for all headers, not one ps per pane.
let table = { at: 0, pending: null };
function processTable() {
  if (table.pending && Date.now() - table.at < SSH_POLL_MS - 500) return table.pending;
  table.at = Date.now();
  table.pending = exec("ps", ["-A", "-o", "pid=,ppid=,comm=,args="]).then((r) => {
    if (r.code !== 0) throw new Error(r.stderr.trim() || `ps exited ${r.code}`);
    const rows = new Map();
    const children = new Map();
    for (const line of r.stdout.split("\n")) {
      const m = line.match(/^\s*(\d+)\s+(\d+)\s+(\S+)\s*(.*)$/);
      if (!m) continue;
      rows.set(m[1], { comm: m[3], args: m[4] });
      children.set(m[2], [...(children.get(m[2]) ?? []), m[1]]);
    }
    return { rows, children };
  });
  return table.pending;
}

// The target of the first ssh client below `root`, as typed on its command line, or "".
function sshTarget({ rows, children }, root) {
  const queue = [String(root)];
  while (queue.length) {
    const pid = queue.shift();
    const row = rows.get(pid);
    if (row && row.comm.split("/").pop() === "ssh") {
      const words = row.args.split(/\s+/);
      for (let i = 1; i < words.length; i++) {
        const w = words[i];
        if (/^-[a-zA-Z]$/.test(w) && SSH_VALUE_OPTIONS.has(w[1])) { i++; continue; }
        if (w.startsWith("-")) continue;
        return w;
      }
    }
    queue.push(...(children.get(pid) ?? []));
  }
  return "";
}

function icon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
}

export default class Pane extends View {
  init(_props, cx) {
    this.hovered = false;
    this.pid = null;
    this.pidOf = null;
    this.target = "";
    this.targetOf = null;
    this.failed = false;
    this.polling = false;
    this.refresh(cx);
    cx.timer.every(SSH_POLL_MS, (cx) => this.refresh(cx));
  }

  // The pid is the terminal's shell and stays the same, so it is fetched once.
  // Terminals on another machine (address "machine/t7") have pids this computer
  // cannot look up; their header stays as it was.
  async refresh(cx) {
    const terminal = props()?.terminal;
    if (this.polling || !terminal || terminal.includes("/")) return;
    this.polling = true;
    try {
      if (this.pidOf !== terminal) {
        const got = await hc(["get", terminal, "--json"]);
        if (got.code !== 0) throw new Error(got.stderr.trim() || `hc get exited ${got.code}`);
        this.pid = JSON.parse(got.stdout).pid;
        this.pidOf = terminal;
      }
      this.target = sshTarget(await processTable(), this.pid);
      this.failed = false;
    } catch (_err) {
      // The plain header stays, marked, and the next tick tries again.
      this.target = "";
      this.failed = true;
    }
    this.targetOf = terminal;
    this.polling = false;
    cx.notify();
  }

  me() {
    return panes().find((p) => p.pane === props()?.pane);
  }

  button(t, id, icon, command, args) {
    return div()
      .id(id)
      .p(3)
      .rounded(4)
      .text_color(t.dim)
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .on_click((_e, cx) => {
        cx.stop_propagation();
        run(command, args);
      })
      .child(svg(`mods/my-pane/${icon}.svg`).size(14));
  }

  render(cx) {
    const t = theme();
    const p = this.me();
    if (!p) return div();
    // A just-focused terminal's header shows its own answer only, not the previous one's.
    const ssh = this.targetOf === p.terminal ? this.target : "";
    const name = ssh || ((p.program?.agent || p.program?.shell) && p.program.name) || p.title || p.program?.name || "shell";
    const pic = icon(p.program, 14, t.dim);
    const st = p.status;
    const pane = p.pane;
    return h_flex()
      .id(`pane-head-${pane}`)
      .size_full()
      .px(10)
      .gap(8)
      .items_center()
      .bg(t.background)
      .border_b(1)
      .border_color(t.border)
      .text_size(12)
      .on_hover((hovered, cx) => { this.hovered = hovered; cx.notify(); })
      .on_click(() => run("pane.focus", { pane }))
      .when(Boolean(pic), (el) => el.child(pic))
      .child(div().flex_none().truncate().max_w(260).font_medium().text_color(ssh ? t.accent : t.foreground).child(name))
      .when(this.failed, (el) => el.child(div().flex_none().text_color(t.blocked).child("ssh?")))
      .child(div().flex_1().truncate().text_color(t.dim).child(folder(p.cwd)))
      .when(st === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)))
      .when(st === "blocked", el => el.child(div().flex_none().px(6).h(18).flex().items_center().rounded(5).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).child("Needs you")))
      .when(st === "done", el => el.child(div().size(7).flex_none().rounded(4).bg(t.done)))
      .when(this.hovered, el => el
        .child(this.button(t, `ph-r-${pane}`, "split-right", "pane.split", { direction: "right", pane }))
        .child(this.button(t, `ph-d-${pane}`, "split-down", "pane.split", { direction: "down", pane }))
        .child(this.button(t, `ph-z-${pane}`, p.zoomed ? "unzoom" : "zoom", "pane.zoom", { pane }))
        .child(this.button(t, `ph-x-${pane}`, "close", "pane.close", { pane })));
  }
}
