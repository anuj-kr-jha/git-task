#!/bin/sh
RED="\033[0;31m"
GREEN="\033[0;32m"
RESET="\033[0m"

# Get commit message (for pre-commit, use $HUSKY_GIT_PARAMS or HEAD)
commit_msg=$(git log -1 --pretty=%B)

types="feat|fix|docs|style|refactor|perf|test|chore|revert"
pattern="^($types): [A-Z]+-[0-9]+ - .+"

if ! echo "$commit_msg" | grep -Eq "$pattern"; then
    echo -e "${RED}❌ Invalid commit message format.${RESET}"
    echo -e "${RED}Expected: <type>: <TICKET-ID> - <short description>${RESET}"
    exit 1
fi

echo -e "${GREEN}✅ Commit message format is valid.${RESET}"
