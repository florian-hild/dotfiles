import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, theme, run, window, keys, shared, hc, focused, nextCommand } from "herdr";

// Same mapping as tmux.conf: v = side by side, h = stacked.
const SPLITS = { v: "right", h: "down" };
// Without a timeout a forgotten prefix would leave typing stuck in the footer.
const PREFIX_TIMEOUT_MS = 5000;

export default class WorkspaceStatus extends View {
  // Prefix mode, because keys.json has no chords: ctrl-a is bound to
  // "my-status.arm", this always-shown copy takes the keyboard for one key and
  // then runs the matching split, like `bind v` / `bind h` in tmux.conf.
  init(_props, cx) {
    this.armed = false;
    this.pane = null;
    this.timeout = null;
    this.handle = cx.focus_handle();
    cx.spawn(async (cx) => {
      for (;;) {
        // Either "arm" or the full "my-status.arm", depending on how the host hands it over.
        const command = String(await nextCommand()).split(".").pop();
        if (command === "arm") this.arm(cx);
        cx.notify();
      }
    });
  }

  arm(cx) {
    const f = focused();
    if (this.armed) {
      // Prefix twice sends the key itself, like tmux's send-prefix.
      this.disarm();
      if (f?.terminal) hc(["keys", f.terminal, "ctrl+a"]);
      return;
    }
    // Without a model pane (a mod or a layout terminal block) there is nothing to split.
    if (!f?.pane) return;
    this.armed = true;
    this.pane = f.pane;
    this.handle.focus();
    this.timeout = cx.timer.after(PREFIX_TIMEOUT_MS, (cx) => { this.disarm(); cx.notify(); });
  }

  // Gives the keyboard back to the pane it was taken from.
  disarm() {
    if (!this.armed) return;
    this.armed = false;
    this.timeout?.cancel();
    this.timeout = null;
    run("pane.focus", { pane: this.pane });
  }

  key(e, cx) {
    if (!this.armed) return;
    const pane = this.pane;
    this.disarm();
    const direction = SPLITS[e.key];
    if (direction && !e.modifiers.control && !e.modifiers.alt) run("pane.split", { direction, pane });
    // Escape and any other key just end the prefix; none of them reach the program.
    cx.stop_propagation();
    cx.notify();
  }

  // The palette key as actually bound, not a hardcoded one; without a
  // binding the hint stays useful ("commands") instead of lying.
  hint(t) {
    const mac = window()?.platform === "macos";
    const mod = { cmd: mac ? "⌘" : "Ctrl+", ctrl: mac ? "⌃" : "Ctrl+", shift: mac ? "⇧" : "Shift+", alt: mac ? "⌥" : "Alt+", option: mac ? "⌥" : "Alt+" };
    const b = keys().find((k) => k.section === "global" && k.action === "app.palette");
    const parts = b && b.keys.endsWith("--") ? [...b.keys.slice(0, -2).split("-"), "-"] : b?.keys.split("-");
    const key = parts && parts.map((p) => mod[p.toLowerCase()] ?? p.toUpperCase()).join("");
    return key ? `${key}  commands` : "commands";
  }

  budgets() {
    const d = shared("prs.data");
    const out = [];
    const c = d?.claude;
    const pct = (x) => (typeof x?.used_percentage === "number" ? `${Math.round(x.used_percentage)}%` : null);
    const parts = [pct(c?.five_hour) && `5h ${pct(c.five_hour)}`, pct(c?.seven_day) && `7d ${pct(c.seven_day)}`].filter(Boolean);
    if (parts.length) out.push(`Claude ${parts.join(" · ")}`);
    return out;
  }

  render() {
    const t = theme();
    const space = spaces().find(s => s.active);
    const list = agents();
    const needs = list.filter(a => a.status === "blocked").length;
    const label = (icon, text) => h_flex().gap(6).items_center().child(svg(`mods/workspace-chrome/${icon}.svg`).size(13)).child(text);
    return h_flex().size_full().px(14).gap(16).items_center().bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted)
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .when(this.armed, el => el.child(div().font_bold().text_color(t.accent).child("PFX")))
      .child(label(space?.machine ? "server" : "monitor", space?.machine ?? "This computer"))
      .when(Boolean(space?.branch), el => el.child(label("branch", space.branch)))
      .child(h_flex().gap(6).items_center().child(div().size(6).rounded(3).bg(t.dim)).child(`${list.length} agents`)
        .when(needs > 0, el => el.child(div().text_color(t.blocked).child(`· ${needs} needs you`))))
      .children(this.budgets().map((x) => div().child(x)))
      .child(div().flex_1())
      .child(div().id("palette").text_color(t.dim).on_click(() => run("app.palette")).child(this.hint(t)));
  }
}
