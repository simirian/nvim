-- simirian's NeoVim
-- telescope config

local icons = require("icons")

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
        prompt_prefix = " " .. icons.shapes.telescope .. "  ",
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
    local keys = require("keymaps")
    keys.add("telescope", {
      { "<leader>ff", builtin.find_files, desc = "[f]ind [f]iles",  mode = "n" },
      { "<leader>fg", builtin.live_grep,  desc = "[f]ind [g]rep",   mode = "n" },
      { "<leader>fb", builtin.buffers,    desc = "[f]ind [b]uffer", mode = "n" },
      { "<leader>fh", builtin.help_tags,  desc = "[f]ind [h]elp",   mode = "n" },
    })
    keys.bind("telescope")
  end,
}
