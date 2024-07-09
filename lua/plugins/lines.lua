-- simirian's NeoVim
-- lines settings for statusline and tabline

local vfn = vim.fn
local settings = require("settings")

return {
  "nvim-contour",
  dev = true,
  config = function()
    local contour = require("contour")
    local c = require("contour.components")
    local buf = c.buffer

    -- refresh tabline every minute
    vfn.timer_start(60000, function()
      vim.cmd.redrawtabline()
    end, { ["repeat"] = -1 })

    -- set how buffers are displayed
    buf.default_name = "U.N. Owen"
    buf.modified_icon = settings.icons.dot
    buf.show_bufnr = true

    contour.statusline.setup("always", {
      -- left filetype
      {
        highlight = "StatusLine",
        left = true,
        min_width = 15,
        c.diagnostics {
          icons = {
            error = settings.icons.error,
            warn = settings.icons.warning,
            info = settings.icons.info,
            hint = settings.icons.hint,
            base = settings.icons.diagnostics,
          },
          highlight = 2,
        },
      },
      -- center file name and modified
      "%=",
      buf { modified_icon = settings.icons.dot },
      "%=",
      -- right position
      { "%2* %l,%c ", min_width = 15 },
    })

    contour.tabline.setup("always", {
      highlight = "TabLine",
      -- cwd
      "%1* %{fnamemodify(getcwd(), ':t')} | %{strftime('%H:%M')} ",
      "%#TabLineFill#%=",
      c.tabbufs { close_icon = settings.icons.cross },
    })
  end
}
