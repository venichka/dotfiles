#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync_to_home.sh [--dry-run]

Apply selected configs from this dotfiles repo into ~/.config:
  - alacritty/
  - nnn/
  - nvim/
  - starship.toml (if present)

Safety:
  - Creates a timestamped backup of existing target paths before overwriting:
      ~/.config.backup-YYYYMMDD-HHMMSS/

Options:
  --dry-run   Show what would change without copying/deleting (no backup made)
  -h, --help  Show help
EOF
}

DRYRUN=0
case "${1:-}" in
  --dry-run) DRYRUN=1 ;;
  -h|--help) usage; exit 0 ;;
  "" ) ;;
  *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
esac

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG_DIR="$REPO_DIR/.config"
HOME_CONFIG_DIR="${HOME}/.config"

# Guardrails: ensure expected repo paths exist
for p in "$REPO_CONFIG_DIR/alacritty" "$REPO_CONFIG_DIR/nnn" "$REPO_CONFIG_DIR/nvim"; do
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

  # Backup only the target paths if they exist
  for name in alacritty nnn nvim; do
    if [[ -e "$HOME_CONFIG_DIR/$name" ]]; then
      cp -a "$HOME_CONFIG_DIR/$name" "$BACKUP_DIR/"
    fi
  done

  if [[ -e "$HOME_CONFIG_DIR/starship.toml" ]]; then
    cp -a "$HOME_CONFIG_DIR/starship.toml" "$BACKUP_DIR/"
  fi
fi

RSYNC_FLAGS=(-av --delete)
if [[ "$DRYRUN" -eq 1 ]]; then
  RSYNC_FLAGS+=(--dry-run)
fi

rsync "${RSYNC_FLAGS[@]}" \
  "$REPO_CONFIG_DIR/alacritty" \
  "$HOME_CONFIG_DIR/"

rsync "${RSYNC_FLAGS[@]}" \
  "$REPO_CONFIG_DIR/nnn" \
  "$HOME_CONFIG_DIR/"

rsync "${RSYNC_FLAGS[@]}" \
  "$REPO_CONFIG_DIR/nvim" \
  "$HOME_CONFIG_DIR/"

if [[ -f "$REPO_CONFIG_DIR/starship.toml" ]]; then
  rsync -av ${DRYRUN:+--dry-run} \
    "$REPO_CONFIG_DIR/starship.toml" \
    "$HOME_CONFIG_DIR/"
else
  echo "NOTE: $REPO_CONFIG_DIR/starship.toml not found; skipping."
fi

echo "✅ Applied from $REPO_CONFIG_DIR -> $HOME_CONFIG_DIR"
if [[ -n "$BACKUP_DIR" ]]; then
  echo "🧯 Backup saved at: $BACKUP_DIR"
fi

