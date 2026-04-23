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

    REPO_ROOT="$(git rev-parse --show-toplevel)"
    python3 "$REPO_ROOT/scripts/send-failure-email.py" "$BRANCH" "$TIMESTAMP" "$output" 2>&1 || true
fi
