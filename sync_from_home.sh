#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync_from_home.sh [--dry-run]

Sync selected configs from ~/.config into this dotfiles repo:
  - alacritty/
  - nnn/ (excluding sessions/)
  - nvim/ (excluding lazy-lock.json)
  - starship.toml (if present)

Options:
  --dry-run   Show what would change without copying/deleting
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

mkdir -p "$REPO_CONFIG_DIR"

# Guardrails: ensure expected source paths exist
for p in "$HOME_CONFIG_DIR/alacritty" "$HOME_CONFIG_DIR/nnn" "$HOME_CONFIG_DIR/nvim"; do
  if [[ ! -e "$p" ]]; then
    echo "ERROR: missing source path: $p" >&2
    exit 1
  fi
done

RSYNC_FLAGS=(-av --delete)
if [[ "$DRYRUN" -eq 1 ]]; then
  RSYNC_FLAGS+=(--dry-run)
  echo "🔎 DRY RUN: no changes will be made."
fi

rsync "${RSYNC_FLAGS[@]}" \
  "$HOME_CONFIG_DIR/alacritty" \
  "$REPO_CONFIG_DIR/"

rsync "${RSYNC_FLAGS[@]}" --exclude 'sessions/' \
  "$HOME_CONFIG_DIR/nnn" \
  "$REPO_CONFIG_DIR/"

rsync "${RSYNC_FLAGS[@]}" --exclude 'lazy-lock.json' \
  "$HOME_CONFIG_DIR/nvim" \
  "$REPO_CONFIG_DIR/"

if [[ -f "$HOME_CONFIG_DIR/starship.toml" ]]; then
  rsync -av ${DRYRUN:+--dry-run} \
    "$HOME_CONFIG_DIR/starship.toml" \
    "$REPO_CONFIG_DIR/"
else
  echo "NOTE: $HOME_CONFIG_DIR/starship.toml not found; skipping."
fi

echo "✅ Synced from $HOME_CONFIG_DIR -> $REPO_CONFIG_DIR"

