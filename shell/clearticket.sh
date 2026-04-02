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
# Prompt with [Y/n] — Enter defaults to yes. Uses read -r (full line)
# to avoid leaking keystrokes into subsequent reads.
_ct_confirm() {
  print_question "$1 [Y/n] "
  read -r REPLY
  [[ -z "$REPLY" || "$REPLY" =~ ^[Yy]$ ]]
}

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
    # List existing worktree branches (exclude the main worktree)
    local main_wt_path
    main_wt_path=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
    local -a wt_branches=()
    local line_wt="" line_br=""
    while IFS= read -r line; do
      if [[ "$line" == "worktree "* ]]; then
        line_wt="${line#worktree }"
      elif [[ "$line" == "branch "* ]]; then
        line_br="${line#branch refs/heads/}"
        # Skip the main worktree
        if [[ "$line_wt" != "$main_wt_path" && -n "$line_br" ]]; then
          wt_branches+=("$line_br")
        fi
        line_wt="" ; line_br=""
      fi
    done < <(git worktree list --porcelain 2>/dev/null)

    local default_branch=""
    if (( ${#wt_branches[@]} > 0 )); then
      echo ""
      print_in_blue "Existing worktrees:"
      local idx=1
      for b in "${wt_branches[@]}"; do
        print_in_blue "  ${idx}) ${b}"
        (( idx++ ))
      done
      # Default to the last worktree (most recently added)
      default_branch="${wt_branches[-1]}"
    fi

    echo ""
    if [[ -n "$default_branch" ]]; then
      print_question "Worktree branch to remove (Enter = ${default_branch}): "
    else
      print_question "Worktree branch to remove: "
    fi
    read -r branch
    branch="${branch:-$default_branch}"
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
    print_in_yellow "  [!] You are inside the worktree you are trying to remove."
    if _ct_confirm "Switch to repo root (${repo_root}) and continue?"; then
      cd "$repo_root" || { print_error "Failed to switch to repo root."; return 1; }
      print_success "Switched to ${repo_root}"
    else
      print_error "Aborted. To remove manually, run:"
      print_in_blue "  cd ${repo_root} && clearticket ${branch}"
      return 1
    fi
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
  if ! _ct_confirm "Remove worktree for '${branch}'?"; then
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
    git worktree prune 2>/dev/null
    print_success "Worktree directory already gone — git reference pruned"
  fi

  # ── 8. Optionally delete the branch ────────────────────────────────────────
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    if _ct_confirm "Also delete branch '${branch}'?"; then
      # Resolve base ref safely — fall back to main if origin/HEAD is not set
      local base_ref
      base_ref=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
      base_ref="${base_ref:-main}"

      local should_delete=true
      # Check if branch has unmerged commits
      if ! git merge-base --is-ancestor "$branch" "origin/${base_ref}" 2>/dev/null; then
        print_in_yellow "  [!] Branch '${branch}' has unmerged commits against 'origin/${base_ref}'."
        if ! _ct_confirm "Delete anyway? Unmerged commits will be lost."; then
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
  git worktree prune 2>/dev/null
  print_success "Worktree references pruned"

  # ── 10. Navigate to repo root to avoid shell being in a deleted path ──────
  cd "$repo_root" || true
  print_in_blue "Navigated back to repo root: ${repo_root}"

  echo ""
  print_success "Worktree '${branch}' cleared."
}
