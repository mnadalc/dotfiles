#!/bin/bash

# Clones / pulls externally-maintained skill repos into .ai/vendor/
# and creates relative symlinks under .ai/skills/ so they appear
# alongside your own skills.
#
# Skill discovery: walk the repo for any SKILL.md, but skip any
# directory named in EXCLUDED_BUCKETS (matches the convention used
# by mattpocock/skills where `personal/` and `deprecated/` buckets
# are intentionally not promoted).
#
# Collisions: if .ai/skills/<name> already exists as a real
# directory, it's left alone — your own skills always win.
# Existing symlinks are refreshed every run.

source './osx/utils.sh'

# Format: "local-name|git-url[|skill1,skill2,...]"
# If a third comma-separated whitelist is provided, only those skill
# directory names will be linked from that vendor. Leave empty to
# pull every promoted skill.
VENDOR_SKILL_REPOS=(
  "mattpocock-skills|https://github.com/mattpocock/skills.git"
  "vercel-agent-skills|https://github.com/vercel-labs/agent-skills.git|vercel-react-best-practices,vercel-composition-patterns,web-design-guidelines"
  "vercel-next-skills|https://github.com/vercel-labs/next-skills.git|next-best-practices,next-cache-components"
  "vercel-components-build|https://github.com/vercel/components.build.git|building-components"
)

# Directory names skipped during skill discovery, at any depth.
EXCLUDED_BUCKETS=(personal deprecated)

sync_vendor_skills() {
  local ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  local vendor_dir="${ROOT_DIR}/.ai/vendor"
  local skills_dir="${ROOT_DIR}/.ai/skills"

  print_info "Syncing vendor skills."

  mkdir -p "$vendor_dir"
  mkdir -p "$skills_dir"

  for entry in "${VENDOR_SKILL_REPOS[@]}"; do
    local name url skill_filter
    IFS='|' read -r name url skill_filter <<< "$entry"
    local clone_path="${vendor_dir}/${name}"

    if [ -d "${clone_path}/.git" ]; then
      print_in_blue "Pulling latest ${name}..."
      ( cd "$clone_path" && git pull --quiet --ff-only ) || {
        print_error "Failed to pull ${name}."
        continue
      }
    else
      print_in_blue "Cloning ${name} from ${url}..."
      GIT_TEMPLATE_DIR= git clone --quiet "$url" "$clone_path" || {
        print_error "Failed to clone ${name}."
        continue
      }
    fi
    print_success "${name} ready at .ai/vendor/${name}"

    local find_args=(-path "$clone_path/.git" -prune)
    local bucket
    for bucket in "${EXCLUDED_BUCKETS[@]}"; do
      find_args+=(-o -type d -name "$bucket" -prune)
    done
    find_args+=(-o -name SKILL.md -print)
    local skill_source
    skill_source=$(find "$clone_path" "${find_args[@]}" | xargs -n1 dirname)

    local created=0
    local refreshed=0
    local skipped=0
    local kept_names=" "
    local filter_pattern=""
    if [ -n "$skill_filter" ]; then
      filter_pattern=" ${skill_filter//,/ } "
    fi

    while IFS= read -r skill_path; do
      [ -z "$skill_path" ] && continue
      [ -f "${skill_path}/SKILL.md" ] || continue
      local skill_name
      skill_name=$(grep -m1 '^name:' "${skill_path}/SKILL.md" | sed 's/^name:[[:space:]]*//' | tr -d "\"'")
      [ -z "$skill_name" ] && skill_name="$(basename "$skill_path")"
      if [ -n "$filter_pattern" ] && [[ "$filter_pattern" != *" ${skill_name} "* ]]; then
        continue
      fi
      local rel_inside="${skill_path#$clone_path/}"
      local target="${skills_dir}/${skill_name}"
      local rel_source="../vendor/${name}/${rel_inside}"
      kept_names+="${skill_name} "

      if [ -L "$target" ]; then
        rm "$target"
        ln -s "$rel_source" "$target"
        refreshed=$((refreshed + 1))
      elif [ -e "$target" ]; then
        print_in_yellow "  [!] ${skill_name} exists as a real directory — leaving it (your copy wins)."
        skipped=$((skipped + 1))
      else
        ln -s "$rel_source" "$target"
        created=$((created + 1))
      fi
    done <<< "$skill_source"

    print_in_blue "  ${name}: ${created} linked, ${refreshed} refreshed, ${skipped} skipped"

    # Prune symlinks pointing into this vendor that are either dangling
    # or no longer included in the vendor's promoted skill set.
    local pruned=0
    for link in "$skills_dir"/*; do
      [ -L "$link" ] || continue
      local dest
      dest="$(readlink "$link")"
      if [[ "$dest" == "../vendor/${name}/"* ]]; then
        local link_name="$(basename "$link")"
        if [ ! -d "${skills_dir}/${dest}" ]; then
          rm "$link"
          pruned=$((pruned + 1))
          print_in_yellow "  [!] Removed stale symlink: ${link_name}"
        elif [[ "$kept_names" != *" ${link_name} "* ]]; then
          rm "$link"
          pruned=$((pruned + 1))
          print_in_yellow "  [!] Removed unpromoted symlink: ${link_name}"
        fi
      fi
    done
    [ "$pruned" -gt 0 ] && print_in_blue "  ${name}: ${pruned} stale symlinks pruned"
  done

  print_success "Vendor skills synced."
}

sync_vendor_skills
