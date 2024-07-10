-- simirian's NeoVim
-- treesitter settings

return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-manager" },
  opts = {
    sync_install = true,
    auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
  },
  config = function(_, opts)
    opts.ensure_installed = require("nvim-manager.workspaces").ts_fts()
    require("nvim-treesitter.configs").setup(opts)
  end
}
