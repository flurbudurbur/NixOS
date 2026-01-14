#!/usr/bin/env bash

# Get dunst status
is_paused=$(dunstctl is-paused)
count=$(dunstctl count waiting)

# Determine the status
if [ "$is_paused" = "true" ]; then
    if [ "$count" -gt 0 ]; then
        status="dnd-notification"
    else
        status="dnd-none"
    fi
else
    if [ "$count" -gt 0 ]; then
        status="notification"
    else
        status="none"
    fi
fi

# Output JSON for waybar
if [ "$count" -gt 0 ]; then
    echo "{\"text\":\"$count\",\"alt\":\"$status\",\"tooltip\":\"$count notification(s)\",\"class\":\"$status\"}"
else
    echo "{\"text\":\"\",\"alt\":\"$status\",\"tooltip\":\"No notifications\",\"class\":\"$status\"}"
fi
