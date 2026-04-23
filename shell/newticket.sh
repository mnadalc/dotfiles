# ── Dependencies ──────────────────────────────────────────────────────────────
if [[ -z "$DOTFILES_DIR" ]]; then
  echo "  [✖] DOTFILES_DIR is not set — cannot source utils.sh" >&2
  return 1
fi
source "${DOTFILES_DIR}/osx/utils.sh"

# ── newticket ─────────────────────────────────────────────────────────────────
#
# Creates a git worktree + branch and launches Claude Code inside it.
#
# Usage:
#   newticket <branch-name>          — creates worktree directly
#   newticket                        — prompts for branch name interactively
#
# Examples:
#   newticket shoptec-1022-kam-at-uxui-buttons-style-issues
#   newticket feat/LIN-123-user-auth
#
# The worktree is created at .claude/worktrees/<branch-name>/
# and a Claude Code session is started named after the branch.
#
newticket() {
  # ── 1. Resolve repo root (always the main working tree, even from inside a worktree)
  local repo_root
  repo_root=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
  if [[ -z "$repo_root" ]]; then
    print_error "Not inside a git repository."
    return 1
  fi

  # ── 2. Check Claude Code CLI is installed ─────────────────────────────────
  if ! command -v claude &>/dev/null; then
    print_error "Claude Code CLI not found — is it installed and in your PATH?"
    return 1
  fi

  # ── 3. Warn if repository is in detached HEAD state ───────────────────────
  if ! git symbolic-ref HEAD &>/dev/null; then
    print_in_yellow "  [!] Repository is in detached HEAD state — worktree may branch from unexpected commit."
    ask_for_confirmation "Continue anyway?"
    if ! answer_is_yes; then
      print_error "Aborted."
      return 1
    fi
  fi

  # ── 4. Warn if there are uncommitted changes in current directory ──────────
  if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    print_in_yellow "  [!] You have uncommitted changes in the current directory."
    print_in_blue   "      They will stay here and won't be in the new worktree."
  fi

  # ── 5. Resolve branch name ────────────────────────────────────────────────
  local branch="${1:-}"

  if [[ -z "$branch" ]]; then
    echo ""
    print_question "Branch name: "
    read -r branch
    echo ""
  fi

  if [[ -z "$branch" ]]; then
    print_error "Aborted — no branch name given."
    return 1
  fi

  local worktree_dir="${repo_root}/.claude/worktrees/${branch}"

  print_info "Setting up worktree: $branch"

  # ── 6. Guard: bail if worktree already exists in git ─────────────────────
  if git worktree list | grep -qF "${worktree_dir} "; then
    print_error "Worktree '${branch}' already exists."
    print_in_blue "Resume with: cd ${worktree_dir} && claude --resume ${branch}"
    print_in_blue "Or remove with: clearticket ${branch}"
    return 1
  fi

  # ── 7. Guard: stale worktree directory exists on disk ────────────────────
  if [ -d "${worktree_dir}" ]; then
    print_in_yellow "  [!] Stale worktree directory found at ${worktree_dir}"
    ask_for_confirmation "Remove stale directory and continue?"
    if answer_is_yes; then
      rm -rf "$worktree_dir"
      git worktree prune --quiet
      print_success "Stale worktree cleaned up"
    else
      print_error "Aborted — remove it manually: rm -rf ${worktree_dir}"
      return 1
    fi
  fi

  # ── 8. Ensure .claude/worktrees/ is gitignored ────────────────────────────
  local gitignore="${repo_root}/.gitignore"
  if ! grep -qxF '.claude/worktrees/' "$gitignore" 2>/dev/null; then
    echo '.claude/worktrees/' >> "$gitignore"
    print_success "Added .claude/worktrees/ to .gitignore"
  fi

  # ── 9. Sync origin/HEAD & fetch ───────────────────────────────────────────
  print_in_blue "Fetching origin..."
  git remote set-head origin -a 2>/dev/null || true
  git fetch origin --quiet
  print_success "Fetched origin"

  # ── 10. Verify origin/HEAD is resolvable ───────────────────────────────────
  if ! git rev-parse --verify origin/HEAD &>/dev/null; then
    print_error "origin/HEAD is not set — is the remote configured and reachable?"
    return 1
  fi

  # ── 11. Ensure parent directory exists (handles branch names with slashes) ─
  mkdir -p "$(dirname "$worktree_dir")"

  # ── 12. Create worktree + branch ──────────────────────────────────────────
  print_in_blue "Creating worktree for branch '${branch}'..."

  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    # Branch already exists locally — just attach the worktree to it
    print_in_blue "Branch '${branch}' already exists locally — attaching worktree..."
    git worktree add "$worktree_dir" "$branch" || {
      print_error "Failed to create worktree."
      return 1
    }
  elif git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
    # Branch exists on remote but not locally — check it out with tracking
    print_in_blue "Branch '${branch}' found on remote — checking out..."
    git worktree add --track -b "$branch" "$worktree_dir" "origin/${branch}" || {
      print_error "Failed to create worktree."
      return 1
    }
  else
    # Branch doesn't exist anywhere — create it fresh from origin/HEAD
    git worktree add -b "$branch" "$worktree_dir" origin/HEAD || {
      print_error "Failed to create worktree."
      return 1
    }
  fi

  print_success "Worktree created → ${worktree_dir}"

  # ── 13. Copy .env files from main working tree ────────────────────────────
  # .env files are gitignored so they only live in the main working tree.
  # Copy them into the new worktree so the user doesn't have to re-paste them.
  print_in_blue "Copying .env files from main working tree..."
  local env_count=0
  while IFS= read -r -d '' env_file; do
    local rel_path="${env_file#${repo_root}/}"
    local dest="${worktree_dir}/${rel_path}"
    mkdir -p "$(dirname "$dest")"
    cp "$env_file" "$dest"
    env_count=$((env_count + 1))
  done < <(find "$repo_root" -type f \( -name '.env' -o -name '.env.*' -o -name '.env-*' \) \
    -not -path "${repo_root}/node_modules/*" \
    -not -path "${repo_root}/.claude/worktrees/*" \
    -not -path "${repo_root}/.git/*" \
    -not -path '*/node_modules/*' \
    -print0 2>/dev/null)

  if [ "$env_count" -gt 0 ]; then
    print_success "Copied ${env_count} .env file(s) from main working tree"
  else
    print_in_blue "No .env files found in main working tree"
  fi

  # ── 14. Detect package manager ────────────────────────────────────────────
  local pkg_manager=""

  if [ -f "${worktree_dir}/pnpm-lock.yaml" ]; then
    pkg_manager="pnpm"
  elif [ -f "${worktree_dir}/yarn.lock" ]; then
    pkg_manager="yarn"
  elif [ -f "${worktree_dir}/bun.lockb" ] || [ -f "${worktree_dir}/bun.lock" ]; then
    pkg_manager="bun"
  elif [ -f "${worktree_dir}/package-lock.json" ]; then
    pkg_manager="npm"
  elif [ -f "${worktree_dir}/package.json" ]; then
    pkg_manager="npm"
  fi

  if [[ -z "$pkg_manager" ]]; then
    print_in_blue "No package.json found — skipping install"
  else
    # ── 15. Install dependencies ───────────────────────────────────────────
    print_in_blue "Installing dependencies ($pkg_manager install)..."
    ( cd "$worktree_dir" && "$pkg_manager" install )
    if [ $? -eq 0 ]; then
      print_success "Dependencies installed"
    else
      print_error "$pkg_manager install failed (see output above)"
    fi

    # ── 16. Setup git hooks (only if husky is configured) ─────────────────
    local has_husky=false
    if [ -f "${worktree_dir}/.husky/_/husky.sh" ] || \
       [ -f "${worktree_dir}/.husky/pre-commit" ] || \
       grep -q '"husky"' "${worktree_dir}/package.json" 2>/dev/null; then
      has_husky=true
    fi

    if $has_husky; then
      print_in_blue "Setting up git hooks ($pkg_manager run prepare)..."
      ( cd "$worktree_dir" && "$pkg_manager" run prepare )
      if [ $? -eq 0 ]; then
        print_success "Git hooks ready"
      else
        print_error "$pkg_manager run prepare failed (see output above)"
      fi
    else
      print_in_blue "No husky found — skipping git hooks setup"
    fi
  fi

  # ── 17. Launch Claude Code ────────────────────────────────────────────────
  echo ""
  print_success "Worktree ready. Launching Claude Code..."
  echo ""
  cd "$worktree_dir" || {
    print_error "Failed to cd into ${worktree_dir}"
    return 1
  }
  claude --name "$branch"
}
