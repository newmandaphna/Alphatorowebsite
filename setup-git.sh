#!/bin/sh
HELPER="$(pwd)/.git-credentials-helper.sh"
git config --local credential.helper "$HELPER"
git config --local credential.https://github.com.helper "$HELPER"

HOOK_FILE="$(git rev-parse --git-dir)/hooks/post-commit"
cat > "$HOOK_FILE" << 'HOOK'
#!/bin/sh
BRANCH=$(git rev-parse --abbrev-ref HEAD)
output=$(git push origin HEAD:"$BRANCH" 2>&1)
status=$?
if [ $status -ne 0 ]; then
    echo "[GitHub Sync] Push to GitHub failed:" >&2
    echo "$output" >&2
fi
exit 0
HOOK
chmod +x "$HOOK_FILE"
