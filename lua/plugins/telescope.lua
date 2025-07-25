-- simirian's NeoVim
-- telescope config

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    telescope.setup {
      defaults = {
        prompt_prefix = "   ",
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["jk"] = actions.close,
            ["kj"] = actions.close,
            ["<Esc>"] = actions.close,
          },
        },
      },
    }


    local builtin = require("telescope.builtin")
    vim.keymap.set("", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]iles" })
    vim.keymap.set("", "<leader>fg", builtin.live_grep, { desc = "[f]ind [g]rep" })
    vim.keymap.set("", "<leader>fb", builtin.buffers, { desc = "[f]ind [b]uffer" })
    vim.keymap.set("", "<leader>fh", builtin.help_tags, { desc = "[f]ind [h]elp" })
  end,
}
