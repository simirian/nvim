-- simirian's NeoVim
-- telescope config

local settings = require("settings")

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
        prompt_prefix = " " .. settings.icons.telescope .. " ",
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

    -- find projects with nvim manager
    local mok = pcall(require, "nvim-manager")
    if mok then
      vim.keymap.set("n", "<leader>fp",
        telescope.extensions.projects.projects, {})
    end

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
    vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
    -- TODO: chache pickers for picker picker
    --vim.keymap.set("n", "<leader>ft", builtin.pickers, { })
  end,
}
