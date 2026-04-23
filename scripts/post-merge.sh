#!/bin/bash
set -e

sh setup-git.sh 2>/dev/null || true

LOG_FILE="$(git rev-parse --show-toplevel)/github-sync-status.log"
BRANCH=$(git symbolic-ref --short -q HEAD || echo "main")
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
if output=$(git push origin HEAD:"$BRANCH" 2>&1); then
    echo "[$TIMESTAMP] SUCCESS: pushed branch '$BRANCH' to GitHub" >> "$LOG_FILE"
else
    echo "[$TIMESTAMP] FAILED: push of branch '$BRANCH' to GitHub failed" >> "$LOG_FILE"
    echo "$output" >> "$LOG_FILE"
    echo "---" >> "$LOG_FILE"
    echo "[GitHub Sync] Push to GitHub failed:" >&2
    echo "$output" >&2

    if [ -n "$FORMSPREE_ENDPOINT" ]; then
        msg_body="GitHub sync failed.

Branch:    $BRANCH
Time:      $TIMESTAMP

Error output:
$output"
        payload=$(jq -n \
            --arg subject "[GitHub Sync] Push failed on branch '$BRANCH'" \
            --arg message "$msg_body" \
            '{"subject": $subject, "message": $message}')
        alert_http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$FORMSPREE_ENDPOINT" \
            -H "Content-Type: application/json" \
            --data "$payload" 2>&1)
        if [ "$alert_http_code" != "200" ]; then
            echo "[$TIMESTAMP] ALERT: Failed to deliver failure notification (HTTP $alert_http_code)" >> "$LOG_FILE"
            echo "[GitHub Sync] Failed to deliver failure notification (HTTP $alert_http_code)" >&2
        fi
    fi
fi
