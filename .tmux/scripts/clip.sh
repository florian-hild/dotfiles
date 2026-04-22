#!/bin/sh
# Cross-platform clipboard helper for tmux copy-mode.
# Reads from stdin and copies to the system clipboard.

if command -v pbcopy >/dev/null 2>&1; then
    exec pbcopy
elif [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
    exec wl-copy
elif command -v xclip >/dev/null 2>&1; then
    exec xclip -selection clipboard -in
elif command -v xsel >/dev/null 2>&1; then
    exec xsel --clipboard --input
else
    # No clipboard tool available; just consume stdin so tmux doesn't block.
    cat >/dev/null
fi
