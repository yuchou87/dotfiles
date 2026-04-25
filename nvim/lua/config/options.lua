-- General editor options
local o = vim.opt

o.number         = true
o.relativenumber = true
o.expandtab      = true
o.shiftwidth     = 2
o.tabstop        = 2
o.smartindent    = true
o.ignorecase     = true
o.smartcase      = true
o.termguicolors  = true
o.signcolumn     = "yes"
o.updatetime     = 250
o.clipboard      = "unnamedplus"
o.scrolloff      = 4
o.splitright     = true
o.splitbelow     = true
o.cursorline     = true
o.undofile       = true

-- Filetype overrides for ambiguous files
vim.filetype.add({
  extension = {
    hurl = "hurl",
  },
  filename = {
    [".env"]                = "sh",
    ["docker-compose.yml"]  = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
  },
  pattern = {
    ["%.env%..*"] = "sh", -- .env.local / .env.production / etc.
  },
})
