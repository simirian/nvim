-- simirian's NeoVim
-- pretty basic telescope config

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter",
  },
  -- load when used
  cmd = { "Telescope" },
  keys = { "<leader>ff", "<leader>fg", "<leader>fb", "<leader>fh" },
  config = function()
    require("telescope").setup{ }
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { })
    -- TODO: chache pickers for picker picker
    --vim.keymap.set("n", "<leader>ft", builtin.pickers, { })
  end,
}

