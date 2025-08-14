#!/bin/sh
# --- Cross-platform Modular Git Hooks Setup ---

# ========================
# Colors
# ========================
if [ -t 1 ]; then
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    RED="\033[0;31m"
    RESET="\033[0m"
else
    GREEN=""
    YELLOW=""
    RED=""
    RESET=""
fi

success() { echo -e "${GREEN}✅ $1${RESET}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${RESET}"; }
error()   { echo -e "${RED}❌ $1${RESET}"; }

# ========================
# Detect Windows
# ========================
detect_windows() {
    case "$(uname -s)" in
        MINGW*|CYGWIN*|MSYS*)
            warn "Detected Windows environment."
            git config core.autocrlf input
            ;;
    esac
}

# ========================
# Create hooks dir
# ========================
create_hooks_dir() {
    mkdir -p .githooks
    success "Hooks directory ready: .githooks"
}

# ========================
# Add hook function
# ========================
add_hook() {
    local hook_name="$1"
    local hook_func="$2"
    local hook_path=".githooks/$hook_name"

    if [ ! -f "$hook_path" ]; then
        $hook_func > "$hook_path"
        chmod +x "$hook_path"
        success "Created $hook_name hook."
    else
        success "$hook_name hook already exists."
    fi
}

# ========================
# Hook: commit-msg
# ========================
hook_commit_msg() {
    cat <<'EOF'
#!/bin/sh
RED="\033[0;31m"
GREEN="\033[0;32m"
RESET="\033[0m"

commit_msg_file="$1"
commit_msg=$(cat "$commit_msg_file")

types="feat|fix|docs|style|refactor|perf|test|chore|revert"
pattern="^($types): [A-Z]+-[0-9]+ - .+"

header=$(echo "$commit_msg" | head -n 1)
body=$(echo "$commit_msg" | tail -n +2 | sed '/^[[:space:]]*$/d')

if ! echo "$header" | grep -Eq "$pattern"; then
    echo -e "${RED}❌ Invalid commit message format.${RESET}"
    exit 1
fi

if [ ${#header} -gt 100 ]; then
    echo -e "${RED}❌ Commit header exceeds 100 characters.${RESET}"
    exit 1
fi

if echo "$header" | grep -Eq "^(feat|fix|refactor):"; then
    if [ -z "$body" ]; then
        echo -e "${RED}❌ Body required for feat, fix, refactor.${RESET}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Commit message format is valid.${RESET}"
EOF
}

# ========================
# Hook: pre-commit
# ========================
hook_pre_commit() {
    cat <<'EOF'
#!/bin/sh
echo "🔍 Running pre-commit checks..."
# Example: npm run lint || exit 1
echo "✅ Pre-commit checks passed."
EOF
}

# ========================
# Hook: pre-push
# ========================
hook_pre_push() {
    cat <<'EOF'
#!/bin/sh
echo "🚀 Running pre-push checks..."
# Example: npm test || exit 1
echo "✅ Pre-push checks passed."
EOF
}

# ========================
# Hook: prepare-commit-msg
# ========================
hook_prepare_commit_msg() {
    cat <<'EOF'
#!/bin/sh
branch_name=$(git rev-parse --abbrev-ref HEAD | sed 's/[\/&]/-/g')
msg_file="$1"

# Only add branch name if not already present
if ! grep -q "\[$branch_name\]" "$msg_file"; then
    # Detect OS for sed compatibility
    if sed --version >/dev/null 2>&1; then
        # GNU sed
        sed -i "1s/^/[$branch_name] /" "$msg_file"
    else
        # BSD/macOS sed
        sed -i '' "1s/^/[$branch_name] /" "$msg_file"
    fi
fi
EOF
}

# ========================
# Set hooks path
# ========================
set_hooks_path() {
    git config core.hooksPath .githooks
    success "Git core.hooksPath set to .githooks"
}

# ========================
# Main
# ========================
echo -e "${YELLOW}🔧 Setting up Git hooks...${RESET}"
detect_windows
create_hooks_dir
add_hook "commit-msg" hook_commit_msg
add_hook "pre-commit" hook_pre_commit
add_hook "pre-push" hook_pre_push
add_hook "prepare-commit-msg" hook_prepare_commit_msg
set_hooks_path
success "Git hooks setup complete!"
