# dotfiles

个人终端工具链配置。当前包含一套用 [lazy.nvim](https://github.com/folke/lazy.nvim)
管理的 Neovim 配置,覆盖主流语言 LSP 与 Markdown 实时渲染。

> Other languages: [English](./README.md)

## 仓库结构

```
dotfiles/
├── install.sh                    # 依赖检查 + symlink 安装脚本
├── nvim/                         # → ~/.config/nvim
│   ├── init.lua
│   └── lua/
│       ├── config/{lazy,options,keymaps}.lua
│       └── plugins/
│           ├── lsp.lua           # mason + nvim-lspconfig (9 个 LSP)
│           ├── completion.lua    # blink.cmp
│           ├── treesitter.lua    # 22 个 parser
│           ├── format-lint.lua   # conform.nvim + nvim-lint
│           ├── md-render.lua     # delphinus/md-render.nvim
│           ├── snacks.lua        # 文件搜索 / 终端 / lazygit / 通知
│           ├── dap.lua           # nvim-dap + 适配器 (Go / Python / JS-TS)
│           └── lang-rust.lua     # rustaceanvim
├── ghostty/                      # → ~/.config/ghostty
│   └── config                    # Kitty graphics 已开(md-render 显示图片)
├── zsh/                          # 可选 shell 别名(不自动 source)
│   └── aliases.zsh               # gt / lg / v
└── README.md / README.zh-CN.md
```

## 快速上手

```bash
# 1. 克隆
git clone https://github.com/yuchou87/dotfiles.git ~/Github/yuchou87/dotfiles
cd ~/Github/yuchou87/dotfiles

# 2. 仅检查依赖状态(不安装)
./install.sh --check

# 3. 安装。脚本会:
#    a. 检查依赖,缺失的提示用 brew 安装(macOS)
#    b. symlink nvim/ → ~/.config/nvim(已存在的旧配置自动备份)
#    c. 检测到 lazygit 时,提示是否把 nvim 设为默认编辑器
./install.sh

# 4. 启动 Neovim,lazy.nvim 自动引导并同步插件
nvim

# 5. 等 :Lazy 全绿后,验证:
#    :checkhealth      (mason / lsp / treesitter / dap 段)
#    :Mason            (所有 LSP / 工具已装)
#    :LspInfo          (当前 buffer 的 LSP 状态)
```

## 系统要求

`./install.sh --check` 会逐项报告下列依赖状态,在 macOS 上自动用
`brew install` 帮你装缺的。

| 级别 | 工具                | 用途                                              |
|------|---------------------|---------------------------------------------------|
| 必装 | `nvim` ≥ 0.10       | md-render.nvim 最低版本                           |
| 必装 | `git`               | lazy.nvim 拉插件                                  |
| 推荐 | `ripgrep` (`rg`)    | Snacks 全局 grep + Treesitter selectoid           |
| 推荐 | `fd`                | 快速文件查找                                      |
| 推荐 | `lazygit`           | `<leader>gg` 在 nvim 内开 lazygit                 |
| 推荐 | `fzf`               | Snacks 模糊匹配后端                                |
| 推荐 | `node`              | Vue language server / mermaid-cli / js-debug      |
| 推荐 | `helix` (`hx`)      | 备用编辑器(lazygit ↔ helix 工作流)              |
| 推荐 | `ghostty`           | 终端 + Kitty graphics(md-render 显示图片需要)     |
| 推荐 | JetBrainsMono Nerd Font | Snacks / blink.cmp / DAP UI 图标渲染          |
| 推荐 | Sarasa Term SC Nerd | Ghostty 配置的中日韩字体回退(手动装,见下)       |
| 推荐 | `gh`                | GitHub CLI — 终端里管 PR / Issue / Release        |
| 推荐 | `glow`              | 独立 Markdown 终端渲染器(`glow README.md`)       |
| 可选 | `ffmpeg`            | md-render 图片格式转换                            |
| 可选 | `imagemagick`       | md-render 图片格式转换                            |
| 可选 | `@mermaid-js/mermaid-cli` (`mmdc`) | md-render Mermaid 图渲染            |

### 可选层级(`--with-extras`、`--with-langs`)

默认**不**提示。加 flag 才会进检查 + 安装流程。

#### `--with-extras` — 现代 CLI 替代品

| 工具      | 替代                    | 优势                                            |
|-----------|-------------------------|-------------------------------------------------|
| `bat`     | `cat`                   | 语法高亮、行号、自动分页                        |
| `eza`     | `ls`                    | 彩色、git 状态、`eza -T` 树形视图               |
| `delta`   | `git diff` pager        | 双栏 diff、语法高亮                             |
| `zoxide`  | `cd`                    | 智能跳目录(`z foo` 跳到最近用过的 foo)        |
| `jq`      | (无替代)                | JSON 万能处理器                                 |
| `yq`      | (无替代)                | YAML / TOML / XML 处理器,YAML 版的 jq          |
| `tldr`    | `man`                   | 社区维护的命令实例速查                          |
| `btm`     | `top` / `htop`          | 资源监控(bottom),图表 + 鼠标支持              |

#### `--with-langs` — 语言工具链

| 工具    | 用途                                                                   |
|---------|------------------------------------------------------------------------|
| `go`    | Go 编译器 (`go run / build / test`)                                    |
| `rust`  | rustc + cargo(Rust toolchain via brew)                                |
| `zig`   | Zig 编译器                                                             |
| `pnpm`  | npm 兼容的包管理器,更快、磁盘占用更少                                 |
| `bun`   | 一体化 JS 运行时 + 包管理器                                            |
| `fnm`   | 快速 node 版本管理器(Rust 写),替代 nvm                              |
| `mise`  | **万用版本管理器**,统管 go / node / python / rust / zig / ...         |

如果你已经用 `mise` 统管所有语言,可以只装 mise 跳过其他 — `mise install`
按项目自动配版本。这个表是"brew 装什么",不是"你日常用什么"。

`install.sh` 自动安装的内容:

- 上表所有 `必装` + `推荐` 项(通过 `brew install` / `brew install --cask` /
  `npm install -g`)
- 可选项目仅报告状态,需自行安装

`install.sh` 故意**不**接管的:

- **语言工具链** (Go / Rust / Python) — 按项目按需安装
- **把 Nerd Font 设为终端字体** — Ghostty 的字体已在 `ghostty/config`
  里指定(自动生效)。其他终端需要手动在 Preferences 选
  `JetBrainsMono Nerd Font`
- **Sarasa Term SC Nerd 字体** — `ghostty/config` 用它做中日韩回退,
  不在 Homebrew 主仓。安装方式:
  ```bash
  brew tap laishulu/homebrew
  brew install --cask laishulu/homebrew/font-sarasa-nerd
  ```
  或从 <https://github.com/laishulu/Sarasa-Mono-Nerd> 直接下载。
  不装的话,Ghostty 中文会回落到 JetBrainsMono(缺中文字形,显示成方块)。

需要你**显式确认**才会做的(默认拒绝,安全护栏):

- **追加 `source` 行到 `~/.zshrc` / `~/.bashrc`** — 脚本检测 `$SHELL`
  自动选目标 rc 文件,默认答案是 **N**(拒绝)。如果你输 `y`:
  - 原 rc 文件备份成 `<rc>.bak.YYYYMMDD-HHMMSS`
  - 追加一个有 marker 的 block:
    ```
    # >>> dotfiles aliases >>>
    source /path/to/dotfiles/zsh/aliases.zsh
    # <<< dotfiles aliases <<<
    ```
  - 重复跑是幂等的 — marker 检测到就跳过
  - 想撤回:删 block + 从备份恢复
- **lazygit 编辑器配置** — 同样 opt-in。默认 **Y**(低风险:
  无配置时新建文件,有配置时只打印片段不动)

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

## install.sh 命令行参数

| 参数              | 作用                                                                  |
|-------------------|-----------------------------------------------------------------------|
| (无)              | 默认。检查依赖 → 提示装缺的 → symlink 配置 → lazygit + shell rc 提示。 |
| `--check`         | 仅做依赖报告。必装齐全 exit 0,缺则 exit 1。                          |
| `--skip-deps`     | 跳过依赖检查/安装。CI 或依赖另外管理时用。                            |
| `--skip-lazygit`  | 跳过"把 nvim 设为 lazygit 编辑器"的提示。                             |
| `--skip-aliases`  | 跳过"追加 source 行到 ~/.zshrc / ~/.bashrc"的提示。                   |
| `--with-extras`   | 加上**现代 CLI 工具**(`bat / eza / delta / zoxide / jq / yq / tldr / btm`)。 |
| `--with-langs`    | 加上**语言工具链**(`go / rust / zig / pnpm / bun / fnm / mise`)。   |
| `--copy`          | 拷贝而不是 symlink。改 repo 不会同步到 ~/.config。                    |
| `--force`         | 覆盖现有目标(不备份)。                                              |
| `--dry-run`       | 仅打印每一步动作。                                                    |
| `-h` / `--help`   | 查看帮助。                                                            |

如果 `~/.config/nvim` 已存在,默认会自动备份成
`~/.config/nvim.bak.YYYYMMDD-HHMMSS`,除非加 `--force`。

重复跑同一个 module 是**幂等的** — symlink 已正确指向时安装步骤跳过。

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

## License

MIT — 见 [LICENSE](./LICENSE)。
