-- simirian's NeoVim
-- treesitter settings

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()
    vim.api.nvim_create_autocmd("FileType", {
      desc = "Enable treesitter in supported buffers.",
      callback = function() pcall(vim.treesitter.start) end,
    })
  end
}
