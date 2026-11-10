// Status bar in the style of ~/.tmux.conf: space name, ZOOM flag, clock, user@host.
// The window list is the tabs-prs bar above. tmux's PFX and SYNC flags have no
// counterpart here (no prefix mode, no synchronized panes).

import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, exec } from "herdr";

// Nord palette, same values as the tmux.conf header.
const C = { bg0: "#2e3440", bg1: "#3b4252", bg2: "#434c5e", fg: "#d8dee9", blue: "#88c0d0", yel: "#ebcb8b", mag: "#b48ead", red: "#bf616a" };

const pad = (n) => String(n).padStart(2, "0");
// Same format as tmux's status-right: %d-%m-%Y %H:%M
const clock = (d) => `${pad(d.getDate())}-${pad(d.getMonth() + 1)}-${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}`;

export default class StatusTmux extends View {
  init(_props, cx) {
    this.userhost = "";
    // Local identity, fetched once. Spaces on another machine show its label instead.
    exec("sh", ["-c", 'printf "%s@%s" "$USER" "$(hostname -s)"'])
      .then((r) => { this.userhost = r.code === 0 ? r.stdout.trim() : "user@host n/a"; cx.notify(); })
      .catch(() => { this.userhost = "user@host n/a"; cx.notify(); });
    // The clock has minute resolution; 5 s matches tmux's status-interval.
    cx.timer.every(5000, (cx) => cx.notify());
  }

  render() {
    const space = spaces().find((s) => s.active);
    const tab = space?.tabs.find((c) => c.active);
    const needs = agents().filter((a) => a.status === "blocked").length;
    const who = space?.machine ?? this.userhost;
    const seg = (bg, fg, text, bold) => h_flex().h_full().px(10).flex_none().items_center().bg(bg).text_color(fg).when(Boolean(bold), (el) => el.font_bold()).child(text);

    return h_flex().size_full().items_center().bg(C.bg0).text_color(C.fg).text_size(12)
      .child(seg(C.blue, C.bg0, "λ", true))
      .child(seg(C.bg1, C.fg, space?.name ?? ""))
      .when(Boolean(tab?.zoomed), (el) => el.child(seg(C.bg0, C.mag, "ZOOM", true)))
      .when(needs > 0, (el) => el.child(seg(C.bg0, C.yel, `${needs} needs you`, true)))
      .child(div().flex_1())
      .child(seg(C.bg2, C.fg, clock(new Date())))
      .child(seg(C.blue, who.startsWith("root@") ? C.red : C.bg0, who, true));
  }
}
