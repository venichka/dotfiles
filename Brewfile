# Packages for a Mac set up from this repo: `brew bundle --file=Brewfile`.
# On a new Mac run setup_mac.sh instead: it also trusts the Cadabra tap, which Homebrew 6+
# requires before this file can install from it. PLATFORMS.md lists the Linux equivalents.

tap "kpeeters/repo"

# Shell
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-completions"
brew "starship"
brew "fzf"
brew "ghq"                # clones into ~/code/<host>/<owner>/<repo>; `repo` in zshrc jumps between them
brew "tmux"
brew "nnn"
brew "tree"
brew "htop"
brew "fastfetch"          # neofetch is no longer in Homebrew
brew "git"
brew "gh"

# Neovim, plus what its plugins call: Treesitter parsers, Telescope search, the Lua LSP
brew "neovim"
brew "tree-sitter-cli"
brew "ripgrep"
brew "fd"
brew "lua-language-server"

# Compilers: GNU gcc, g++ and gfortran, installed as gcc-16, g++-16 and gfortran
# (plain gcc and g++ stay Apple clang), plus CMake and Ninja
brew "gcc"
brew "cmake"
brew "ninja"

# Documents: vimwiki HTML export, PDF previews in nnn
brew "pandoc"
brew "poppler"

# Science
brew "juliaup"
brew "kpeeters/repo/cadabra2"

cask "miniforge"          # conda + mamba, conda-forge only; Anaconda's own channel needs a licence at larger organisations
cask "mactex-no-gui"      # TeX Live; VimTeX + Skim do the editing, so TeXShop and friends aren't needed
cask "skim"
cask "visual-studio-code"
cask "zotero"
cask "rio"                # second terminal; Alacritty's cask is disabled, so `setup_mac.sh alacritty` builds it
cask "font-monaspice-nerd-font"
cask "font-iosevka-term-nerd-font"

# Optional: on the personal Mac but not on the requested list
# cask "obsidian"
# brew "imagemagick"
# brew "ffmpeg"
# brew "gnuplot"
