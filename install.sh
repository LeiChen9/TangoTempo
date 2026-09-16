#!/usr/bin/env bash
#
# install.sh — sync TangoTempo skills + always-on Gate into your agent's
# environment. Idempotent, non-destructive: existing files are appended to,
# never overwritten. Skills are installed as symlinks, so `git pull` in this
# repo instantly updates every host.
#
# Usage:
#   ./install.sh                          global scope, auto-detect hosts
#   ./install.sh --scope project          install into $PWD (.agents/skills + AGENTS.md)
#   ./install.sh --agents opencode        only this host (comma-separated list)
#   ./install.sh --dry-run                preview without changing anything
#
set -euo pipefail

# --- markers ----------------------------------------------------------------
BEGIN_MARK="<!-- BEGIN tango-tempo gate -->"
END_MARK="<!-- END tango-tempo gate -->"

# --- resolve repo root (directory this script lives in) ---------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
GATE_FILE="$REPO_DIR/AGENTS.md"

# --- defaults ---------------------------------------------------------------
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
    --help|-h) sed -n '2,10p' "$0"; exit 0;;
    *) echo "unknown option: $1" >&2; exit 1;;
  esac
done

if [[ "$SCOPE" != "global" && "$SCOPE" != "project" ]]; then
  echo "error: --scope must be 'global' or 'project' (got '$SCOPE')" >&2; exit 1
fi
if [[ ! -f "$GATE_FILE" ]]; then
  echo "error: $GATE_FILE not found (is this the TangoTempo repo?)" >&2; exit 1
fi

log() { if [[ "$DRY_RUN" -eq 1 ]]; then echo "[dry-run] $*"; else echo "$*"; fi; }
do_or_skip() { if [[ "$DRY_RUN" -eq 1 ]]; then return 0; else "$@"; fi; }

# --- host registry -----------------------------------------------------------
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
host_installed() {
  case "$1" in
    opencode) command -v opencode >/dev/null 2>&1 || [[ -d "$HOME/.config/opencode" ]] ;;
    codex)    command -v codex    >/dev/null 2>&1 || [[ -d "$HOME/.codex" ]] ;;
    copilot)  command -v copilot  >/dev/null 2>&1 || [[ -d "$HOME/.copilot" ]] ;;
  esac
}

# --- choose hosts ------------------------------------------------------------
if [[ -n "$AGENTS_FILTER" ]]; then
  IFS=',' read -r -a TARGET_HOSTS <<< "$AGENTS_FILTER"
  for h in "${TARGET_HOSTS[@]}"; do
    case "$h" in opencode|codex|copilot) ;; *) echo "error: unknown host '$h' (try opencode, codex, copilot)" >&2; exit 1;; esac
  done
else
  TARGET_HOSTS=()
  for h in opencode codex copilot; do
    host_installed "$h" && TARGET_HOSTS+=("$h")
  done
  if [[ "${#TARGET_HOSTS[@]}" -eq 0 ]]; then
    echo "no supported agent detected; pass --agents opencode,codex,copilot" >&2
    exit 1
  fi
fi

# --- skill names -------------------------------------------------------------
SKILL_NAMES=()
for d in "$SKILLS_DIR"/*/; do
  [[ -d "$d" ]] && SKILL_NAMES+=("$(basename "$d")")
done
SKILL_NAMES=($(printf '%s\n' "${SKILL_NAMES[@]}" | sort))

# --- install skills (symlink) --------------------------------------------------
if [[ "$SCOPE" == "global" ]]; then
  TARGETS=()
  for h in "${TARGET_HOSTS[@]}"; do TARGETS+=("$(host_skills_dir "$h")"); done
else
  TARGETS=("$PWD/.agents/skills")
fi

for target in "${TARGETS[@]}"; do
  for name in "${SKILL_NAMES[@]}"; do
    dest="$target/$name"
    src="$SKILLS_DIR/$name"
    if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
      log "ok      $dest (already linked)"
    elif [[ -e "$dest" ]]; then
      echo "skip    $dest exists and is not ours — untouched (remove it yourself if you want the link)" >&2
    else
      log "link    $dest -> $src"
      do_or_skip mkdir -p "$target"
      do_or_skip ln -s "$src" "$dest"
    fi
  done
done

# --- install Gate (append, never overwrite) -----------------------------------
append_gate() {
  local file="$1"
  if [[ -f "$file" ]] && grep -qF "$BEGIN_MARK" "$file"; then
    log "ok      $file (gate already present)"
    return
  fi
  log "append  gate -> $file"
  [[ "$DRY_RUN" -eq 1 ]] && return
  mkdir -p "$(dirname "$file")"
  {
    [[ -e "$file" ]] && [[ -s "$file" ]] && { printf '\n'; }
    printf '%s\n' "$BEGIN_MARK"
    cat "$GATE_FILE"
    printf '%s\n' "$END_MARK"
  } >> "$file"
}

if [[ "$SCOPE" == "global" ]]; then
  for h in "${TARGET_HOSTS[@]}"; do append_gate "$(host_gate_file "$h")"; done
else
  append_gate "$PWD/AGENTS.md"
fi

echo
echo "Done ($SCOPE scope). Restart your agent — tango-tempo is now always-on."