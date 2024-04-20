-- simirian's NeoVim
-- treesitter settings

-- TODO: language module system

return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    --TODO: make this ensure_installed list work better
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "bash" },
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
    require("nvim-treesitter.configs").setup(opts)
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldlevelstart = 999999
  end
}

