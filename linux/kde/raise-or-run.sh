#!/bin/bash
# raise-or-run.sh <search_term> <launch_command>
# Raises the app if running, cycles through instances, or launches it.
# Usage: raise-or-run.sh neovide neovide

SEARCH="$1"
LAUNCH="$2"

# kdotool gets results back from a KWin script over D-Bus and occasionally
# exits before they arrive, printing nothing with exit 0 (~1 in 150 calls).
# Retry so a dropped result isn't mistaken for "no windows".
kdo_retry() {
    local out
    for _ in 1 2 3 4 5; do
        out=$(kdotool "$@")
        if [ -n "$out" ]; then
            echo "$out"
            return
        fi
        sleep 0.05
    done
}

ACTIVE=$(kdo_retry getactivewindow)
WINDOWS=$(kdo_retry search "$SEARCH")

if [ -z "$WINDOWS" ]; then
    # @im=none blocks legacy XIM discovery: wezterm 20240203 leaks X windows via
    # XIM/ibus-x11 even with use_ime=false, degrading the X server over hours.
    # GUI apps use ibus over D-Bus, not XIM, so input methods are unaffected.
    XMODIFIERS=@im=none $LAUNCH
    exit
fi

FIRST=$(head -n1 <<< "$WINDOWS")

# If active window isn't in the list, just focus the first one
if [ -z "$ACTIVE" ] || ! grep -qxF "$ACTIVE" <<< "$WINDOWS"; then
    kdotool windowactivate "$FIRST"
    exit
fi

# Active window is already a match — focus the next one
NEXT=false
while IFS= read -r win; do
    if [ "$NEXT" = true ]; then
        kdotool windowactivate "$win"
        exit
    fi
    [ "$win" = "$ACTIVE" ] && NEXT=true
done <<< "$WINDOWS"

# Wrapped around — go back to the first
kdotool windowactivate "$FIRST"
