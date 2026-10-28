#!/usr/bin/env bash
# Set up a Mac from this repo. Safe to re-run: each step skips what is already done.
#
#   ./setup_mac.sh                  # every step, in order
#   ./setup_mac.sh python kernels   # only the named steps
#
# Steps: brew dotfiles python julia kernels vscode alacritty mathematica
# What it can't do (SSH keys, git identity, Zotero) is under "New Mac" in PLATFORMS.md.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVS="$HOME/.python_envs"
ALACRITTY_VERSION="0.17.0"
STEPS=(brew dotfiles python julia kernels vscode alacritty mathematica)

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

note() { printf '  NOTE: %s\n' "$*"; }

# put_line <file> <line>: create <file> holding <line>; leave an existing file alone
put_line() {
  if [[ ! -e "$1" ]]; then
    echo "$2" > "$1"
  elif ! grep -qxF "$2" "$1"; then
    note "$1 exists; add this line to it yourself: $2"
  fi
}

step_brew() {
  if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
    echo "Finish installing the Command Line Tools, then run this script again."
    exit 1
  fi
  if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  # Homebrew 6+ loads third-party taps only once trusted (Cadabra comes from one)
  brew tap kpeeters/repo
  brew trust kpeeters/repo
  brew bundle --file="$REPO_DIR/Brewfile"
  # zsh's compinit refuses group-writable completion folders and would prompt in every new shell
  chmod go-w "$HOMEBREW_PREFIX/share"
  chmod -R go-w "$HOMEBREW_PREFIX"/share/zsh*
}

