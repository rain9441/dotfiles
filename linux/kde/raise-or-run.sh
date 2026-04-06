#!/bin/bash
# raise-or-run.sh <search_term> <launch_command>
# Raises the app if running, cycles through instances, or launches it.
# Usage: raise-or-run.sh neovide neovide

SEARCH="$1"
LAUNCH="$2"

ACTIVE=$(kdotool getactivewindow)
WINDOWS=$(kdotool search "$SEARCH")

if [ -z "$WINDOWS" ]; then
    $LAUNCH
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
