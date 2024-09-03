-- simirian's NeoVim
-- lines icons for statusline and tabline

local vfn = vim.fn
local icons = require("icons")

-- plugin {{{1
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

    -- buffer {{{2
    buf.default_name = "U.N. Owen"
    buf.modified_icon = icons.dot
    buf.show_bufnr = true

    -- statusline {{{2
    contour.statusline.setup("always", {
      -- left filetype
      {
        highlight = "StatusLine",
        left = true,
        min_width = 15,
        c.diagnostics {
          icons = {
            error = icons.error,
            warn  = icons.warning,
            info  = icons.info,
            hint  = icons.hint,
            base  = icons.diagnostics,
          },
          highlight = 2,
        },
      },
      -- center file name and modified
      "%=",
      buf { modified_icon = icons.dot },
      "%=",
      -- right position
      { "%2* %l,%c ", min_width = 15 },
    })

    -- tabline {{{2
    contour.tabline.setup("always", {
      highlight = "TabLine",
      -- cwd
      "%1* %{fnamemodify(getcwd(), ':t')} | %{strftime('%H:%M')} ",
      "%#TabLineFill#%=",
      c.tabbufs { close_icon = icons.cross },
    })
  end
}
-- vim:fdm=marker
