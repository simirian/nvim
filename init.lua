-- simirian's NeoVim

-- require all the basic configs for file editing
vim.cmd("colorscheme habamax")
require("opts")
require("keys")
require("commands")
require("lazy-init")

-- setup workspace, if one is detected then the associated language server
-- will be set up as well.
require("languages").get_workspace()

