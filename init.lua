-- simirian's NeoVim

-- require all the basic configs for file editing
vim.cmd("colorscheme habamax")
require("opts")
require("keys").setup()
require("commands")
require("lazy-init")
