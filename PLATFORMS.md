# macOS and Linux differences

These dotfiles are shared by two machines: a MacBook (macOS, Homebrew) and an EndeavourOS
laptop (Arch-based, KDE Plasma). Everything that differs between them is handled in one of
three ways:

1. **Detected at runtime**: the config checks the OS, the session or `PATH` and picks the
   right value. Nothing to do per machine.
2. **Machine-local files**: not in git, and never copied or deleted by the sync scripts.
3. **Per-machine setup**: packages and files outside the repo that each machine needs.

Rule of thumb: never put a machine-specific value (an absolute path, a font, a macOS-only
tool) into a tracked file. Use `~`, a `PATH` lookup, an OS check, or a machine-local file.

## 1. Detected at runtime

| What | macOS | Linux | Where |
|---|---|---|---|
| VimTeX PDF viewer | Skim | Zathura; `zathura_simple` on Wayland or without `xdotool` | `nvim/lua/jimi/plugins.lua` (vimtex `init`) |
| Google Drive folder (vimwiki notes, HTML export, export script) | `~/Google Drive` | `~/Google_drive` | `nvim/lua/jimi/plugins.lua` (vimwiki `init`) |
| Sage REPL | `sage` from `PATH`, else `~/.python_envs/sage/bin/sage` | same | `nvim/lua/jimi/iron.lua` |
| Cadabra REPL | `cadabra2-cli` from `PATH` (Homebrew) | `cadabra2-cli` from `PATH` (`/usr/bin`) | `nvim/lua/jimi/iron.lua` |
| Julia language server | `julia` from `PATH` (juliaup) | same | `nvim/lua/jimi/lsp/settings/julials.lua` |
| Alacritty font | FiraCode Nerd Font, from `local.toml` | Alacritty's default (`monospace`), because there is no `local.toml` | `alacritty/alacritty.toml` (`[general] import`) |
| Rio window and top space | `NativeTab` mode, no decorations (no title bar), 6 pt above the text | `Plain` mode, normal title bar, 8 pt above the text | `rio/config.toml` (`[platform.macos]`) |

In Neovim the OS check is `vim.fn.has("mac") == 1`. The Wayland check is
`vim.env.WAYLAND_DISPLAY`.

### Rio

Rio has no include or import, so each machine can't have its own extra file the way
Alacritty does. Instead, Rio's `[platform.macos]` and `[platform.linux]` tables override
settings per OS. In Rio 0.5.28 they cover shell, navigation, window (including
decorations), renderer, `env-vars` and theme, but **not fonts or margin**.

- **Margin:** Rio adds its own space above the text: 2 pt on Linux, and on macOS 26 pt for
  the title bar unless navigation is `NativeTab`. The Mac overrides switch to `NativeTab`
  with decorations disabled, so the Mac reserves nothing and one `margin = [6]` works on
  both: 6 pt on macOS, 8 pt on Linux. On the Mac the text area is exactly what the old
  `Plain` + `Buttonless` + `margin = [-20, 6, 6, 6]` setup gave (same rows and columns,
  tested).
