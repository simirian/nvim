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
    opts.ensure_installed = opts.ensure_installed or {}
    for _, spec in pairs(require("nvim-manager.workspaces").list()) do
      for _, ft in ipairs(spec.filetypes) do
        if not vim.tbl_contains(opts.ensure_installed, ft) then
          table.insert(opts.ensure_installed, ft)
        end
      end
    end
    require("nvim-treesitter.configs").setup(opts)
  end
}
