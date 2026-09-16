#!/usr/bin/env bash
#
# uninstall.sh — remove what install.sh created. Non-destructive: only removes
# symlinks that point into this repo's skills/ and Gate blocks delimited by the
# tango-tempo markers. Everything else is left exactly as it was.
#
# Usage mirrors install.sh:
#   ./uninstall.sh
#   ./uninstall.sh --scope project
#   ./uninstall.sh --agents opencode,codex,copilot
#   ./uninstall.sh --dry-run
#
set -euo pipefail

BEGIN_MARK="<!-- BEGIN tango-tempo gate -->"
END_MARK="<!-- END tango-tempo gate -->"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"

SCOPE="global"
AGENTS_FILTER=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope) SCOPE="$2"; shift 2;;
    --scope=*) SCOPE="${1#*=}"; shift;;
    --agents) AGENTS_FILTER="$2"; shift 2;;
    --agents=*) AGENTS_FILTER="${1#*=}"; shift;;
    --dry-run) DRY_RUN=1; shift;;
    --help|-h) sed -n '1,10p' "$0"; exit 0;;
    *) echo "unknown option: $1" >&2; exit 1;;
  esac
done

log() { if [[ "$DRY_RUN" -eq 1 ]]; then echo "[dry-run] $*"; else echo "$*"; fi; }
do_or_skip() { if [[ "$DRY_RUN" -eq 1 ]]; then return 0; else "$@"; fi; }

host_skills_dir() {
  case "$1" in
    opencode) echo "$HOME/.config/opencode/skills" ;;
    codex)    echo "$HOME/.codex/skills" ;;
    copilot)  echo "$HOME/.copilot/skills" ;;
  esac
}
host_gate_file() {
  case "$1" in
    opencode) echo "$HOME/.config/opencode/AGENTS.md" ;;
    codex)    echo "$HOME/.codex/AGENTS.md" ;;
    copilot)  echo "$HOME/.copilot/copilot-instructions.md" ;;
  esac
}

if [[ -n "$AGENTS_FILTER" ]]; then
  IFS=',' read -r -a TARGET_HOSTS <<< "$AGENTS_FILTER"
else
  TARGET_HOSTS=(opencode codex copilot)
fi

SKILL_NAMES=()
for d in "$SKILLS_DIR"/*/; do
  [[ -d "$d" ]] && SKILL_NAMES+=("$(basename "$d")")
done
SKILL_NAMES=($(printf '%s\n' "${SKILL_NAMES[@]}" | sort))

if [[ "$SCOPE" == "global" ]]; then
  TARGETS=()
  for h in "${TARGET_HOSTS[@]}"; do TARGETS+=("$(host_skills_dir "$h")"); done
  GATE_FILES=()
  for h in "${TARGET_HOSTS[@]}"; do GATE_FILES+=("$(host_gate_file "$h")"); done
else
  TARGETS=("$PWD/.agents/skills")
  GATE_FILES=("$PWD/AGENTS.md")
fi

for target in "${TARGETS[@]}"; do
  for name in "${SKILL_NAMES[@]}"; do
    dest="$target/$name"
    if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$SKILLS_DIR/$name" ]]; then
      log "unlink  $dest"
      do_or_skip rm "$dest"
    elif [[ -e "$dest" ]]; then
      echo "keep    $dest (not ours — only removing symlinks that point into this repo)" >&2
    fi
  done
done

for file in "${GATE_FILES[@]}"; do
  if [[ -f "$file" ]] && grep -qF "$BEGIN_MARK" "$file"; then
    log "strip   gate -> $file"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      :
    else
      tmp="$file.tango-tempo.bak"
      do_or_skip awk -v b="$BEGIN_MARK" -v e="$END_MARK" '
        index($0, b) { inblock=1; next }
        inblock && index($0, e) { inblock=0; next }
        !inblock { print }
      ' "$file" > "$tmp"
      do_or_skip mv "$tmp" "$file"
    fi
  elif [[ -f "$file" ]]; then
    echo "keep    $file (no gate block found)" >&2
  fi
done

echo
echo "Uninstalled ($SCOPE scope). Your own content is untouched."