#!/bin/bash
set -e

sh setup-git.sh 2>/dev/null || true

BRANCH=$(git rev-parse --abbrev-ref HEAD)
output=$(git push origin HEAD:"$BRANCH" 2>&1)
status=$?
if [ $status -ne 0 ]; then
    echo "[GitHub Sync] Push to GitHub failed:" >&2
    echo "$output" >&2
fi
