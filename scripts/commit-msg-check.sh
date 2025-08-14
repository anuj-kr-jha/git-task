#!/bin/sh
#
# commit-msg hook
# Usage: placed in .git/hooks/commit-msg and made executable
#
# It enforce type, ticket, header length, and body for feat/fix/revert
#

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# Ensure Git passed the commit message file
[ -z "$1" ] && echo -e "${RED}❌ ERROR: No commit message file.${RESET}" && exit 1

commit_msg_file="$1"
commit_msg=$(cat "$commit_msg_file")

# Allowed commit types
types="feat|fix|docs|style|refactor|perf|test|chore|revert"

# Types that require a ticket ID
ticket_required_types="feat|fix"

# Types that require a body
body_required_types="feat|fix|revert"

# Extract first line (header)
header=$(echo "$commit_msg" | head -n 1)
commit_type=$(echo "$header" | cut -d':' -f1)

# Cheat sheet helper
print_cheatsheet() {
    echo -e "${YELLOW}📌 Commit Message Cheat Sheet:${RESET}"
    echo "Header format: <type>: [<ticket> - ]<message>"
    echo "Ticket required for: feat, fix"
    echo "Body required for: feat, fix, revert"
    echo "Revert commits must include 'This reverts commit <SHA>' in the body"
    echo ""
}

# 1️⃣ Valid type
if ! echo "$commit_type" | grep -Eq "^($types)$"; then
    echo -e "${RED}❌ Invalid commit type: $commit_type${RESET}"
    print_cheatsheet
    exit 1
fi

# 2️⃣ Ticket ID check for feat|fix
if [[ "$ticket_required_types" =~ (^|[|])$commit_type($|[|]) ]]; then
    if ! [[ "$header" =~ ^$commit_type:[[:space:]]+[A-Z]+-[0-9]+[[:space:]]+-[[:space:]]+.+ ]]; then
        echo -e "${RED}❌ Missing or invalid ticket ID for $commit_type${RESET}"
        print_cheatsheet
        exit 1
    fi
fi

# 3️⃣ Revert check (body must include SHA)
if [ "$commit_type" = "revert" ]; then
    if ! echo "$commit_msg" | grep -Eq "This reverts commit [0-9a-f]{7,40}"; then
        echo -e "${RED}❌ Revert commit missing SHA${RESET}"
        print_cheatsheet
        exit 1
    fi
fi

# 4️⃣ Body required for feat/fix/revert
if [[ "$body_required_types" =~ (^|[|])$commit_type($|[|]) ]]; then
    body=$(echo "$commit_msg" | tail -n +2 | sed '/^\s*$/d')
    if [ -z "$body" ]; then
        echo -e "${RED}❌ Body required for $commit_type commits${RESET}"
        print_cheatsheet
        exit 1
    fi
fi

# 5️⃣ Header length check
if [ ${#header} -gt 100 ]; then
    echo -e "${RED}❌ Commit header exceeds 100 chars${RESET}"
    print_cheatsheet
    exit 1
fi

echo -e "${GREEN}✅ Commit message format is valid.${RESET}"
exit 0
