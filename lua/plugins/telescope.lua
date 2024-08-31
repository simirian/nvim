-- simirian's NeoVim
-- telescope config

local icons = require("icons")

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter",
    "nvim-manager",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    telescope.setup {
      defaults = {
        prompt_prefix = " " .. icons.telescope .. "  ",
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
    keys.telescope = {
      { "<leader>ff", builtin.find_files, desc = "[f]ind [f]iles" },
      { "<leader>fg", builtin.live_grep,  desc = "[f]ind [g]rep" },
      { "<leader>fb", builtin.buffers,    desc = "[f]ind [b]uffer" },
      { "<leader>fh", builtin.help_tags,  desc = "[f]ind [h]elp" },
    }
    -- find projects with nvim manager
    if pcall(require, "nvim-manager") then
      table.insert(keys.telescope,
        { "<leader>fp", telescope.extensions.projects.projects, desc = "[f]ind [p]rojects" })
    end
    keys.setup("telescope")
  end,
}
