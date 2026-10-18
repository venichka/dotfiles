#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync_from_home.sh [--dry-run] [component ...]

Sync selected configs from ~/.config into this dotfiles repo.

Components (default: all):
  alacritty  nnn  nvim  rio  tmux  starship

Excludes applied automatically (machine-local files):
  alacritty/{local.toml,os.toml}   nnn/{sessions/,bookmarks/,.lastd,mounts}
  nvim/{lazy-lock.json,CLAUDE.md}   tmux/plugins/

Syncing everything skips components that aren't installed here (e.g. rio);
naming a missing component is an error.

Examples:
  sync_from_home.sh                 # sync everything
  sync_from_home.sh nvim            # sync only nvim
  sync_from_home.sh --dry-run nvim  # preview nvim changes only

Options:
  --dry-run   Show what would change without copying/deleting
  -h, --help  Show help
EOF
}

DRYRUN=0
SELECTED=()
SKIPPED=()
VALID=(alacritty nnn nvim rio tmux starship)

is_valid() {
  local n
  for n in "${VALID[@]}"; do [[ "$n" == "$1" ]] && return 0; done
  return 1
}

# want <name>: true if <name> was selected, or if nothing was selected (= all),
# unless <name> was skipped because it isn't installed here.
# (Arrays are length-checked before expansion: macOS bash 3.2 treats an empty "${a[@]}" as unbound.)
want() {
  local n
  if [[ ${#SKIPPED[@]} -gt 0 ]]; then
    for n in "${SKIPPED[@]}"; do [[ "$n" == "$1" ]] && return 1; done
  fi
  [[ ${#SELECTED[@]} -eq 0 ]] && return 0
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

mkdir -p "$REPO_CONFIG_DIR"

# Guardrails: ensure expected source paths exist (only for selected dir components).
# When syncing everything, skip components this machine doesn't have instead of failing.
for name in alacritty nnn nvim rio tmux; do
  want "$name" || continue
  p="$HOME_CONFIG_DIR/$name"
  if [[ ! -e "$p" ]]; then
    if [[ ${#SELECTED[@]} -eq 0 ]]; then
      echo "NOTE: $p not found; skipping $name."
      SKIPPED+=("$name")
    else
      echo "ERROR: missing source path: $p" >&2
      exit 1
    fi
  fi
done

RSYNC_FLAGS=(-av --delete)
if [[ "$DRYRUN" -eq 1 ]]; then
  RSYNC_FLAGS+=(--dry-run)
  echo "🔎 DRY RUN: no changes will be made."
fi

if want alacritty; then
  rsync "${RSYNC_FLAGS[@]}" --exclude 'local.toml' --exclude 'os.toml' \
    "$HOME_CONFIG_DIR/alacritty" \
    "$REPO_CONFIG_DIR/"
fi

if want rio; then
  rsync "${RSYNC_FLAGS[@]}" \
    "$HOME_CONFIG_DIR/rio" \
    "$REPO_CONFIG_DIR/"
fi

if want nnn; then
  rsync "${RSYNC_FLAGS[@]}" --exclude 'sessions/' --exclude 'bookmarks/' --exclude '.lastd' --exclude 'mounts' \
    "$HOME_CONFIG_DIR/nnn" \
    "$REPO_CONFIG_DIR/"
fi

if want nvim; then
  rsync "${RSYNC_FLAGS[@]}" --exclude 'lazy-lock.json' --exclude 'CLAUDE.md' \
    "$HOME_CONFIG_DIR/nvim" \
    "$REPO_CONFIG_DIR/"
fi

if want tmux; then
  rsync "${RSYNC_FLAGS[@]}" --exclude 'plugins/' \
    "$HOME_CONFIG_DIR/tmux" \
    "$REPO_CONFIG_DIR/"
fi

if want starship; then
  if [[ -f "$HOME_CONFIG_DIR/starship.toml" ]]; then
    STARSHIP_FLAGS=(-av)
    [[ "$DRYRUN" -eq 1 ]] && STARSHIP_FLAGS+=(--dry-run)
    rsync "${STARSHIP_FLAGS[@]}" \
      "$HOME_CONFIG_DIR/starship.toml" \
      "$REPO_CONFIG_DIR/"
  else
    echo "NOTE: $HOME_CONFIG_DIR/starship.toml not found; skipping."
  fi
fi

echo "✅ Synced from $HOME_CONFIG_DIR -> $REPO_CONFIG_DIR"
