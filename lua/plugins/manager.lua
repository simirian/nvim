-- simirian's NeoVim
-- nvim-manager config

return {
  "nvim-manager",
  lazy = false,
  priority = 900,
  dev = true,
  config = function()
    require("nvim-manager.workspaces").setup()
    require("nvim-manager.projects").setup()
  end
}
