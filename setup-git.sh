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
        msg_body="GitHub sync failed.

Branch:    $BRANCH
Time:      $TIMESTAMP

Error output:
$output"
        if command -v jq > /dev/null 2>&1; then
            payload=$(jq -n \
                --arg subject "[GitHub Sync] Push failed on branch '$BRANCH'" \
                --arg message "$msg_body" \
                '{"subject": $subject, "message": $message}')
        else
            payload=$(python3 -c \
                "import json,sys; print(json.dumps({'subject':sys.argv[1],'message':sys.argv[2]}))" \
                "[GitHub Sync] Push failed on branch '$BRANCH'" "$msg_body")
        fi
        alert_http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 -X POST "$FORMSPREE_ENDPOINT" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            --data "$payload" 2>/dev/null)
        case "$alert_http_code" in
            2*)
                ;;
            *)
                echo "[$TIMESTAMP] ALERT: Failed to deliver failure notification (HTTP $alert_http_code)" >> "$LOG_FILE"
                echo "[GitHub Sync] Failed to deliver failure notification (HTTP $alert_http_code)" >&2
                ;;
        esac
    fi
fi
exit 0
HOOK
chmod +x "$HOOK_FILE"
