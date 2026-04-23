#!/bin/bash
set -e

sh setup-git.sh 2>/dev/null || true

git push origin HEAD:main --quiet 2>&1 || true
