#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync_to_home.sh [--dry-run] [component ...]

Apply selected configs from this dotfiles repo into ~/.config.

Components (default: all):
  alacritty  nnn  nvim  tmux  starship

Examples:
  sync_to_home.sh                 # apply everything
  sync_to_home.sh nvim            # apply only nvim
  sync_to_home.sh --dry-run nvim  # preview nvim changes only

Safety:
  - Creates a timestamped backup of existing target paths before overwriting:
      ~/.config.backup-YYYYMMDD-HHMMSS/
  - Only the components being synced are backed up.

Options:
  --dry-run   Show what would change without copying/deleting (no backup made)
  -h, --help  Show help
EOF
}

DRYRUN=0
SELECTED=()
VALID=(alacritty nnn nvim tmux starship)

is_valid() {
  local n
  for n in "${VALID[@]}"; do [[ "$n" == "$1" ]] && return 0; done
  return 1
}

# want <name>: true if <name> was selected, or if nothing was selected (= all)
want() {
  [[ ${#SELECTED[@]} -eq 0 ]] && return 0
  local n
  for n in "${SELECTED[@]}"; do [[ "$n" == "$1" ]] && return 0; done
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRYRUN=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *)
      if is_valid "$1"; then
        SELECTED+=("$1")
      else
        echo "Unknown component: $1" >&2; usage; exit 2
      fi
      ;;
  esac
  shift
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG_DIR="$REPO_DIR/.config"
HOME_CONFIG_DIR="${HOME}/.config"

# Guardrails: ensure expected repo paths exist (only for selected dir components)
for name in alacritty nnn nvim tmux; do
  want "$name" || continue
  p="$REPO_CONFIG_DIR/$name"
  if [[ ! -e "$p" ]]; then
    echo "ERROR: missing repo path: $p" >&2
    echo "Did you clone correctly and/or run sync_from_home.sh at least once?" >&2
    exit 1
  fi
done

mkdir -p "$HOME_CONFIG_DIR"

# Backup (skip when dry-running)
BACKUP_DIR=""
if [[ "$DRYRUN" -eq 1 ]]; then
  echo "🔎 DRY RUN: no changes will be made (and no backup will be created)."
else
  TS="$(date +"%Y%m%d-%H%M%S")"
  BACKUP_DIR="${HOME}/.config.backup-${TS}"
  mkdir -p "$BACKUP_DIR"

  echo "📦 Creating backup at: $BACKUP_DIR"

  # Backup only the selected target paths that exist
  for name in alacritty nnn nvim tmux; do
    want "$name" || continue
    if [[ -e "$HOME_CONFIG_DIR/$name" ]]; then
      cp -a "$HOME_CONFIG_DIR/$name" "$BACKUP_DIR/"
    fi
  done

  if want starship && [[ -e "$HOME_CONFIG_DIR/starship.toml" ]]; then
    cp -a "$HOME_CONFIG_DIR/starship.toml" "$BACKUP_DIR/"
  fi
fi

RSYNC_FLAGS=(-av --delete)
if [[ "$DRYRUN" -eq 1 ]]; then
  RSYNC_FLAGS+=(--dry-run)
fi

if want alacritty; then
  rsync "${RSYNC_FLAGS[@]}" \
    "$REPO_CONFIG_DIR/alacritty" \
    "$HOME_CONFIG_DIR/"
fi

if want nnn; then
  rsync "${RSYNC_FLAGS[@]}" \
    "$REPO_CONFIG_DIR/nnn" \
    "$HOME_CONFIG_DIR/"
fi

if want nvim; then
  rsync "${RSYNC_FLAGS[@]}" \
    "$REPO_CONFIG_DIR/nvim" \
    "$HOME_CONFIG_DIR/"
fi

if want tmux; then
  rsync "${RSYNC_FLAGS[@]}" --exclude 'plugins/' \
    "$REPO_CONFIG_DIR/tmux" \
    "$HOME_CONFIG_DIR/"
fi

if want starship; then
  if [[ -f "$REPO_CONFIG_DIR/starship.toml" ]]; then
    STARSHIP_FLAGS=(-av)
    [[ "$DRYRUN" -eq 1 ]] && STARSHIP_FLAGS+=(--dry-run)
    rsync "${STARSHIP_FLAGS[@]}" \
      "$REPO_CONFIG_DIR/starship.toml" \
      "$HOME_CONFIG_DIR/"
  else
    echo "NOTE: $REPO_CONFIG_DIR/starship.toml not found; skipping."
  fi
fi

echo "✅ Applied from $REPO_CONFIG_DIR -> $HOME_CONFIG_DIR"
if [[ -n "$BACKUP_DIR" ]]; then
  echo "🧯 Backup saved at: $BACKUP_DIR"
fi
