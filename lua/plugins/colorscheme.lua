-- simirian's neovim
-- colorschemes, loaded by lazy according to settings.lua

local settings = require("settings")

return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    enabled = settings.colorscheme == "kanagawa",
    config = function()
      vim.cmd("colorscheme " .. settings.colorscheme)
    end,
  },
  {
    "sainnhe/gruvbox-material",
    priority = 1000,
    enabled = settings.colorscheme == "gruvbox-material",
    config = function()
      vim.cmd("colorscheme " .. settings.colorscheme)
    end,
  },
}

