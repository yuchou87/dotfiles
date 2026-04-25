-- Markdown live rendering inside Neovim.
-- https://github.com/delphinus/md-render.nvim
--
-- Image / Mermaid display requires a terminal that supports the Kitty
-- graphics protocol — Ghostty, WezTerm, or Kitty.
-- iTerm2 / Terminal.app fall back to plain-text preview.
return {
  {
    "delphinus/md-render.nvim",
    version = "*",
    ft = { "markdown" },
    dependencies = {
      { "nvim-tree/nvim-web-devicons", version = "*" },
      { "delphinus/budoux.lua",        version = "*" },
    },
    keys = {
      { "<leader>mp", "<Plug>(md-render-preview)",     desc = "Markdown preview (toggle)" },
      { "<leader>mt", "<Plug>(md-render-preview-tab)", desc = "Markdown preview in tab (toggle)" },
      { "<leader>md", "<Plug>(md-render-demo)",        desc = "Markdown render demo" },
    },
  },
}
