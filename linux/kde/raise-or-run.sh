#!/bin/bash
# raise-or-run.sh <search_term> <launch_command>
# Raises the app if running, cycles through instances, or launches it.
# Usage: raise-or-run.sh neovide neovide

SEARCH="$1"
LAUNCH="$2"

ACTIVE=$(kdotool getactivewindow)
WINDOWS=$(kdotool search "$SEARCH")

if [ -z "$WINDOWS" ]; then
    # @im=none blocks legacy XIM discovery: wezterm 20240203 leaks X windows via
    # XIM/ibus-x11 even with use_ime=false, degrading the X server over hours.
    # GUI apps use ibus over D-Bus, not XIM, so input methods are unaffected.
    XMODIFIERS=@im=none $LAUNCH
    exit
fi

# If active window isn't in the list, just focus the first one
if ! echo "$WINDOWS" | grep -q "$ACTIVE"; then
    kdotool search "$SEARCH" windowactivate %1
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
kdotool search "$SEARCH" windowactivate %1
