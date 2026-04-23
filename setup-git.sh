#!/bin/sh
HELPER="$(pwd)/.git-credentials-helper.sh"
git config --local credential.helper "$HELPER"
git config --local credential.https://github.com.helper "$HELPER"

HOOK_FILE="$(git rev-parse --git-dir)/hooks/post-commit"
cat > "$HOOK_FILE" << 'HOOK'
#!/bin/sh
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
        curl -s -X POST "$FORMSPREE_ENDPOINT" \
            -H "Content-Type: application/json" \
            --data "{\"subject\":\"[GitHub Sync] Push failed on branch '$BRANCH'\",\"message\":\"GitHub sync failed.\n\nBranch: $BRANCH\nTime: $TIMESTAMP\n\nError output:\n$output\"}" \
            > /dev/null 2>&1 || true
    fi
fi
exit 0
HOOK
chmod +x "$HOOK_FILE"
