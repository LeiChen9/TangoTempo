#!/usr/bin/env bash
#
# install.sh — sync TangoTempo skills + always-on Gate into your agent's
# environment. Idempotent, non-destructive: files are appended to, or have the
# tango-tempo marker block refreshed in place, never reset. Skills are installed
# as symlinks, so `git pull` + re-running this script updates every host.
#
# Usage:
#   ./install.sh                          install + update, global, auto-detect hosts
#   ./install.sh --scope project          install into $PWD (per-host dir + AGENTS.md)
#   ./install.sh --agents opencode        only this host (comma-separated list)
#   ./install.sh --dry-run                preview without changing anything
#
# Hosts: opencode | codex | copilot | cline
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
    --help|-h) sed -n '2,14p' "$0"; exit 0;;
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
    cline)    echo "$HOME/.cline/skills" ;;
  esac
}
host_gate_file() {
  case "$1" in
    opencode) echo "$HOME/.config/opencode/AGENTS.md" ;;
    codex)    echo "$HOME/.codex/AGENTS.md" ;;
    copilot)  echo "$HOME/.copilot/copilot-instructions.md" ;;
    # Cline loads every rule in this dir on every session, so our own file there
    # is the always-on equivalent of Copilot's copilot-instructions.md.
    cline)    echo "$HOME/Documents/Cline/Rules/tango-tempo.md" ;;
  esac
}
# Project-scope skills dir per host. Copilot, Codex and OpenCode share
# `.agents/skills/`; Cline only reads `.cline/skills/` (or `.clinerules/skills/`).
host_project_skills_dir() {
  case "$1" in
    opencode|codex|copilot) echo ".agents/skills" ;;
    cline)                  echo ".cline/skills" ;;
  esac
}
host_installed() {
  case "$1" in
    opencode) command -v opencode >/dev/null 2>&1 || [[ -d "$HOME/.config/opencode" ]] ;;
    codex)    command -v codex    >/dev/null 2>&1 || [[ -d "$HOME/.codex" ]] ;;
    copilot)  command -v copilot  >/dev/null 2>&1 || [[ -d "$HOME/.copilot" ]] ;;
    cline)    command -v cline    >/dev/null 2>&1 || [[ -d "$HOME/.cline" ]] || [[ -d "$HOME/Documents/Cline" ]] ;;
  esac
}

# --- choose hosts ------------------------------------------------------------
if [[ -n "$AGENTS_FILTER" ]]; then
  IFS=',' read -r -a TARGET_HOSTS <<< "$AGENTS_FILTER"
  for h in "${TARGET_HOSTS[@]}"; do
    case "$h" in opencode|codex|copilot|cline) ;; *) echo "error: unknown host '$h' (try opencode, codex, copilot, cline)" >&2; exit 1;; esac
  done
else
  TARGET_HOSTS=()
  for h in opencode codex copilot cline; do
    host_installed "$h" && TARGET_HOSTS+=("$h")
  done
  if [[ "${#TARGET_HOSTS[@]}" -eq 0 ]]; then
    echo "no supported agent detected; pass --agents opencode,codex,copilot,cline" >&2
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
  TARGETS=()
  for h in "${TARGET_HOSTS[@]}"; do
    d="$PWD/$(host_project_skills_dir "$h")"
    case " ${TARGETS[*]:-} " in *" $d "*) continue ;; esac   # shared dirs link once
    TARGETS+=("$d")
  done
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

# --- install/refresh Gate (marker block only — never a reset) -----------------
# Appends the block when it is absent; refreshes it in place when it is present,
# so `git pull` + re-run propagates Gate edits. Everything outside the markers
# is left exactly as it is.
sync_gate() {
  local file="$1" has_begin=0 has_end=0
  if [[ -f "$file" ]]; then
    grep -qF "$BEGIN_MARK" "$file" && has_begin=1
    grep -qF "$END_MARK" "$file" && has_end=1
  fi

  if [[ "$has_begin" -eq 1 && "$has_end" -eq 1 ]]; then
    log "refresh gate -> $file"
    [[ "$DRY_RUN" -eq 1 ]] && return
    local tmp="$file.tango-tempo.new"
    awk -v b="$BEGIN_MARK" -v e="$END_MARK" -v g="$GATE_FILE" '
      index($0, b) {                       # our block starts here
        print
        while ((getline line < g) > 0) print line
        close(g)
        inblock = 1
        next
      }
      inblock && index($0, e) { inblock = 0; print; next }
      inblock { next }                     # drop the stale body only
      { print }                            # everything else belongs to the user
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
    return
  fi

  if [[ "$has_begin" -eq 1 || "$has_end" -eq 1 ]]; then
    echo "warn    $file has an unpaired tango-tempo marker — left untouched" >&2
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
  for h in "${TARGET_HOSTS[@]}"; do sync_gate "$(host_gate_file "$h")"; done
else
  sync_gate "$PWD/AGENTS.md"
fi

echo
echo "Done ($SCOPE scope). Restart your agent — tango-tempo is now always-on."
echo "Update later with: git pull && ./install.sh"