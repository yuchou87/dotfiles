-- lazy.nvim bootstrap + plugin auto-import from lua/plugins/
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
}, {
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true, notify = false },
  ui      = { border = "rounded" },
  change_detection = { notify = false },
})