step_dotfiles() {
  "$REPO_DIR/sync_to_home.sh"
  put_line ~/.zshrc 'source ~/.config/zsh/zshrc'
  put_line ~/.tmux.conf 'source-file ~/.config/tmux/tmux.conf'
  local tpm=~/.config/tmux/plugins/tpm
  [[ -d "$tpm" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
  "$tpm/bin/install_plugins"
}

step_python() {
  local mamba="$HOMEBREW_PREFIX/Caskroom/miniforge/base/bin/mamba" f name
  if [[ ! -e ~/.condarc ]]; then
    cp "$REPO_DIR/conda/condarc" ~/.condarc
  elif ! cmp -s ~/.condarc "$REPO_DIR/conda/condarc"; then
    note "~/.condarc differs from conda/condarc; envs go wherever its envs_dirs says"
  fi
  for f in "$REPO_DIR"/conda/envs/*.yml; do
    name="$(basename "$f" .yml)"
    [[ -d "$ENVS/$name" ]] && continue
    "$mamba" env create -y -f "$f"
  done

  # FriCAS's core image only runs on the SBCL it was built with, and conda-forge has shipped
  # mismatched pairs (vault: technologies/python/sagemath.md). Match SBCL to the build, then pin it.
  local fricas="$ENVS/sage/bin/fricas" want have
  if [[ -x "$fricas" ]] && grep -qx 'FRICAS_LISP_FLAVOR="sbcl"' "$fricas"; then
    want="$(sed -n 's/^FRICAS_LISP_VERSION="\(.*\)"$/\1/p' "$fricas")"
    have="$("$ENVS/sage/bin/sbcl" --version 2>/dev/null | awk '{print $2}')"
    [[ "$want" == "$have" ]] || "$mamba" install -y -n sage "sbcl=$want"
    grep -qs '^sbcl ' "$ENVS/sage/conda-meta/pinned" || echo "sbcl $want.*" >> "$ENVS/sage/conda-meta/pinned"
  fi
}

step_julia() {
  [[ "$(juliaup status 2>/dev/null)" == *release* ]] || juliaup add release
  # Neovim's Julia LSP; see "Julia LanguageServer" in PLATFORMS.md before upgrading Julia
  julia --project=@nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'
}

# Register every kernel globally so VS Code and Jupyter Lab both see them
# (vault: technologies/python/jupyter_kernels.md)
step_kernels() {
  local name py
  for name in ml_base mp pmp qutip; do
    py="$ENVS/$name/bin/python"
    [[ -x "$py" ]] && "$py" -m ipykernel install --user --name "$name" --display-name "Python ($name)"
  done

  # Sage's own kernel.json starts a bare "python", which breaks under VS Code; use the absolute path
  local sage="$ENVS/sage" dir=~/Library/Jupyter/kernels/sagemath ver
  if [[ -x "$sage/bin/python" ]]; then
    ver="$("$sage/bin/python" -c 'import sage.version; print(sage.version.version)')"
    mkdir -p "$dir"
    cp "$sage"/share/jupyter/kernels/sagemath/logo* "$dir/" 2>/dev/null || true
    cat > "$dir/kernel.json" <<EOF
{
  "argv": ["$sage/bin/python", "-m", "sage.repl.ipython_kernel", "-f", "{connection_file}"],
  "display_name": "SageMath $ver",
  "language": "sage",
  "metadata": {"debugger": true}
}
EOF
  fi

  # Cadabra runs on Homebrew's Python. Its kernel.json names the installed version,
  # so re-run this step after `brew upgrade cadabra2`.
  local cadabra="$HOMEBREW_PREFIX/opt/cadabra2/share/jupyter/kernels/cadabra2"
  if [[ -x "$ENVS/ml_base/bin/jupyter" && -d "$cadabra" ]]; then
    "$ENVS/ml_base/bin/jupyter" kernelspec install "$cadabra" --user --name cadabra2
  else
    note "skipped the Cadabra kernel: it needs the ml_base env and cadabra2"
  fi
}

step_vscode() {
  local user="$HOME/Library/Application Support/Code/User" ext
  # VS Code installed outside Homebrew (e.g. by an MDM) doesn't put `code` on PATH
  local cli="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  command -v code >/dev/null || PATH="$cli:$PATH"
  if ! command -v code >/dev/null; then
    note "install VS Code first, then run: $0 vscode"
    return
  fi
  while read -r ext; do
    code --install-extension "$ext" </dev/null
  done < "$REPO_DIR/vscode/extensions.txt"
  mkdir -p "$user"
  if [[ -e "$user/settings.json" ]]; then
    note "VS Code settings.json exists; compare it with vscode/settings.json yourself"
  else
    sed "s#__HOME__#$HOME#g" "$REPO_DIR/vscode/settings.json" > "$user/settings.json"
  fi
}

# Homebrew disabled the Alacritty cask on 2026-09-01: the app isn't notarized, so Gatekeeper
# blocks it. A local build isn't quarantined, so it runs without overriding Gatekeeper.
# To update, raise ALACRITTY_VERSION and run this step again.
step_alacritty() {
  local app=/Applications/Alacritty.app have="" src
  [[ -d "$app" ]] && have="$(defaults read "$app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || true)"
  if [[ "$have" == "$ALACRITTY_VERSION" ]]; then
    echo "Alacritty $have is already installed"
    return
  fi
  [[ -x ~/.cargo/bin/cargo ]] ||
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal
  src="$(mktemp -d)"
  git clone --depth 1 --branch "v$ALACRITTY_VERSION" https://github.com/alacritty/alacritty "$src"
  # "scdoc: command not found" during the build only means no man pages
  (cd "$src" && PATH="$HOME/.cargo/bin:$PATH" make app && tic -xe alacritty,alacritty-direct extra/alacritty.info)
  rm -rf "$app"
  cp -R "$src/target/release/osx/Alacritty.app" /Applications/
  rm -rf "$src"
  echo "Rust (~0.6 GB) stays in ~/.cargo and ~/.rustup for rebuilds; 'rustup self uninstall' removes it."
}

# Sage's mathematica interface runs `math`, which Wolfram 14 doesn't ship (vault: sagemath.md)
step_mathematica() {
  local kernel=/Applications/Wolfram.app/Contents/MacOS/WolframKernel
  if [[ -x "$kernel" && -d "$ENVS/sage/bin" ]]; then
    ln -sf "$kernel" "$ENVS/sage/bin/math"
  else
    note "install Mathematica and the sage env first, then run: $0 mathematica"
  fi
}

[[ $# -eq 0 ]] && set -- "${STEPS[@]}"
for s in "$@"; do
  case " ${STEPS[*]} " in
    *" $s "*) ;;
    *) echo "Unknown step: $s (steps: ${STEPS[*]})" >&2; exit 2 ;;
  esac
done
for s in "$@"; do
  printf '\n==> %s\n' "$s"
  "step_$s"
done
printf '\nDone. Manual steps (SSH keys, git identity, Zotero, ~/.zshrc.local): PLATFORMS.md, "New Mac".\n'
