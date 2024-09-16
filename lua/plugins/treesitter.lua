-- simirian's NeoVim
-- treesitter settings

return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-manager" },
  opts = {
    sync_install = false,
    auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
      disable = { "markdown" },
    },
  },
  config = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    local installed = vim.tbl_map(function(e)
      return vim.fn.fnamemodify(e, ":t:r")
    end, vim.api.nvim_get_runtime_file("parser/*", true))
    for _, spec in pairs(require("nvim-manager.workspaces").list()) do
      for _, ft in ipairs(spec.filetypes) do
        if not vim.tbl_contains(opts.ensure_installed, ft)
            and not vim.tbl_contains(installed, ft)
        then
          table.insert(opts.ensure_installed, ft)
        end
      end
    end
    require("nvim-treesitter.configs").setup(opts)
  end
}
