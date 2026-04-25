# dotfiles

Personal terminal toolchain config. Currently shipping a Neovim setup
managed by [lazy.nvim](https://github.com/folke/lazy.nvim) with broad
language support and live Markdown rendering.

> Other languages: [中文](./README.zh-CN.md)

## What's inside

```
dotfiles/
├── install.sh                    # idempotent symlink installer
├── nvim/                         # → ~/.config/nvim
│   ├── init.lua
│   └── lua/
│       ├── config/
│       │   ├── lazy.lua          # lazy.nvim bootstrap
│       │   ├── options.lua       # vim.opt.* + filetype overrides
│       │   └── keymaps.lua       # global keys (LSP keys live in plugins/lsp.lua)
│       └── plugins/
│           ├── lsp.lua           # mason + nvim-lspconfig (9 LSPs)
│           ├── completion.lua    # blink.cmp
│           ├── treesitter.lua    # 22 parsers
│           ├── format-lint.lua   # conform.nvim + nvim-lint
│           ├── md-render.lua     # delphinus/md-render.nvim
│           ├── snacks.lua        # picker / terminal / lazygit / notifier (folke/snacks.nvim)
│           ├── dap.lua           # nvim-dap + dap-ui + adapters (Go/Python/JS-TS)
│           └── lang-rust.lua     # rustaceanvim (Rust LSP + DAP via codelldb)
└── README.md / README.zh-CN.md
```

## Quick start

```bash
# 1. Clone
git clone https://github.com/yuchou87/dotfiles.git ~/Github/yuchou87/dotfiles
cd ~/Github/yuchou87/dotfiles

# 2. Preview what install.sh will do
./install.sh --dry-run

# 3. Install (symlinks into ~/.config)
./install.sh

# 4. Launch Neovim — lazy.nvim auto-bootstraps and syncs plugins
nvim

# 5. After :Lazy reports all green, verify:
#    :checkhealth      (mason / lsp / treesitter sections)
#    :Mason            (all servers/tools installed)
#    :LspInfo          (per-buffer LSP status)
```

## Requirements

- **Neovim ≥ 0.10** (md-render.nvim requirement) — `brew install neovim`
- **Nerd Font** for icons — `brew install --cask font-jetbrains-mono-nerd-font`
- **ripgrep + fd** — `brew install ripgrep fd`
- **Node.js, Go, Rust, Python** for the language toolchains you actually use
- **Kitty graphics protocol terminal** for md-render image/Mermaid display:
  Ghostty, WezTerm, or Kitty. iTerm2 / macOS Terminal fall back to plain text.
- **md-render extras (optional)**: `brew install ffmpeg imagemagick && npm i -g @mermaid-js/mermaid-cli`

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

## Install modes

| Mode      | Command                       | Notes                                      |
|-----------|-------------------------------|--------------------------------------------|
| Symlink   | `./install.sh`                | Default. `git pull` updates take effect immediately. |
| Copy      | `./install.sh --copy`         | One-shot copy. Edits to repo do **not** propagate. |
| Force     | `./install.sh --force`        | Overwrites existing target (no backup).    |
| Dry run   | `./install.sh --dry-run`      | Print actions only.                        |

Existing config is auto-backed up to `~/.config/nvim.bak.YYYYMMDD-HHMMSS`
unless `--force` is given.

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

## Reference

Design notes and rationale:
[learning/topics/engineering/terminal-dev-toolkit.md](https://github.com/yuchou87/learning/blob/main/topics/engineering/terminal-dev-toolkit.md)

## License

MIT — see [LICENSE](./LICENSE).
