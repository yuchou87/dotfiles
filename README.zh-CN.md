# dotfiles

个人终端工具链配置。当前包含一套用 [lazy.nvim](https://github.com/folke/lazy.nvim)
管理的 Neovim 配置,覆盖主流语言 LSP 与 Markdown 实时渲染。

> Other languages: [English](./README.md)

## 仓库结构

```
dotfiles/
├── install.sh                    # 幂等的 symlink 安装脚本
├── nvim/                         # → ~/.config/nvim
│   ├── init.lua
│   └── lua/
│       ├── config/
│       │   ├── lazy.lua          # lazy.nvim 引导
│       │   ├── options.lua       # vim.opt.* + filetype 覆盖
│       │   └── keymaps.lua       # 全局快捷键(LSP 快捷键在 plugins/lsp.lua)
│       └── plugins/
│           ├── lsp.lua           # mason + nvim-lspconfig (9 个 LSP)
│           ├── completion.lua    # blink.cmp
│           ├── treesitter.lua    # 22 个 parser
│           ├── format-lint.lua   # conform.nvim + nvim-lint
│           ├── md-render.lua     # delphinus/md-render.nvim
│           └── lang-rust.lua     # rustaceanvim
└── README.md / README.zh-CN.md
```

## 快速上手

```bash
# 1. 克隆
git clone https://github.com/yuchou87/dotfiles.git ~/Github/yuchou87/dotfiles
cd ~/Github/yuchou87/dotfiles

# 2. 预览 install.sh 会做什么
./install.sh --dry-run

# 3. 安装(symlink 到 ~/.config)
./install.sh

# 4. 启动 Neovim,lazy.nvim 自动引导并同步插件
nvim

# 5. 等 :Lazy 全绿后,验证:
#    :checkhealth      (mason / lsp / treesitter 段)
#    :Mason            (所有 LSP / 工具已装)
#    :LspInfo          (当前 buffer 的 LSP 状态)
```

## 系统要求

- **Neovim ≥ 0.10** (md-render.nvim 要求) — `brew install neovim`
- **Nerd Font** 显示图标 — `brew install --cask font-jetbrains-mono-nerd-font`
- **ripgrep + fd** — `brew install ripgrep fd`
- **Node.js / Go / Rust / Python** 按你实际用的语言装工具链
- **支持 Kitty graphics 协议的终端**(md-render 显示图片/Mermaid 需要):
  Ghostty / WezTerm / Kitty。iTerm2 / Terminal.app 会降级到纯文本预览。
- **md-render 可选依赖**: `brew install ffmpeg imagemagick && npm i -g @mermaid-js/mermaid-cli`

## 语言支持

| 语言            | LSP                                         | 格式化               | Linter         |
|-----------------|---------------------------------------------|----------------------|----------------|
| Go              | gopls                                       | gofumpt + goimports  | gopls 内建     |
| TypeScript / JS | vtsls                                       | prettierd            | tsserver       |
| React (TSX/JSX) | vtsls                                       | prettierd            | tsserver       |
| Vue 3           | vue_ls + vtsls + @vue/typescript-plugin     | prettierd            | vtsls          |
| Rust            | rust-analyzer (通过 rustaceanvim)           | rustfmt              | rust-analyzer  |
| Python          | pyright + ruff                              | ruff_format          | ruff           |
| YAML            | yamlls + SchemaStore                        | prettierd            | yamlls         |
| Shell           | bashls                                      | shfmt                | shellcheck     |
| `.env`          | bashls (通过 `vim.filetype.add` 映射 sh)    | —                    | —              |
| Dockerfile      | dockerls                                    | —                    | hadolint       |
| docker-compose  | docker_compose_language_service             | prettierd            | yamlls schema  |
| Markdown        | —                                           | prettierd            | markdownlint   |

## 安装模式

| 模式      | 命令                          | 说明                                       |
|-----------|-------------------------------|--------------------------------------------|
| Symlink   | `./install.sh`                | 默认。`git pull` 改动立即生效。           |
| Copy      | `./install.sh --copy`         | 一次性拷贝,改 repo 不会同步到 ~/.config。 |
| Force     | `./install.sh --force`        | 覆盖现有目标(不备份)。                  |
| Dry run   | `./install.sh --dry-run`      | 仅打印动作。                              |

如果 `~/.config/nvim` 已存在,默认会自动备份成
`~/.config/nvim.bak.YYYYMMDD-HHMMSS`,除非加 `--force`。

## 主要快捷键

`<leader>` 是 `Space`。

| 模式 | 按键              | 动作                          |
|------|-------------------|-------------------------------|
| n    | `<leader>w`       | 保存                          |
| n    | `<leader>q`       | 退出                          |
| n    | `<C-h/j/k/l>`     | 窗口跳转                      |
| n    | `gd / gr / gi`    | 跳定义 / 查引用 / 查实现      |
| n    | `K`               | 悬浮文档                      |
| n    | `<leader>rn`      | 重命名                        |
| n    | `<leader>ca`      | Code action                   |
| n    | `[d / ]d`         | 上一个 / 下一个诊断           |
| n    | `<leader>e`       | 诊断浮窗                      |
| n    | `<leader>mp`      | Markdown 预览(toggle)         |
| n    | `<leader>mt`      | Markdown 预览(新 tab)         |
| n    | `<leader>md`      | md-render demo                |
| n    | `gnn / grn / grm` | Treesitter 增量选择           |

## 设计说明

详细的技术决策和取舍:
[learning/topics/engineering/terminal-dev-toolkit.md](https://github.com/yuchou87/learning/blob/main/topics/engineering/terminal-dev-toolkit.md)

## License

MIT — 见 [LICENSE](./LICENSE)。
