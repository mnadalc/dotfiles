# ── Dependencies ──────────────────────────────────────────────────────────────
if [[ -z "$DOTFILES_DIR" ]]; then
  echo "  [✖] DOTFILES_DIR is not set — cannot source utils.sh" >&2
  return 1
fi
source "${DOTFILES_DIR}/osx/utils.sh"

# ── clearticket ───────────────────────────────────────────────────────────────
#
# Removes a git worktree and optionally deletes its branch.
#
# Usage:
#   clearticket <branch-name>        — removes worktree directly
#   clearticket                      — prompts for branch name interactively
#
# Examples:
#   clearticket shoptec-1022-kam-at-uxui-buttons-style-issues
#   clearticket feat/LIN-123-user-auth
#
clearticket() {
  # ── 1. Resolve repo root (always the main working tree, even from inside a worktree)
  local repo_root
  repo_root=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
  if [[ -z "$repo_root" ]]; then
    print_error "Not inside a git repository."
    return 1
  fi

  # ── 2. Resolve branch name ────────────────────────────────────────────────
  local branch="${1:-}"

  if [[ -z "$branch" ]]; then
    echo ""
    print_question "Branch name to clear: "
    read -r branch
    echo ""
  fi

  if [[ -z "$branch" ]]; then
    print_error "Aborted — no branch name given."
    return 1
  fi

  local worktree_dir="${repo_root}/.claude/worktrees/${branch}"

  print_info "Clearing worktree: $branch"

  # ── 3. Guard: bail if running from inside the worktree to be deleted ──────
  local current_dir
  current_dir=$(pwd -P)
  if [[ "$current_dir" == "${worktree_dir}" || "$current_dir" == "${worktree_dir}/"* ]]; then
    print_error "You are inside the worktree you are trying to delete."
    print_in_blue "Run: cd ${repo_root} && clearticket ${branch}"
    return 1
  fi

  # ── 4. Guard: bail if neither worktree nor branch exist ───────────────────
  if ! git worktree list | grep -qF "${worktree_dir} " && \
     ! git show-ref --verify --quiet "refs/heads/${branch}" && \
     ! [ -d "${worktree_dir}" ]; then
    print_error "Worktree '${branch}' does not exist."
    return 1
  fi

  # ── 5. Warn about uncommitted changes in the worktree ────────────────────
  if [ -d "$worktree_dir" ]; then
    local dirty_files
    dirty_files=$(git -C "$worktree_dir" status --porcelain 2>/dev/null)
    if [[ -n "$dirty_files" ]]; then
      print_in_yellow "  [!] Worktree has uncommitted changes that will be lost:"
      echo "$dirty_files" | head -10
    fi
  fi

  # ── 6. Confirm worktree removal ──────────────────────────────────────────
  ask_for_confirmation "Remove worktree for '${branch}'?"
  if ! answer_is_yes; then
    print_error "Aborted."
    return 1
  fi

  # ── 7. Remove the worktree ────────────────────────────────────────────────
  print_in_blue "Removing worktree..."
  if [ -d "$worktree_dir" ]; then
    git worktree remove --force "$worktree_dir" && \
      print_success "Worktree removed" || \
      print_error "Failed to remove worktree — check manually"
  else
    # Directory already gone — just prune the git reference
    git worktree prune --quiet
    print_success "Worktree directory already gone — git reference pruned"
  fi

  # ── 8. Optionally delete the branch ────────────────────────────────────────
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    ask_for_confirmation "Also delete branch '${branch}'?"
    if answer_is_yes; then
      # Resolve base ref safely — fall back to main if origin/HEAD is not set
      local base_ref
      base_ref=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
      base_ref="${base_ref:-main}"

      local should_delete=true
      # Check if branch has unmerged commits
      if ! git merge-base --is-ancestor "$branch" "origin/${base_ref}" 2>/dev/null; then
        print_in_yellow "  [!] Branch '${branch}' has unmerged commits against 'origin/${base_ref}'."
        ask_for_confirmation "Delete anyway? Unmerged commits will be lost."
        if ! answer_is_yes; then
          should_delete=false
        fi
      fi

      if $should_delete; then
        git branch -D "$branch" && \
          print_success "Branch deleted" || \
          print_error "Failed to delete branch — check manually"
      else
        print_in_blue "Branch '${branch}' kept."
      fi
    else
      print_in_blue "Branch '${branch}' kept."
    fi
  else
    print_in_blue "Branch '${branch}' already gone — skipping"
  fi

  # ── 9. Prune any remaining stale worktree references ─────────────────────
  git worktree prune --quiet
  print_success "Worktree references pruned"

  # ── 10. Navigate to repo root to avoid shell being in a deleted path ──────
  cd "$repo_root" || true
  print_in_blue "Navigated back to repo root: ${repo_root}"

  echo ""
  print_success "Worktree '${branch}' cleared."
}
