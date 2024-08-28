-- simirian's NeoVim
-- nvim-manager config

local vfn = vim.fn

return {
  "nvim-manager",
  dependencies = { "williamboman/mason.nvim" },
  priority = 900,
  dev = true,
  config = function()
    local workspaces = {}
    local fnames = vim.api.nvim_get_runtime_file("lua/workspaces/*.lua", true)
    for _, fname in ipairs(fnames) do
      local wsname = vfn.fnamemodify(fname, ":t:r")
      workspaces[wsname] = require("workspaces." .. wsname)
    end
    require("nvim-manager").setup{ workspaces = workspaces }
  end,
}
