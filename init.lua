--------------------------------------------------------------------------------
--                          simirian's NeoVim                                 --
--                                                          .O.       T.      --
--    .o888o. 8^88^8 8.   .8 8^88^8 888880. 8^88^8   .8.   | \OO.     TTT     --
--    88   ``   88   888o888   88   88   88   88   .8' '8. |  \OOO.   TTT     --
--    `^888o.   88   88 8 88   88   888888    88   88ooo88 |  |'OOOO. TTT     --
--    __   88   88   88   88   88   88   88   88   88```88 |  |  'OOOOTTT     --
--    `^888^` 8u88u8 88   88 8u88u8 88   88 8u88u8 88   88 |  |    'OOTTT     --
--                                                          '.|      'T'      --
--                       github.com/simirian/nvim                             --
--------------------------------------------------------------------------------

vim.cmd.colorscheme("yicks")
require("opts")
require("keymaps").bind("default")
require("commands")
require("lines")
require("lsp")
require("pairs")
require("fex")
require("lazy-init")
