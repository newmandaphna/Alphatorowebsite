#!/bin/bash
set -e

sh setup-git.sh 2>/dev/null || true

BRANCH=$(git symbolic-ref --short -q HEAD || echo "main")
if ! output=$(git push origin HEAD:"$BRANCH" 2>&1); then
    echo "[GitHub Sync] Push to GitHub failed:" >&2
    echo "$output" >&2
fi
