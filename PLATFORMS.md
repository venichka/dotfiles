# macOS and Linux differences

These dotfiles are shared by two machines: a MacBook (macOS, Homebrew) and an EndeavourOS
laptop (Arch-based, KDE Plasma). Everything that differs between them is handled in one of
three ways:

1. **Detected at runtime**: the config checks the OS, the session or `PATH` and picks the
   right value. Nothing to do per machine.
2. **Machine-local files**: not in git, and never copied or deleted by the sync scripts.
3. **Per-machine setup**: packages and files outside the repo that each machine needs.

Rule of thumb: never put a machine-specific value (an absolute path, a macOS-only tool)
into a shared tracked file. Use `~`, a `PATH` lookup, an OS check, a per-OS file, or a
machine-local file.

## 1. Detected at runtime

| What | macOS | Linux | Where |
|---|---|---|---|
| VimTeX PDF viewer | Skim | Zathura; `zathura_simple` on Wayland or without `xdotool` | `nvim/lua/jimi/plugins.lua` (vimtex `init`) |
| Google Drive folder (vimwiki notes, HTML export, export script) | `~/Google Drive` | `~/Google_drive` | `nvim/lua/jimi/plugins.lua` (vimwiki `init`) |
| Sage REPL | `sage` from `PATH`, else `~/.python_envs/sage/bin/sage` | same | `nvim/lua/jimi/iron.lua` |
| Cadabra REPL | `cadabra2-cli` from `PATH` (Homebrew) | `cadabra2-cli` from `PATH` (`/usr/bin`) | `nvim/lua/jimi/iron.lua` |
| Julia language server | `julia` from `PATH` (juliaup) | `julia` from `PATH` (Arch's `julia` package) | `nvim/lua/jimi/lsp/settings/julials.lua` |
| Alacritty window | `buttonless` decorations, opacity 1.0 | no decorations, opacity 0.8 | `alacritty/os/macos.toml`, `alacritty/os/linux.toml` |
| Alacritty font | Monaspace Neon (`MonaspiceNe Nerd Font Mono`) | Iosevka Term (`IosevkaTerm Nerd Font Mono`) | same files |
| Rio window and top space | `NativeTab` mode, no decorations (no title bar), opacity 1.0, 6 pt above the text | `Plain` mode, no decorations, opacity 0.8 | `rio/config.toml` (`[platform.macos]`; `NativeTab` is a `# macos:` line) |
| Rio font, size and line height | Monaspace Neon, 11.5 and 1.09 | Iosevka Term, 16 and 1.1 | `rio/config.toml` (`# macos:` lines) |

In Neovim the OS check is `vim.fn.has("mac") == 1`. The Wayland check is
`vim.env.WAYLAND_DISPLAY`.

### Alacritty

Alacritty has no OS check, so the settings that differ live in two tracked files,
`alacritty/os/macos.toml` and `alacritty/os/linux.toml`. `sync_to_home.sh` links
`~/.config/alacritty/os.toml` to the one for the current OS (`uname -s`), and
`alacritty.toml` imports it:

```toml
[general]
import = ["os.toml", "local.toml"]
```

Alacritty loads the imports in order and `alacritty.toml` *last*, and the last value wins.
So:

- `alacritty.toml` must not set anything the OS files set (`window.decorations`,
  `window.opacity`, the font faces), or it silently overrides them on both systems.
- `local.toml` (optional, machine-local) loads after `os.toml`, so it can override the OS
  settings on one machine, e.g. to try another font (see section 2).
- On a new machine, run `sync_to_home.sh` once to create the `os.toml` link. Without it
  Alacritty falls back to its defaults (default font, title bar, opaque window).

### Rio

Rio has no include or import, so each machine can't have its own extra file the way
Alacritty does. Instead, Rio's `[platform.macos]` and `[platform.linux]` tables override
settings per OS. In Rio 0.5.28 they cover shell, navigation, window (including
decorations), renderer, `env-vars` and theme, but **not fonts, line height or margin**.

- **Per-OS lines:** what the platform tables can't do is handled by the sync scripts.
  The repo's `rio/config.toml` holds the Linux values, and a line that differs on macOS
  carries its Mac version after a `# macos:` tag:
  ```toml
  size = 16                                   # macos: size = 11.5
  # macos: mode = "NativeTab"
  ```
  On a Mac, `sync_to_home.sh` swaps them, so `~/.config/rio/config.toml` there reads
  `size = 11.5  # linux: size = 16` and `mode = "NativeTab"  # macos only`.
  `sync_from_home.sh` swaps them back, so the repo always keeps the Linux form (the swap
  is `os_lines.awk`). Edit either machine's file as usual. On the Mac, change a value in
  front of its `# linux:` tag, or end a new Mac-only line with `# macos only`. Keep other
  comments off tagged lines.
- **`NativeTab` must stay tagged:** Rio on Linux doesn't know it and rejects it even inside
  `[platform.macos]`. It then shows a warning and ignores the *whole* file (title bar,
  default font, no transparency).

- **Margin:** Rio adds its own space above the text: 2 pt on Linux, and on macOS 26 pt for
  the title bar unless navigation is `NativeTab`. The Mac overrides switch to `NativeTab`
  with decorations disabled, so the Mac reserves nothing and one `margin = [6]` works on
  both: 6 pt on macOS, 8 pt on Linux. On the Mac the text area is exactly what the old
  `Plain` + `Buttonless` + `margin = [-20, 6, 6, 6]` setup gave (same rows and columns,
  tested).
- **What changes on the Mac:** the window has no title bar. Amethyst still tiles it, the
  first lines of text are selectable (there's no invisible drag strip any more), and
  native tabs (Cmd+T) have nowhere to show their tab strip, so use tmux.
- **Fonts:** the same as Alacritty: Monaspace Neon on macOS and Iosevka Term on Linux. If
  the family is missing, Rio shows a warning and falls back to its built-in Cascadia Code,
  *without* bold or italic faces. Monaspace Neon lacks some of the sub/superscripts vimtex
  conceals to (the Greek ones like ᵦ ᵧ ᵝ ᵞ, and ˂ ˃): those fall back to another font or
  show blank. Iosevka Term has them all.
- **Font size differs per OS:** Alacritty on Linux converts points to pixels at 96 DPI
  (12 pt = 16 px), but on macOS, like Rio everywhere, 1 pt = 1 px (doubled on Retina). To
  get the same cells as Alacritty at size 12, Rio needs:
  - Linux, Iosevka Term: size 16 with `line-height = 1.1`, giving 8×22 px cells at scale 1
    (measured against Alacritty).
  - macOS, Monaspace Neon: size 11.5 with `line-height = 1.09`, giving 7×16 px at 1x and
    14×31 on Retina. On the Mac, Alacritty floors the glyph width (14.88 px on Retina) but
    Rio rounds it, so Rio at 12 would get 15 px cells and about 7% fewer columns. These
    numbers come from Rio measured on Linux at the same pixel sizes and from Alacritty's
    macOS source; they haven't been measured on the Mac yet.
- **Rio picks font faces by style name and ignores `weight`.** Always use the exact face
  name, like `style = "Medium Italic"`.

## 2. Machine-local files

These live in `~/.config` on each machine and stay there: they are git-ignored and excluded
by both `sync_to_home.sh` and `sync_from_home.sh`.

| File | Purpose | macOS | Linux |
|---|---|---|---|
| `alacritty/os.toml` | Symlink to this OS's settings, made by `sync_to_home.sh` | → `os/macos.toml` | → `os/linux.toml` |
| `alacritty/local.toml` | Optional overrides for this machine only | none | none |
| `nvim/lazy-lock.json` | Plugin versions pinned on this machine | own copy | own copy |
| `nvim/CLAUDE.md` | Claude Code notes for the Neovim config | own, if any | own, if any |
| `nnn/sessions/`, `nnn/bookmarks/`, `nnn/.lastd`, `nnn/mounts` | nnn state | own | own |
| `tmux/plugins/` | Plugins installed by TPM | own | own |

**Alacritty's `local.toml`** is loaded after `os.toml` (see [Alacritty](#alacritty)), so it
can override anything there on one machine. To try the other installed font on one
machine, for example Monaspace Neon on Linux (use `IosevkaTerm Nerd Font Mono` on the Mac):

```toml
[font.normal]
family = "MonaspiceNe Nerd Font Mono"
[font.bold]
family = "MonaspiceNe Nerd Font Mono"
[font.italic]
family = "MonaspiceNe Nerd Font Mono"
[font.bold_italic]
family = "MonaspiceNe Nerd Font Mono"
```

Delete `local.toml` to go back. An older `local.toml` that sets font faces (the Mac had one
for FiraCode before the OS files existed) overrides the OS files the same way, so delete it.

The lock file is ignored by choice, so the two machines can run different plugin
versions. To make one machine match the other, copy its `lazy-lock.json` over and run
`:Lazy restore`.

## 3. Per-machine setup

### Outside the repo, needed on both machines

- **`~/.tmux.conf`** with the single line `source-file ~/.config/tmux/tmux.conf`.
- **TPM**: `git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm`, then
  `prefix + I` inside tmux (or `~/.config/tmux/plugins/tpm/bin/install_plugins` outside it).
- **vimwiki HTML template**: `~/.dotfiles/vimwiki_conf/templates_html/GitHub.html5`. It
  isn't in this repo; copy it from the Mac.
- **vimwiki export script**: `Work/Notes/vimwiki/wiki2html_zsh.sh` in Google Drive. It needs
  `zsh` and `pandoc`. Auto-export on save switches itself off on a machine that is missing
  `pandoc` or the template.
- **Julia LanguageServer**: install it once per machine, into the shared environment:
  `julia --project=@nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'`.
  Julia 1.13 needs LanguageServer 6 or newer. Older versions use `SymbolServer` 7, which
  fails to precompile on 1.13 (`KeyError: key :_apply not found`), so the server exits
  right after it starts. After every Julia minor upgrade (1.12 to 1.13 and so on), update
  the environment:
  `julia --project=@nvim-lspconfig -e 'using Pkg; Pkg.Registry.update(); Pkg.update()'`.
  Don't add `SymbolServer` or `StaticLint` to the environment yourself: a direct
  dependency keeps the old version and blocks the update. On Linux, Arch's `julia`
  package changes minor version during an ordinary `pacman -Syu`, so check julials after
  big updates. Projects don't need LanguageServer. Each project only needs its own
  dependencies installed (`Pkg.instantiate()`) so the server can index them.
- **Sage**: either `sage` on `PATH`, or a venv at `~/.python_envs/sage`.
- **Shell config** (`.zshrc`: conda, starship init, nnn variables) isn't in this repo.

### Packages

| Needed for | macOS (Homebrew) | EndeavourOS (pacman / AUR) |
|---|---|---|
| Editor (Neovim 0.12 or newer: the julials `cmd` function needs it) | `neovim` | `neovim` |
| Neovim system clipboard (`clipboard=unnamedplus`) | built in | `wl-clipboard` (Wayland) or `xclip` (X11) |
| Treesitter parsers (main branch compiles them) | `tree-sitter-cli`, Xcode command-line tools | `tree-sitter-cli`, `base-devel` |
| telescope-fzf-native (`make`) | Xcode command-line tools | `base-devel` |
| Mason (installs clangd, texlab, pylsp, julials) | `curl`, `unzip`, `git`, Python 3 | same |
| LaTeX | `mactex` (cask) | `texlive-basic`, `texlive-latex`, `texlive-binextra` (latexmk) |
| PDF viewer | `skim` (cask) | `zathura`, `zathura-pdf-mupdf`; `xdotool` only on X11 |
| vimwiki export | `pandoc` | `pandoc-cli` |
| Julia | `juliaup` | `julia` (or `juliaup` from the AUR) |
| Terminal | Alacritty (the Homebrew cask is disabled; install by hand), `rio` (cask) | `alacritty`, `rio` |
| Fonts (Alacritty and Rio) | `font-monaspice-nerd-font`; alternative `font-iosevka-term-nerd-font` | `ttf-iosevkaterm-nerd`; alternative `otf-monaspace-nerd` |
| Telescope search | `ripgrep`, `fd` | `ripgrep`, `fd` |
| Sage REPL | venv at `~/.python_envs/sage` | `sagemath` |
| Cadabra REPL | `cadabra2` | `cadabra2` (AUR) |
| Shell tools | `tmux`, `starship`, `nnn` | `tmux`, `starship`, `nnn` |

## Differences that remain

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
  A sysimage only works with the Julia and package versions it was built from, so rebuild
  it after an update if you start using it.
- **Leftover on both machines:** `~/.config/alacritty/alacritty.yml` (the deprecated YAML
  config). `sync_to_home.sh` deletes it because it isn't in the repo; until then,
  `sync_from_home.sh` would copy it back in.

## Syncing

- **Pull changes onto a machine:** `git pull`, then `./sync_to_home.sh --dry-run` to
  preview, then `./sync_to_home.sh`. It backs up the affected folders to
  `~/.backup/config-<timestamp>/` first (creating `~/.backup` if needed), links
  Alacritty's `os.toml` for this OS, and writes Rio's `config.toml` with this OS's values.
- **After editing in `~/.config`:** run `./sync_from_home.sh`, review `git diff`, then
  commit and push.
- **Components:** `alacritty`, `nnn`, `nvim`, `rio`, `tmux`, `starship`. Name one or
  more to sync only those, like `./sync_to_home.sh --dry-run rio`. When syncing
  everything, `sync_from_home.sh` skips a component that isn't installed (like `rio` on a
  machine without it); naming a missing one is an error.
- **New machine-local file in a synced folder:** add it to the excludes in *both* sync
  scripts and to `.gitignore`. Otherwise `sync_to_home.sh` deletes it (it syncs with
  `--delete`) and `sync_from_home.sh` copies it into the repo.

## Checklist when adding something

- [ ] No `/Users/...`, `/home/...`, `/opt/homebrew/...` or `/usr/local/...` paths. Use `~`
      or look the tool up on `PATH`.
- [ ] macOS-only tools (`pbcopy`, `open`, `osascript`, Skim) and Linux-only ones
      (`xdg-open`, `wl-copy`, `xdotool`) sit behind an OS check.
- [ ] Alacritty settings that differ per OS go in `os/macos.toml` / `os/linux.toml`, never
      also in `alacritty.toml` (it would override them). One-machine experiments go in
      `local.toml`. In Rio, anything that differs goes in `[platform.macos]` /
      `[platform.linux]` if Rio supports it there, otherwise on a `# macos:` line.
- [ ] Any new package is added to the table above for both systems.
