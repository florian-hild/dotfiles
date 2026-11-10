// Right-click pastes, like tmux's `bind -n MouseDown3Pane paste-buffer`.
// The layout's terminal_menu points here, so the popup does its job on open
// and closes itself instead of showing a menu.

import { View, div } from "gpui-kit";
import { props, run, closeOverlay } from "herdr";

export default class PasteMenu extends View {
  init() {
    const { target, overlay } = props() ?? {};
    if (overlay) closeOverlay(overlay);
    // terminal.paste has no target argument and acts on the focused terminal,
    // so the clicked one gets the keyboard first.
    if (target?.terminal) run("pane.focus", { terminal: target.terminal });
    run("terminal.paste");
  }

  render() {
    return div();
  }
}
