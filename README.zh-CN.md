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
│           ├── snacks.lua        # 文件搜索 / 终端 / lazygit / 通知 (folke/snacks.nvim)
│           ├── dap.lua           # nvim-dap + dap-ui + 适配器 (Go/Python/JS-TS)
│           └── lang-rust.lua     # rustaceanvim (Rust LSP + DAP via codelldb)
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

## 调试支持(DAP)

首次启动时 Mason 自动安装下列适配器:

| 语言     | 适配器             | 启动方式                                                                |
|----------|--------------------|-------------------------------------------------------------------------|
| Go       | delve              | 打开 `.go` → `<F5>`,nvim-dap-go 自动识别 test/main 配置。              |
| Python   | debugpy            | 打开 `.py` → `<F5>`,nvim-dap-python 自动配置。                         |
| JS / TS  | js-debug-adapter   | 打开 `.ts/.js` → `<F5>` 在 Node 下启动当前文件。                        |
| Rust     | codelldb           | rustaceanvim 自动管理。打断点后 `:RustLsp debuggables` 选目标。         |

DAP UI 在调试启动时自动弹出(变量 / 作用域 / 断点 / 调用栈 / REPL / 控制台
面板),终止时自动关闭。手动 toggle 用 `<leader>du`。

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

### 编辑器

| 模式 | 按键              | 动作                          |
|------|-------------------|-------------------------------|
| n    | `<leader>w`       | 保存                          |
| n    | `<leader>q`       | 退出                          |
| n    | `<C-h/j/k/l>`     | 窗口跳转                      |
| n    | `gnn / grn / grm` | Treesitter 增量选择           |

### LSP

| 模式 | 按键              | 动作                          |
|------|-------------------|-------------------------------|
| n    | `gd / gr / gi`    | 跳定义 / 查引用 / 查实现      |
| n    | `K`               | 悬浮文档                      |
| n    | `<leader>rn`      | 重命名                        |
| n    | `<leader>ca`      | Code action                   |
| n    | `[d / ]d`         | 上一个 / 下一个诊断           |
| n    | `<leader>e`       | 诊断浮窗                      |

### Snacks(搜索 / 终端 / Git)

| 模式 | 按键           | 动作                                      |
|------|----------------|-------------------------------------------|
| n    | `<leader>ff`   | 找文件                                    |
| n    | `<leader>fg`   | 全局 grep                                 |
| n    | `<leader>fb`   | Buffer 列表                               |
| n    | `<leader>fr`   | 最近文件                                  |
| n    | `<leader>fh`   | 帮助 tag                                  |
| n    | `<leader>fc`   | 命令                                      |
| n    | `<leader>fk`   | 快捷键                                    |
| n    | `<leader>fd`   | 诊断列表                                  |
| n    | `<leader>fs`   | LSP 符号                                  |
| n    | `<leader>/`    | 当前 buffer 内 grep                       |
| n    | `<leader>:`    | 命令历史                                  |
| n    | `<leader>tt`   | 浮窗终端 toggle                           |
| n    | `<leader>gg`   | lazygit(在 nvim 里)                       |
| n    | `<leader>bd`   | 关闭 buffer(保留窗口)                     |
| n,t  | `]] / [[`      | 下/上一个相同词出现位置                   |

### 调试(nvim-dap)

| 模式 | 按键           | 动作                                      |
|------|----------------|-------------------------------------------|
| n    | `<F5>`         | 继续 / 启动                               |
| n    | `<F10>`        | 单步跨越                                  |
| n    | `<F11>`        | 单步进入                                  |
| n    | `<F12>`        | 单步退出                                  |
| n    | `<leader>db`   | 切换断点                                  |
| n    | `<leader>dB`   | 条件断点                                  |
| n    | `<leader>dr`   | 打开 REPL                                 |
| n    | `<leader>dl`   | 重跑上次配置                              |
| n    | `<leader>dx`   | 终止                                      |
| n    | `<leader>du`   | DAP UI 面板 toggle                        |
| n,v  | `<leader>de`   | 求值光标处 / 选区                         |

### Markdown

| 模式 | 按键           | 动作                          |
|------|----------------|-------------------------------|
| n    | `<leader>mp`   | Markdown 预览(toggle)         |
| n    | `<leader>mt`   | Markdown 预览(新 tab)         |
| n    | `<leader>md`   | md-render demo                |

## 设计说明

详细的技术决策和取舍:
[learning/topics/engineering/terminal-dev-toolkit.md](https://github.com/yuchou87/learning/blob/main/topics/engineering/terminal-dev-toolkit.md)

## License

MIT — 见 [LICENSE](./LICENSE)。
