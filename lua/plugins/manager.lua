-- simirian's NeoVim
-- nvim-manager config

return {
  "nvim-manager",
  lazy = false,
  priority = 900,
  dev = true,
  config = function(_, opts)
    local workspaces = require("nvim-manager.workspaces")
    workspaces.setup()
    local projects = require("nvim-manager.projects")
    projects.setup()
  end
}
