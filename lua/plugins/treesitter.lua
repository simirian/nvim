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
      callback = function()
        local language = vim.treesitter.language.get_lang(vim.bo.ft)
        if vim.api.nvim_get_runtime_file("parser/" .. language .. "*", false)[1] then
          vim.treesitter.start()
        end
      end,
    })
  end
}
