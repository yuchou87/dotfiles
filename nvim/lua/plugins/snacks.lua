-- snacks.nvim — modern all-in-one utility suite by folke.
-- Includes: picker (file/grep/buffers), terminal, lazygit integration,
-- notifier, bufdelete, words (highlight instances), input.
--
-- Pickers replace telescope.nvim. Terminal/lazygit replace toggleterm.nvim.
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy     = false,
    opts = {
      picker     = { enabled = true },   -- :Snacks picker.* / fuzzy finder
      terminal   = { enabled = true },   -- floating / split terminals
      lazygit    = { enabled = true },   -- :Snacks.lazygit() inside nvim
      notifier   = { enabled = true, timeout = 3000 },
      bufdelete  = { enabled = true },   -- close buffer without breaking layout
      words      = { enabled = true },   -- highlight other instances of word under cursor
      input      = { enabled = true },   -- prettier vim.ui.input
      quickfile  = { enabled = true },   -- render large files faster
      bigfile    = { enabled = true },   -- disable expensive features on huge files
      statuscolumn = { enabled = false }, -- skip: subjective
      dashboard  = { enabled = false },  -- skip: style preference, can opt in later
    },
    keys = {
      -- File / project navigation
      { "<leader>ff", function() Snacks.picker.files()         end, desc = "Find files" },
      { "<leader>fg", function() Snacks.picker.grep()          end, desc = "Live grep" },
      { "<leader>fb", function() Snacks.picker.buffers()       end, desc = "Buffers" },
      { "<leader>fr", function() Snacks.picker.recent()        end, desc = "Recent files" },
      { "<leader>fh", function() Snacks.picker.help()          end, desc = "Help tags" },
      { "<leader>fc", function() Snacks.picker.commands()      end, desc = "Commands" },
      { "<leader>fk", function() Snacks.picker.keymaps()       end, desc = "Keymaps" },
      { "<leader>fd", function() Snacks.picker.diagnostics()   end, desc = "Diagnostics" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols()   end, desc = "LSP symbols" },
      { "<leader>/",  function() Snacks.picker.lines()         end, desc = "Grep current buffer" },
      { "<leader>:",  function() Snacks.picker.command_history() end, desc = "Command history" },

      -- Terminal
      { "<leader>tt", function() Snacks.terminal()             end, desc = "Toggle terminal (float)" },

      -- lazygit (within nvim, useful when you don't want to leave editor)
      { "<leader>gg", function() Snacks.lazygit()              end, desc = "Lazygit" },

      -- Buffer
      { "<leader>bd", function() Snacks.bufdelete()            end, desc = "Delete buffer (keep window)" },

      -- Word navigation (uses words module: jump between instances)
      { "]]", function() Snacks.words.jump( 1, true) end, desc = "Next word reference",     mode = { "n", "t" } },
      { "[[", function() Snacks.words.jump(-1, true) end, desc = "Previous word reference", mode = { "n", "t" } },
    },
  },
}