- **What changes on the Mac:** the window has no title bar. Amethyst still tiles it, the
  first lines of text are selectable (there's no invisible drag strip any more), and
  native tabs (Cmd+T) have nowhere to show their tab strip, so use tmux.
- **Fonts are shared:** Hasklug Nerd Font must be installed on both machines. If it's
  missing, Rio shows a warning and falls back to its built-in Cascadia Code, *without*
  bold or italic faces.
- **Rio picks font faces by style name and ignores `weight`.** Always use the exact face
  name, like `style = "Medium Italic"`.

## 2. Machine-local files

These live in `~/.config` on each machine and stay there: they are git-ignored and excluded
by both `sync_to_home.sh` and `sync_from_home.sh`.

| File | Purpose | macOS | Linux |
|---|---|---|---|
| `alacritty/local.toml` | Font faces (family and style) | FiraCode Nerd Font: Light / Bold / Italic / Bold Italic | none (use defaults) |
| `nvim/lazy-lock.json` | Plugin versions pinned on this machine | own copy | own copy |
| `nnn/sessions/`, `nnn/.lastd`, `nnn/mounts` | nnn state | own | own |
| `tmux/plugins/` | Plugins installed by TPM | own | own |

**How Alacritty's `local.toml` works:** `alacritty.toml` imports it, and a missing file is
skipped silently. Alacritty loads imports *first* and `alacritty.toml` *last*, and the last
value wins. So `local.toml` can only provide settings that `alacritty.toml` leaves unset.
That's why the font family and style are not in `alacritty.toml` at all. To use a different
font, or to try one on just one machine, edit that machine's `local.toml`:

```toml
[font.normal]
family = "FiraCode Nerd Font"   # or "Hasklug Nerd Font"
style = "Light"
[font.bold]
family = "FiraCode Nerd Font"
style = "Bold"
[font.italic]
family = "FiraCode Nerd Font"
style = "Italic"
[font.bold_italic]
family = "FiraCode Nerd Font"
style = "Bold Italic"
```

The lock file is ignored by choice, so the two machines can run different plugin
versions. To make one machine match the other, copy its `lazy-lock.json` over and run
`:Lazy restore`.

## 3. Per-machine setup

### Outside the repo, needed on both machines

- **`~/.tmux.conf`** with the single line `source-file ~/.config/tmux/tmux.conf`.
- **TPM**: `git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm`, then
  `prefix + I` inside tmux.
- **vimwiki HTML template**: `~/.dotfiles/vimwiki_conf/templates_html/GitHub.html5`. It
  isn't in this repo; copy it from the Mac.
- **vimwiki export script**: `Work/Notes/vimwiki/wiki2html_zsh.sh` in Google Drive. It needs
  `zsh` and `pandoc`.
- **Julia LanguageServer**: install it once per machine, into the shared environment:
  `julia --project=@nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'`.
  Projects don't need it. Each project only needs its own dependencies installed
  (`Pkg.instantiate()`) so the server can index them.
- **Sage**: either `sage` on `PATH`, or a venv at `~/.python_envs/sage`.
- **Shell config** (`.zshrc`: conda, starship init, nnn variables) isn't in this repo.

### Packages

| Needed for | macOS (Homebrew) | EndeavourOS (pacman / AUR) |
|---|---|---|
| Editor | `neovim` | `neovim` |
| Neovim system clipboard (`clipboard=unnamedplus`) | built in | `wl-clipboard` (Wayland) or `xclip` (X11) |
| Treesitter parsers (main branch compiles them) | `tree-sitter-cli`, Xcode command-line tools | `tree-sitter-cli`, `base-devel` |
| telescope-fzf-native (`make`) | Xcode command-line tools | `base-devel` |
| Mason (installs clangd, texlab, pylsp, julials) | `curl`, `unzip`, `git`, Python 3 | same |
| LaTeX | `mactex` (cask) | `texlive-basic`, `texlive-latex`, `texlive-binextra` (latexmk) |
| PDF viewer | `skim` (cask) | `zathura`, `zathura-pdf-mupdf`; `xdotool` only on X11 |
| vimwiki export | `pandoc` | `pandoc-cli` |
| Julia | `juliaup` | `juliaup` (AUR) |
| Terminal | Alacritty (the Homebrew cask is disabled; install by hand), `rio` (cask) | `alacritty`, `rio` |
| Fonts | `font-fira-code-nerd-font` (Alacritty), `font-hasklug-nerd-font` (Rio) | `otf-hasklig-nerd` (Rio); Alacritty uses the default font |
| Telescope search | `ripgrep`, `fd` | `ripgrep`, `fd` |
| Sage REPL | venv at `~/.python_envs/sage` | `sagemath` |
| Cadabra REPL | `cadabra2` | `cadabra2` (AUR) |
| Shell tools | `tmux`, `starship`, `nnn` | `tmux`, `starship`, `nnn` |

## Differences that remain

- **Alacritty title bar:** `decorations = "buttonless"` is macOS-only. On Linux Alacritty
  shows a normal title bar.
- **Alt key:** in Alacritty on macOS, Option doesn't act as Alt (`option_as_alt` is unset),
  so these Neovim mappings only work on Linux:
  - `<A-Up>`/`<A-Down>`/`<A-Left>`/`<A-Right>` (resize)
  - `<A-j>`/`<A-k>` (move selection)
  - `<A-\>` (split)
  - autopairs `<M-e>`
  - telescope `<M-q>`

  Setting `option_as_alt = "OnlyLeft"` under `[window]` would enable them on the Mac and
  is ignored on Linux.
- **Shift+Insert:** the `PasteSelection` binding pastes the primary selection, which only
  exists on Linux.
- **Home directory:** it's `/Users/nikita` on macOS and `/home/nikita` on Linux. Never write
  it out; use `~`, `vim.fn.expand("~/...")` or `os.getenv("HOME")`.
- **Shebangs:** `#!/bin/zsh` works on both (Arch links `/bin` to `/usr/bin`).
- **Julia sysimage:** `~/.julia/environments/nvim-lspconfig` has a sysimage makefile. The
  output is `languageserver.dylib` on macOS and `.so` on Linux. The config doesn't use either.
- **Leftover on the Mac:** `~/.config/alacritty/alacritty.yml` (the deprecated YAML
  config). `sync_from_home.sh` would copy it into the repo; delete it.

## Syncing

- **Pull changes onto a machine:** `git pull`, then `./sync_to_home.sh --dry-run` to
  preview, then `./sync_to_home.sh`. It backs up the affected folders to
  `~/.config.backup-<timestamp>/` first.
- **After editing in `~/.config`:** run `./sync_from_home.sh`, review `git diff`, then
  commit and push.
- **Components:** `alacritty`, `nnn`, `nvim`, `rio`, `tmux`, `starship`. Name one or
  more to sync only those, like `./sync_to_home.sh --dry-run rio`.
- **New machine-local file in a synced folder:** add it to the excludes in *both* sync
  scripts and to `.gitignore`. Otherwise `sync_to_home.sh` deletes it (it syncs with
  `--delete`) and `sync_from_home.sh` copies it into the repo.

## Checklist when adding something

- [ ] No `/Users/...`, `/home/...`, `/opt/homebrew/...` or `/usr/local/...` paths. Use `~`
      or look the tool up on `PATH`.
- [ ] macOS-only tools (`pbcopy`, `open`, `osascript`, Skim) and Linux-only ones
      (`xdg-open`, `wl-copy`, `xdotool`) sit behind an OS check.
- [ ] Fonts and other per-machine looks go in Alacritty's `local.toml`. In Rio, anything
      that differs goes in `[platform.macos]` / `[platform.linux]` (if Rio supports it there).
- [ ] Any new package is added to the table above for both systems.
