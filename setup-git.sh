#!/bin/sh
HELPER="$(pwd)/.git-credentials-helper.sh"
git config --local credential.helper "$HELPER"
git config --local credential.https://github.com.helper "$HELPER"
