-- Treesitter: syntax highlighting + structural selection
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main  = "nvim-treesitter.configs",
    opts  = {
      ensure_installed = {
        -- Go
        "go", "gomod", "gosum", "gowork",
        -- TypeScript / JS / Vue / React
        "typescript", "tsx", "javascript", "vue",
        -- Rust
        "rust",
        -- Python
        "python",
        -- Config / Data
        "yaml", "json", "toml",
        -- Shell
        "bash",
        -- Container
        "dockerfile",
        -- Docs
        "markdown", "markdown_inline",
        -- Editor / Web
        "lua", "vim", "vimdoc",
        "html", "css", "scss",
        "regex", "gitignore", "gitcommit",
        "hurl",
      },
      highlight = { enable = true },
      indent    = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = "gnn",
          node_incremental  = "grn",
          scope_incremental = "grc",
          node_decremental  = "grm",
        },
      },
    },
  },
}
