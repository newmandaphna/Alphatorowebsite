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

    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        SLACK_MESSAGE="GitHub sync failed for branch \`$BRANCH\` at $TIMESTAMP.\n\`\`\`$output\`\`\`"
        curl -s -X POST "$SLACK_WEBHOOK_URL" \
            -H 'Content-type: application/json' \
            --data "{\"text\":\"$SLACK_MESSAGE\"}" \
            > /dev/null 2>&1 || true
    fi
fi
