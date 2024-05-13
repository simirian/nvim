-- simirian's NeoVim
-- treesitter settings

-- TODO: language module system

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
    autopairs = {
      enable = true,
    },
  },
  config = function(_, opts)
    opts.ensure_installed = require("nvim-manager.workspaces").ts_fts()
    require("nvim-treesitter.configs").setup(opts)

    vim.opt.foldmethod = "indent"
    --vim.opt.foldmethod = "expr"
    --vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldlevelstart = 999999
    vim.opt.foldnestmax = 4
    vim.opt.foldtext = ""
  end
}
