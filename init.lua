-- simirian's NeoVim

-- require all the basic configs for file editing
vim.cmd.colorscheme("yicks")
-- this will set the settings metatable to the current environment
require("settings").setup()
require("opts")
require("keys").setup()
require("commands")
require("lazy-init")
