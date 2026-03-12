#!/usr/bin/env bash

set -e

SUBMODULE_DIR="workspace/src/flie_swarm_core"
BRANCH="main"

if [ ! -d "$SUBMODULE_DIR" ]; then
    echo "Error: Submodule directory $SUBMODULE_DIR not found."
    exit 1
fi

cd "$SUBMODULE_DIR"
git fetch origin
git checkout "$BRANCH"
git pull origin "$BRANCH"
cd - > /dev/null

git add "$SUBMODULE_DIR"

if git diff --cached --quiet; then
    echo "No new changes in $SUBMODULE_DIR."
    exit 0
fi

git commit -m "update flie_swarm_core pointer to latest $BRANCH"
echo "Successfully updated and committed $SUBMODULE_DIR pointer."
