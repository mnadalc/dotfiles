#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# Test suite for newticket and clearticket
# Run: bash shell/__tests__/test-worktree-scripts.sh
# ══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

PASS=0
FAIL=0

# ── Temp directory (cleaned up on exit) ──────────────────────────────────────
TEST_TMPDIR=$(mktemp -d)
trap 'rm -rf "$TEST_TMPDIR"' EXIT

# ── Assertion helpers ─────────────────────────────────────────────────────────

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    ((PASS++))
    printf "  ${GREEN}PASS${NC}: %s\n" "$desc"
  else
    ((FAIL++))
    printf "  ${RED}FAIL${NC}: %s\n" "$desc"
    printf "       expected: %s\n" "$expected"
    printf "       actual:   %s\n" "$actual"
  fi
}

assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    ((PASS++))
    printf "  ${GREEN}PASS${NC}: %s\n" "$desc"
  else
    ((FAIL++))
    printf "  ${RED}FAIL${NC}: %s\n" "$desc"
    printf "       expected to contain: %s\n" "$needle"
    printf "       output was: %s\n" "$haystack" | head -5
  fi
}

assert_not_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if [[ "$haystack" != *"$needle"* ]]; then
    ((PASS++))
    printf "  ${GREEN}PASS${NC}: %s\n" "$desc"
  else
    ((FAIL++))
    printf "  ${RED}FAIL${NC}: %s\n" "$desc"
    printf "       should NOT contain: %s\n" "$needle"
  fi
}

assert_dir_exists() {
  local desc="$1" dir="$2"
  if [ -d "$dir" ]; then
    ((PASS++))
    printf "  ${GREEN}PASS${NC}: %s\n" "$desc"
  else
    ((FAIL++))
    printf "  ${RED}FAIL${NC}: %s\n" "$desc"
    printf "       directory not found: %s\n" "$dir"
  fi
}

assert_dir_not_exists() {
  local desc="$1" dir="$2"
  if [ ! -d "$dir" ]; then
    ((PASS++))
    printf "  ${GREEN}PASS${NC}: %s\n" "$desc"
  else
    ((FAIL++))
    printf "  ${RED}FAIL${NC}: %s\n" "$desc"
    printf "       directory should not exist: %s\n" "$dir"
  fi
}

assert_file_contains() {
  local desc="$1" file="$2" pattern="$3"
  if grep -qF "$pattern" "$file" 2>/dev/null; then
    ((PASS++))
    printf "  ${GREEN}PASS${NC}: %s\n" "$desc"
  else
    ((FAIL++))
    printf "  ${RED}FAIL${NC}: %s\n" "$desc"
    printf "       '%s' not found in %s\n" "$pattern" "$file"
  fi
}

# ── Mock binaries ─────────────────────────────────────────────────────────────

mkdir -p "$TEST_TMPDIR/bin"
for cmd in claude pnpm yarn bun npm; do
  printf '#!/bin/bash\necho "mock-%s $*"\n' "$cmd" > "$TEST_TMPDIR/bin/$cmd"
  chmod +x "$TEST_TMPDIR/bin/$cmd"
done
export PATH="$TEST_TMPDIR/bin:$PATH"

# ── Source dependencies and scripts under test ────────────────────────────────

source "$DOTFILES_DIR/osx/utils.sh"
source "$DOTFILES_DIR/shell/newticket.sh"
source "$DOTFILES_DIR/shell/clearticket.sh"

# Override interactive helpers — always answer yes
ask_for_confirmation() { REPLY="y"; }
answer_is_yes() { return 0; }

# ── Helper: create a test repo with a local bare origin ──────────────────────

create_test_repo() {
  local name="$1"
  local origin="$TEST_TMPDIR/${name}-origin.git"
  local clone="$TEST_TMPDIR/${name}"

  git init --bare -b main "$origin" >/dev/null 2>&1
  git clone "$origin" "$clone" >/dev/null 2>&1
  git -C "$clone" config user.email "test@test.com"
  git -C "$clone" config user.name "Test"
  git -C "$clone" commit --allow-empty -m "initial" >/dev/null 2>&1
  git -C "$clone" push origin main >/dev/null 2>&1

  printf '%s' "$(cd "$clone" && pwd -P)"
}

# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo "=== REPO_ROOT resolution ==="
# ══════════════════════════════════════════════════════════════════════════════

repo=$(create_test_repo "t-root")

cd "$repo"
root=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
assert_eq "resolves correctly from main repo" "$repo" "$root"

mkdir -p "$repo/.claude/worktrees"
git -C "$repo" worktree add "$repo/.claude/worktrees/wt-root-test" -b wt-root-test >/dev/null 2>&1
cd "$repo/.claude/worktrees/wt-root-test"
root=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
assert_eq "resolves to main repo root from inside worktree" "$repo" "$root"

# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo "=== newticket ==="
# ══════════════════════════════════════════════════════════════════════════════

# ── fails outside a git repo ─────────────────────────────────────────────────
mkdir -p "$TEST_TMPDIR/no-git-dir"
cd "$TEST_TMPDIR/no-git-dir"
output=$(newticket "should-fail" 2>&1) || true
assert_contains "fails outside a git repo" "Not inside a git repository" "$output"

# ── creates worktree for new branch ──────────────────────────────────────────
repo=$(create_test_repo "t-nt-create")
cd "$repo"
output=$(newticket "test-create" 2>&1) || true
assert_dir_exists "creates worktree directory" "$repo/.claude/worktrees/test-create"

# ── adds .gitignore entry ────────────────────────────────────────────────────
assert_file_contains "adds .claude/worktrees/ to .gitignore" "$repo/.gitignore" ".claude/worktrees/"

# ── creates worktree from inside another worktree (REPO_ROOT fix) ────────────
repo=$(create_test_repo "t-nt-crosswt")
cd "$repo"
mkdir -p "$repo/.claude/worktrees"
git worktree add "$repo/.claude/worktrees/wt-existing" -b wt-existing >/dev/null 2>&1
cd "$repo/.claude/worktrees/wt-existing"
output=$(newticket "wt-from-inside" 2>&1) || true
assert_dir_exists "creates at repo root when called from inside another worktree" "$repo/.claude/worktrees/wt-from-inside"
assert_dir_not_exists "does NOT nest under current worktree" "$repo/.claude/worktrees/wt-existing/.claude/worktrees/wt-from-inside"

# ── detects existing worktree ────────────────────────────────────────────────
repo=$(create_test_repo "t-nt-dup")
cd "$repo"
output=$(newticket "test-dup" 2>&1) || true
cd "$repo"
output=$(newticket "test-dup" 2>&1) || true
assert_contains "detects existing worktree" "already exists" "$output"
assert_contains "suggests clearticket" "clearticket" "$output"

# ── handles branch names with slashes ────────────────────────────────────────
repo=$(create_test_repo "t-nt-slash")
cd "$repo"
output=$(newticket "feat/LIN-123-auth" 2>&1) || true
assert_dir_exists "handles branch names with slashes" "$repo/.claude/worktrees/feat/LIN-123-auth"

# ── detects pnpm ─────────────────────────────────────────────────────────────
repo=$(create_test_repo "t-nt-pnpm")
echo '{}' > "$repo/package.json"
touch "$repo/pnpm-lock.yaml"
git -C "$repo" add -A >/dev/null 2>&1
git -C "$repo" commit -m "add pnpm" >/dev/null 2>&1
git -C "$repo" push origin main >/dev/null 2>&1
cd "$repo"
output=$(newticket "test-pnpm" 2>&1) || true
assert_contains "detects pnpm from lockfile" "pnpm install" "$output"

# ── detects yarn ─────────────────────────────────────────────────────────────
repo=$(create_test_repo "t-nt-yarn")
echo '{}' > "$repo/package.json"
touch "$repo/yarn.lock"
git -C "$repo" add -A >/dev/null 2>&1
git -C "$repo" commit -m "add yarn" >/dev/null 2>&1
git -C "$repo" push origin main >/dev/null 2>&1
cd "$repo"
output=$(newticket "test-yarn" 2>&1) || true
assert_contains "detects yarn from lockfile" "yarn install" "$output"

# ── detects bun ──────────────────────────────────────────────────────────────
repo=$(create_test_repo "t-nt-bun")
echo '{}' > "$repo/package.json"
touch "$repo/bun.lockb"
git -C "$repo" add -A >/dev/null 2>&1
git -C "$repo" commit -m "add bun" >/dev/null 2>&1
git -C "$repo" push origin main >/dev/null 2>&1
cd "$repo"
output=$(newticket "test-bun" 2>&1) || true
assert_contains "detects bun from lockfile" "bun install" "$output"

# ── detects npm from package-lock.json ───────────────────────────────────────
repo=$(create_test_repo "t-nt-npm")
echo '{}' > "$repo/package.json"
echo '{}' > "$repo/package-lock.json"
git -C "$repo" add -A >/dev/null 2>&1
git -C "$repo" commit -m "add npm" >/dev/null 2>&1
git -C "$repo" push origin main >/dev/null 2>&1
cd "$repo"
output=$(newticket "test-npm" 2>&1) || true
assert_contains "detects npm from package-lock.json" "npm install" "$output"

