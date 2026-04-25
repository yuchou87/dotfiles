-- Global keymaps. LSP keymaps live in plugins/lsp.lua (LspAttach autocmd).
local map = vim.keymap.set

-- File ops
map("n", "<leader>w", ":w<CR>",  { desc = "Save" })
map("n", "<leader>q", ":q<CR>",  { desc = "Quit" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left"  })
map("n", "<C-j>", "<C-w>j", { desc = "Window down"  })
map("n", "<C-k>", "<C-w>k", { desc = "Window up"    })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Clear search highlight
map("n", "<Esc>", ":nohlsearch<CR>", { silent = true })
