# dotfiles

Personal terminal toolchain config. Currently shipping a Neovim setup
managed by [lazy.nvim](https://github.com/folke/lazy.nvim) with broad
language support and live Markdown rendering.

> Other languages: [中文](./README.zh-CN.md)

## What's inside

```
dotfiles/
├── install.sh                    # dependency check + symlink installer
├── nvim/                         # → ~/.config/nvim
│   ├── init.lua
│   └── lua/
│       ├── config/{lazy,options,keymaps}.lua
│       └── plugins/
│           ├── lsp.lua           # mason + nvim-lspconfig (9 LSPs)
│           ├── completion.lua    # blink.cmp
│           ├── treesitter.lua    # 22 parsers
│           ├── format-lint.lua   # conform.nvim + nvim-lint
│           ├── md-render.lua     # delphinus/md-render.nvim
│           ├── snacks.lua        # picker / terminal / lazygit / notifier
│           ├── dap.lua           # nvim-dap + adapters (Go / Python / JS-TS)
│           └── lang-rust.lua     # rustaceanvim
├── ghostty/                      # → ~/.config/ghostty
│   └── config                    # Kitty graphics enabled (md-render images)
├── zsh/                          # opt-in shell aliases (not auto-sourced)
│   └── aliases.zsh               # gt / lg / v
└── README.md / README.zh-CN.md
```

## Quick start

```bash
# 1. Clone
git clone https://github.com/yuchou87/dotfiles.git ~/Github/yuchou87/dotfiles
cd ~/Github/yuchou87/dotfiles

# 2. Inspect dependency status (no install)
./install.sh --check

# 3. Install. Will:
#    a. Check deps; prompt to brew-install missing ones (macOS)
#    b. Symlink nvim/ -> ~/.config/nvim (auto-backups existing config)
#    c. If lazygit found: prompt to set Neovim as its default editor
./install.sh

# 4. Launch Neovim — lazy.nvim auto-bootstraps and syncs plugins
nvim

# 5. After :Lazy reports all green, verify:
#    :checkhealth      (mason / lsp / treesitter / dap sections)
#    :Mason            (all servers/tools installed)
#    :LspInfo          (per-buffer LSP status)
```

## Requirements

`./install.sh --check` reports the status of every dep below and
prompts to `brew install` whatever is missing on macOS.

| Tier        | Tool                | Why                                            |
|-------------|---------------------|------------------------------------------------|
| required    | `nvim` ≥ 0.10       | md-render.nvim minimum                         |
| required    | `git`               | lazy.nvim clones plugins from GitHub           |
| recommended | `ripgrep` (`rg`)    | Snacks live grep + Treesitter selectoid        |
| recommended | `fd`                | Fast file finder                               |
| recommended | `lazygit`           | `<leader>gg` integration in Neovim             |
| recommended | `fzf`               | Snacks fuzzy backend                           |
| recommended | `node`              | Vue language server / mermaid-cli / js-debug   |
| recommended | `helix` (`hx`)      | Alternative editor (lazygit ↔ helix workflow)  |
| recommended | `ghostty`           | Terminal w/ Kitty graphics (md-render images)  |
| recommended | JetBrainsMono Nerd Font | Icons in Snacks / blink.cmp / DAP UI       |
| optional    | `ffmpeg`            | md-render image format conversion              |
| optional    | `imagemagick`       | md-render image format conversion              |
| optional    | `@mermaid-js/mermaid-cli` (`mmdc`) | md-render Mermaid diagram render |

Auto-installed by `install.sh`:

- All `required` + `recommended` items above (via `brew install` /
  `brew install --cask` / `npm install -g`).
- For optional items, `install.sh --check` reports their status and
  you can install manually.

Not handled by `install.sh` (intentional):

- **Language toolchains** (Go / Rust / Python) — install per-project on demand.
- **Setting Nerd Font as terminal font** — open your terminal preferences
  and pick `JetBrainsMono Nerd Font` after install.
- **Modifying `~/.zshrc`** — `zsh/aliases.zsh` is provided but you must
  `source` it manually (the script tells you how).

## Language support

| Language        | LSP                                       | Formatter            | Linter         |
|-----------------|-------------------------------------------|----------------------|----------------|
| Go              | gopls                                     | gofumpt + goimports  | gopls built-in |
| TypeScript / JS | vtsls                                     | prettierd            | tsserver       |
| React (TSX/JSX) | vtsls                                     | prettierd            | tsserver       |
| Vue 3           | vue_ls + vtsls + @vue/typescript-plugin   | prettierd            | vtsls          |
| Rust            | rust-analyzer (via rustaceanvim)          | rustfmt              | rust-analyzer  |
| Python          | pyright + ruff                            | ruff_format          | ruff           |
| YAML            | yamlls + SchemaStore                      | prettierd            | yamlls         |
| Shell           | bashls                                    | shfmt                | shellcheck     |
| `.env`          | bashls (mapped via `vim.filetype.add`)    | —                    | —              |
| Dockerfile      | dockerls                                  | —                    | hadolint       |
| docker-compose  | docker_compose_language_service           | prettierd            | yamlls schema  |
| Markdown        | —                                         | prettierd            | markdownlint   |

## Debugging (DAP)

Adapters auto-installed via Mason on first launch:

| Language     | Adapter            | How to start                                                            |
|--------------|--------------------|-------------------------------------------------------------------------|
| Go           | delve              | Open a `.go` file → `<F5>`. nvim-dap-go infers test/main config.        |
| Python       | debugpy            | Open a `.py` file → `<F5>`. nvim-dap-python infers config.              |
| JS / TS      | js-debug-adapter   | Open a `.ts/.js` file → `<F5>` to launch the file under Node.           |
| Rust         | codelldb           | rustaceanvim handles automatically. Set breakpoint, `:RustLsp debuggables`. |

DAP UI auto-opens on session start (panels for variables / scopes / breakpoints
/ stack / repl / console) and closes on terminate. Toggle manually with
`<leader>du`.

## install.sh flags

| Flag              | Effect                                                                |
|-------------------|-----------------------------------------------------------------------|
| (none)            | Default. Check deps → prompt to install missing → symlink configs → lazygit setup. |
| `--check`         | Dependency report only. Exit 0 if all required present, 1 otherwise.  |
| `--skip-deps`     | Skip dependency check / install. Useful in CI or when deps are managed elsewhere. |
| `--skip-lazygit`  | Skip the "set Neovim as lazygit editor" prompt.                       |
| `--copy`          | Copy instead of symlink. Edits to repo do **not** propagate.          |
| `--force`         | Overwrite existing target (no backup).                                |
| `--dry-run`       | Print every action without executing.                                 |
| `-h` / `--help`   | Show help.                                                            |

Existing config at `~/.config/nvim` is auto-backed up to
`~/.config/nvim.bak.YYYYMMDD-HHMMSS` unless `--force` is given.

Re-running with the same module is **idempotent** — when the symlink already
points to the right place, the install step is a no-op.

## Key bindings (top-level)

`<leader>` is `Space`.

### Editor

| Mode | Keys              | Action                       |
|------|-------------------|------------------------------|
| n    | `<leader>w`       | Save                         |
| n    | `<leader>q`       | Quit                         |
| n    | `<C-h/j/k/l>`     | Window navigation            |
| n    | `gnn / grn / grm` | Treesitter incremental sel.  |

### LSP

| Mode | Keys              | Action                       |
|------|-------------------|------------------------------|
| n    | `gd / gr / gi`    | Definition / refs / impl     |
| n    | `K`               | Hover documentation          |
| n    | `<leader>rn`      | Rename symbol                |
| n    | `<leader>ca`      | Code action                  |
| n    | `[d / ]d`         | Prev / next diagnostic       |
| n    | `<leader>e`       | Diagnostic float             |

### Snacks (picker / terminal / git)

| Mode | Keys           | Action                                    |
|------|----------------|-------------------------------------------|
| n    | `<leader>ff`   | Find files                                |
| n    | `<leader>fg`   | Live grep                                 |
| n    | `<leader>fb`   | Buffers                                   |
| n    | `<leader>fr`   | Recent files                              |
| n    | `<leader>fh`   | Help tags                                 |
| n    | `<leader>fc`   | Commands                                  |
| n    | `<leader>fk`   | Keymaps                                   |
| n    | `<leader>fd`   | Diagnostics                               |
| n    | `<leader>fs`   | LSP symbols                               |
| n    | `<leader>/`    | Grep current buffer                       |
| n    | `<leader>:`    | Command history                           |
| n    | `<leader>tt`   | Toggle floating terminal                  |
| n    | `<leader>gg`   | Lazygit (inside Neovim)                   |
| n    | `<leader>bd`   | Delete buffer (keep window)               |
| n,t  | `]] / [[`      | Next / prev word reference (highlight)    |

### Debugging (nvim-dap)

| Mode | Keys           | Action                                    |
|------|----------------|-------------------------------------------|
| n    | `<F5>`         | Continue / start                          |
| n    | `<F10>`        | Step over                                 |
| n    | `<F11>`        | Step into                                 |
| n    | `<F12>`        | Step out                                  |
| n    | `<leader>db`   | Toggle breakpoint                         |
| n    | `<leader>dB`   | Conditional breakpoint                    |
| n    | `<leader>dr`   | Open REPL                                 |
| n    | `<leader>dl`   | Run last config                           |
| n    | `<leader>dx`   | Terminate                                 |
| n    | `<leader>du`   | Toggle DAP UI                             |
| n,v  | `<leader>de`   | Eval expression under cursor / selection  |

### Markdown

| Mode | Keys           | Action                       |
|------|----------------|------------------------------|
| n    | `<leader>mp`   | Markdown preview (toggle)    |
| n    | `<leader>mt`   | Markdown preview in tab      |
| n    | `<leader>md`   | md-render demo               |

## License

MIT — see [LICENSE](./LICENSE).
