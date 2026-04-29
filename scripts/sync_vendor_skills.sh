#!/bin/bash

# Clones / pulls externally-maintained skill repos into .ai/vendor/
# and creates relative symlinks under .ai/skills/ so they appear
# alongside your own skills.
#
# Collisions: if .ai/skills/<name> already exists as a real
# directory, it's left alone — your own skills always win.
# Existing symlinks are refreshed every run.

source './osx/utils.sh'

# Format: "local-name|git-url"
VENDOR_SKILL_REPOS=(
  "mattpocock-skills|https://github.com/mattpocock/skills.git"
)

sync_vendor_skills() {
  local ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  local vendor_dir="${ROOT_DIR}/.ai/vendor"
  local skills_dir="${ROOT_DIR}/.ai/skills"

  print_info "Syncing vendor skills."

  mkdir -p "$vendor_dir"
  mkdir -p "$skills_dir"

  for entry in "${VENDOR_SKILL_REPOS[@]}"; do
    local name="${entry%%|*}"
    local url="${entry##*|}"
    local clone_path="${vendor_dir}/${name}"

    if [ -d "${clone_path}/.git" ]; then
      print_in_blue "Pulling latest ${name}..."
      ( cd "$clone_path" && git pull --quiet --ff-only ) || {
        print_error "Failed to pull ${name}."
        continue
      }
    else
      print_in_blue "Cloning ${name} from ${url}..."
      git clone --quiet "$url" "$clone_path" || {
        print_error "Failed to clone ${name}."
        continue
      }
    fi
    print_success "${name} ready at .ai/vendor/${name}"

    local created=0
    local refreshed=0
    local skipped=0
    while IFS= read -r skill_md; do
      local skill_path="$(dirname "$skill_md")"
      local skill_name="$(basename "$skill_path")"
      local rel_inside="${skill_path#$clone_path/}"
      local target="${skills_dir}/${skill_name}"
      local rel_source="../vendor/${name}/${rel_inside}"

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
    done < <(find "$clone_path" -path "$clone_path/.git" -prune -o -name SKILL.md -print)

    print_in_blue "  ${name}: ${created} linked, ${refreshed} refreshed, ${skipped} skipped"

    # Prune symlinks that point into this vendor but whose upstream skill is gone.
    local pruned=0
    for link in "$skills_dir"/*; do
      [ -L "$link" ] || continue
      local dest
      dest="$(readlink "$link")"
      if [[ "$dest" == "../vendor/${name}/"* ]]; then
        if [ ! -d "${skills_dir}/${dest}" ]; then
          rm "$link"
          pruned=$((pruned + 1))
          print_in_yellow "  [!] Removed stale symlink: $(basename "$link")"
        fi
      fi
    done
    [ "$pruned" -gt 0 ] && print_in_blue "  ${name}: ${pruned} stale symlinks pruned"
  done

  print_success "Vendor skills synced."
}

sync_vendor_skills