# ── skips install when no package.json ───────────────────────────────────────
repo=$(create_test_repo "t-nt-nopkg")
cd "$repo"
output=$(newticket "test-nopkg" 2>&1) || true
assert_contains "skips install when no package.json" "No package.json found" "$output"

# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo "=== clearticket ==="
# ══════════════════════════════════════════════════════════════════════════════

# ── removes worktree and deletes branch ──────────────────────────────────────
repo=$(create_test_repo "t-ct-remove")
cd "$repo"
output=$(newticket "test-remove" 2>&1) || true
cd "$repo"
output=$(clearticket "test-remove" 2>&1) || true
assert_dir_not_exists "removes worktree directory" "$repo/.claude/worktrees/test-remove"
assert_contains "confirms worktree cleared" "cleared" "$output"
# Verify branch is gone
branch_exists=0
git -C "$repo" show-ref --verify --quiet "refs/heads/test-remove" 2>/dev/null || branch_exists=1
assert_eq "deletes the branch" "1" "$branch_exists"

# ── guards against running from exact worktree directory ─────────────────────
repo=$(create_test_repo "t-ct-inside")
cd "$repo"
mkdir -p "$repo/.claude/worktrees"
git worktree add "$repo/.claude/worktrees/inside-test" -b inside-test >/dev/null 2>&1
cd "$repo/.claude/worktrees/inside-test"
output=$(clearticket "inside-test" 2>&1) || true
assert_contains "guards against exact worktree match" "inside the worktree" "$output"

# ── guards against running from subdirectory of target worktree ──────────────
repo=$(create_test_repo "t-ct-subdir")
cd "$repo"
mkdir -p "$repo/.claude/worktrees"
git worktree add "$repo/.claude/worktrees/subdir-test" -b subdir-test >/dev/null 2>&1
mkdir -p "$repo/.claude/worktrees/subdir-test/deep/nested"
cd "$repo/.claude/worktrees/subdir-test/deep/nested"
output=$(clearticket "subdir-test" 2>&1) || true
assert_contains "guards against subdirectory match" "inside the worktree" "$output"

# ── no false positive on similar branch prefix ───────────────────────────────
repo=$(create_test_repo "t-ct-prefix")
cd "$repo"
mkdir -p "$repo/.claude/worktrees"
git worktree add "$repo/.claude/worktrees/feat" -b feat >/dev/null 2>&1
git worktree add "$repo/.claude/worktrees/feat-bar" -b feat-bar >/dev/null 2>&1
cd "$repo/.claude/worktrees/feat-bar"
output=$(clearticket "feat" 2>&1) || true
assert_not_contains "no false positive on similar branch prefix" "inside the worktree" "$output"

# ── handles already-gone worktree directory ──────────────────────────────────
repo=$(create_test_repo "t-ct-gone")
cd "$repo"
mkdir -p "$repo/.claude/worktrees"
git worktree add "$repo/.claude/worktrees/gone-branch" -b gone-branch >/dev/null 2>&1
rm -rf "$repo/.claude/worktrees/gone-branch"
cd "$repo"
output=$(clearticket "gone-branch" 2>&1) || true
assert_contains "handles already-gone directory" "already gone" "$output"
assert_contains "still clears successfully" "cleared" "$output"

# ── warns about unmerged commits ─────────────────────────────────────────────
repo=$(create_test_repo "t-ct-unmerged")
cd "$repo"
mkdir -p "$repo/.claude/worktrees"
git worktree add "$repo/.claude/worktrees/unmerged-branch" -b unmerged-branch >/dev/null 2>&1
git -C "$repo/.claude/worktrees/unmerged-branch" commit --allow-empty -m "unmerged work" >/dev/null 2>&1
cd "$repo"
output=$(clearticket "unmerged-branch" 2>&1) || true
assert_contains "warns about unmerged commits" "unmerged commits" "$output"

# ── warns about uncommitted changes ──────────────────────────────────────────
repo=$(create_test_repo "t-ct-dirty")
cd "$repo"
mkdir -p "$repo/.claude/worktrees"
git worktree add "$repo/.claude/worktrees/dirty-branch" -b dirty-branch >/dev/null 2>&1
echo "uncommitted content" > "$repo/.claude/worktrees/dirty-branch/dirty-file.txt"
cd "$repo"
output=$(clearticket "dirty-branch" 2>&1) || true
assert_contains "warns about uncommitted changes" "uncommitted changes" "$output"

# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo "─────────────────────────────────────────"
printf "Results: ${GREEN}%d passed${NC}, ${RED}%d failed${NC}\n" "$PASS" "$FAIL"
echo "─────────────────────────────────────────"
echo ""

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
