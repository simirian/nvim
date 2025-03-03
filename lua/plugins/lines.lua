-- simirian's NeoVim
-- lines icons for statusline and tabline

local icons = require("icons")

-- statusline components
local buffer = {
  "buffer",
  items = { "typeicon", "filename", "bufnr", "modified" },
  default_name = "U.N. Owen",
  modified_icon = icons.shapes.dot,
}
local diagnostics = {
  "diagnostics",
  highlights = {
    default = "User2",
  },
  icons = {
    error = icons.diagnostic.error,
    warn = icons.diagnostic.warning,
    info = icons.diagnostic.info,
    hint = icons.diagnostic.hint,
    default = icons.diagnostic.status,
  },
}
local ruler = {
  "raw",
  item = "%#User2# %l/%L %v ",
}

-- tabline components
local dirclock = {
  "raw",
  item = "%#User1# %{fnamemodify(getcwd(), ':t')} | %{strftime('%H:%M')} ",
}
local tabbufs = {
  "tab",
  items = { "buflist" },
  buflist = {
    buffer = {
      items = { "typeicon", "filename" },
      default_name = "U.N. Owen",
    },
  },
  highlight_sel = "TabLine",
}
local tablist = {
  "tablist",
  tab = {
    "tab",
    modified_icon = icons.shapes.dot,
  },
}

return {
  "nvim-contour",
  dev = true,
  opts = {
    statusline = {
      default = {
        "space",
        highlight = "StatusLineNC",
        items = {
          diagnostics,
          buffer,
          ruler,
        },
      },
    },
    tabline = {
      default = {
        "space",
        highlight = "TabLine",
        items = {
          dirclock,
          tabbufs,
          tablist,
        },
      },
    },
  },
}
