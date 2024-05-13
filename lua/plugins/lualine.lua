-- simirian's NeoVim
-- lualine settings for a nice tabline and statusline

local settings = require("settings")

local diagnostic_component = {
  "diagnostics",
  sources = { "nvim_lsp" },
  symbols = {
    error = settings.icons.error .. " ",
    warn  = settings.icons.warning .. " ",
    info  = settings.icons.information .. " ",
    hint  = settings.icons.hint .. " ",
  },
  always_visible = true,
}

local file_section = {
  {
    "filetype",
    colored = true,
    icon_only = true,
    icon = { align = "right" },
    separator = "",
  },
  {
    "filename",
    file_status = true,
    newfile_status = false,
    path = 4,
    shorting_target = 40,
    symbols = {
      modified = settings.icons.dot,
      readonly = settings.icons.lock,
      unnamed  = settings.icons.null,
      newfile  = settings.icons.circle,
    },
    separator = "",
    padding = 0,
  },
  "fileformat",
}

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      icons_enabled = true,
      theme = "auto",
      --  
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { "alpha", "dashboard", "Outline" },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = true,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      },
    },
    -- inclue empty space to override the defaults
    sections = {
      lualine_a = { "mode" },
      lualine_b = { { "branch", icon = settings.icons.branch } },
      lualine_c = { "diff" },
      lualine_x = {},
      lualine_y = { "encoding" },
      lualine_z = { "progress", "location" },
    },
    winbar = {
      lualine_a = {},
      lualine_b = file_section,
      lualine_c = { diagnostic_component },
    },
    inactive_winbar = {
      lualine_a = {},
      lualine_b = file_section,
      lualine_c = {},
    },
    tabline = {
      lualine_a = {
        {
          "buffers",
          show_filename_only = true,
          hide_filename_extension = false,
          show_modified_status = true,
          mode = 0,
          -- set buffers to 3/4 screen width
          max_length = vim.o.columns * 3 / 4,
          filetype_names = {
            TelescopePrompt = "Telescope",
            dashboard = "Dashboard",
            packer = "Packer",
            fzf = "FZF",
            alpha = "Alpha",
            lazy = "Lazy",
            mason = "Mason",
            lspinfo = "LSP",
            checkhealth = "Health",
          },
          symbols = {
            modified = settings.icons.dot,
            alternate_file = "",
            directory =settings.icons.floder_close,
          },
        },
      },
      lualine_z = {
        {
          'tabs',
          tab_max_length = 40,
          -- set tabs to 1/4 screen width
          max_length = vim.o.columns / 4,
          mode = 0,
          path = 0,
          show_modified_status = true,
          symbols = { modified = settings.icons.dot},
        }
      }
    },
    extensions = {
      {
        filetypes = { "NvimTree" },
        sections = {
          lualine_a = { function() return "~ nvim-tree" end },
        },
        winbar = {},
        inactive_winbar = {},
      },
      {
        filetypes = { "checkhealth" },
        sections = {},
        winbar = {
          lualine_c = { "filetype" },
        },
        inactive_winbar = {
          lualine_c = { function() return "~ checkhealth" end },
        },
        inactive_sections = {},
      },
    },
  },
}
