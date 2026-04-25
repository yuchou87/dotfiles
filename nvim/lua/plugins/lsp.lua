-- LSP setup: mason + nvim-lspconfig
-- Languages covered: Go / TypeScript / Vue / React / Python / YAML /
--                    Bash / .env / Dockerfile / docker-compose
-- Rust LSP is owned by rustaceanvim (see lang-rust.lua) — don't setup here.
return {
  -- Mason: package manager for LSP servers, formatters, linters
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts  = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "gopls",                              -- Go
        "vtsls",                              -- TS / JS / React (handles JSX/TSX + Vue plugin)
        "vue_ls",                             -- Vue 3 (Volar)
        "pyright",                            -- Python type-check
        "ruff",                               -- Python linter + formatter LSP
        "yamlls",                             -- YAML + SchemaStore
        "bashls",                             -- Shell + .env (mapped via vim.filetype.add)
        "dockerls",                           -- Dockerfile
        "docker_compose_language_service",    -- docker-compose.yml schema LSP
      },
    },
  },

  -- Mason-installed CLI tools (formatters / linters)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "goimports", "gofumpt",
        "prettierd",
        "shfmt", "shellcheck",
        "hadolint",
        "markdownlint",
      },
      run_on_start = true,
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local lsp  = require("lspconfig")
      local caps = require("blink.cmp").get_lsp_capabilities()

      -- Register hurl-lsp (testmind-hq/hurl-lsp, not yet in lspconfig registry).
      -- Binary comes from `brew install testmind-hq/tap/hurl-lsp`.
      local lsp_configs = require("lspconfig.configs")
      if not lsp_configs.hurl_lsp then
        lsp_configs.hurl_lsp = {
          default_config = {
            cmd                 = { "hurl-lsp" },
            filetypes           = { "hurl" },
            -- vim.fs.root is the modern API (nvim 0.10+), nil-safe.
            -- Falls back to cwd when buffer isn't inside a git repo.
            root_dir            = function(fname)
              return vim.fs.root(fname, { ".git" }) or vim.fn.getcwd()
            end,
            single_file_support = true,
          },
        }
      end

      -- Vue 3 hybrid mode: vtsls handles .vue via @vue/typescript-plugin
      local vue_ls_pkg = vim.fn.stdpath("data") ..
        "/mason/packages/vue-language-server/node_modules/@vue/language-server"

      local servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt        = true,
              staticcheck    = true,
              usePlaceholders = true,
              analyses       = { unusedparams = true, shadow = true },
              hints = {
                assignVariableTypes    = true,
                compositeLiteralFields = true,
                constantValues         = true,
                parameterNames         = true,
                rangeVariableTypes     = true,
              },
            },
          },
        },

        vtsls = {
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = { {
                  name             = "@vue/typescript-plugin",
                  location         = vue_ls_pkg,
                  languages        = { "vue" },
                  configNamespace  = "typescript",
                } },
              },
            },
          },
          filetypes = {
            "javascript", "javascriptreact",
            "typescript", "typescriptreact",
            "vue",
          },
        },

        vue_ls = {
          init_options = { vue = { hybridMode = false } },
        },

        pyright = {
          settings = { python = { analysis = { typeCheckingMode = "basic" } } },
        },
        ruff = {},

        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = true,
                url    = "https://www.schemastore.org/api/json/catalog.json",
              },
              schemas = {
                ["https://json.schemastore.org/github-workflow"] = "/.github/workflows/*",
                ["https://json.schemastore.org/docker-compose"]  = "docker-compose*.{yml,yaml}",
                ["https://json.schemastore.org/kustomization"]   = "kustomization.yaml",
              },
            },
          },
        },

        bashls   = { filetypes = { "sh", "bash", "zsh", "env" } },
        dockerls = {},
        docker_compose_language_service = {
          filetypes = { "yaml.docker-compose" },
        },
      }

      -- Custom server: only register + setup when the binary is on PATH.
      -- Otherwise lspconfig spawns the missing binary on every .hurl open
      -- and floods diagnostics with "command not found".
      -- Install: ./install.sh --with-extras  (brew tap testmind-hq/tap)
      if vim.fn.executable("hurl-lsp") == 1 then
        servers.hurl_lsp = {}
      end

      for name, opts in pairs(servers) do
        opts.capabilities = caps
        lsp[name].setup(opts)
      end

      -- LSP keymaps (bound on attach)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local b = { buffer = ev.buf }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,    b)
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,    b)
          vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,b)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,         b)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,        b)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,   b)
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,  b)
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,  b)
          vim.keymap.set("n", "<leader>e",  vim.diagnostic.open_float, b)
        end,
      })
    end,
  },
}
