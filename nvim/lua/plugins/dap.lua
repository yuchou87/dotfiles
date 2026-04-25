-- DAP (Debug Adapter Protocol) setup.
-- Languages: Go (delve), Python (debugpy), JS/TS (js-debug-adapter).
-- Rust DAP is owned by rustaceanvim (codelldb auto-managed) — see lang-rust.lua.
return {
  -- Core
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",                -- nvim-dap-ui requirement
      "jay-babu/mason-nvim-dap.nvim",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<F5>",        function() require("dap").continue()          end, desc = "DAP continue / start" },
      { "<F10>",       function() require("dap").step_over()         end, desc = "DAP step over" },
      { "<F11>",       function() require("dap").step_into()         end, desc = "DAP step into" },
      { "<F12>",       function() require("dap").step_out()          end, desc = "DAP step out" },
      { "<leader>db",  function() require("dap").toggle_breakpoint() end, desc = "DAP toggle breakpoint" },
      { "<leader>dB",  function()
          require("dap").set_breakpoint(vim.fn.input("Condition: "))
        end, desc = "DAP conditional breakpoint" },
      { "<leader>dr",  function() require("dap").repl.open()         end, desc = "DAP REPL" },
      { "<leader>dl",  function() require("dap").run_last()          end, desc = "DAP run last config" },
      { "<leader>dx",  function() require("dap").terminate()         end, desc = "DAP terminate" },
      { "<leader>du",  function() require("dapui").toggle()          end, desc = "DAP UI toggle" },
      { "<leader>de",  function() require("dapui").eval()            end, desc = "DAP eval expression",
        mode = { "n", "v" } },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      -- UI
      dapui.setup()
      require("nvim-dap-virtual-text").setup({ commented = true })

      -- Auto-open / close DAP UI on session start / stop
      dap.listeners.before.attach.dapui_config           = function() dapui.open() end
      dap.listeners.before.launch.dapui_config           = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config     = function() dapui.close() end

      -- Mason: install adapters for Go / Python / JS-TS
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "delve",                -- Go
          "debugpy",              -- Python
          "js-debug-adapter",     -- JS / TS
        },
        automatic_installation = true,
        handlers = {},            -- use defaults, customized per-adapter below
      })

      -- Go: nvim-dap-go integrates delve with debug-test / debug-package shortcuts
      require("dap-go").setup({
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
      })

      -- Python: debugpy install path managed by Mason
      local mason_path = vim.fn.stdpath("data") .. "/mason"
      require("dap-python").setup(mason_path .. "/packages/debugpy/venv/bin/python")

      -- JS / TS (Node): js-debug-adapter from Mason
      local js_debug_path = mason_path .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args    = { js_debug_path, "${port}" },
        },
      }
      for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[lang] = {
          {
            type     = "pwa-node",
            request  = "launch",
            name     = "Launch current file",
            program  = "${file}",
            cwd      = "${workspaceFolder}",
            sourceMaps = true,
          },
          {
            type     = "pwa-node",
            request  = "attach",
            name     = "Attach to running Node",
            processId = require("dap.utils").pick_process,
            cwd      = "${workspaceFolder}",
          },
        }
      end

      -- Visual: red breakpoints, stopped marker
      vim.fn.sign_define("DapBreakpoint",
        { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped",
        { text = "→", texthl = "DiagnosticWarn",  linehl = "Visual", numhl = "" })
    end,
  },

  -- Go-specific extra (test debugging shortcuts)
  -- nvim-dap-go is also a dep above; the module exposes `:DapGoTest` etc.
}
