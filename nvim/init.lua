-- ~/.config/nvim/init.lua
-- Reference: https://github.com/yuchou87/learning/blob/main/topics/engineering/terminal-dev-toolkit.md

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.lazy")
