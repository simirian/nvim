-- simirian's NeoVim
-- lines settings for statusline and tabline

local settings = require("settings")

return {
  "nvim-contour",
  dev = true,
  config = function()
    local contour = require("contour")
    local c = require("contour.components")

    -- refresh tabline every minute
    vim.fn.timer_start(60000, function()
      vim.cmd.redrawtabline()
    end, { ["repeat"] = -1 })

    -- set how buffers are displayed
    c.Buf.default_name = "U.N. Owen"
    c.Buf.modified_icon = settings.icons.dot
    c.Buf.show_bufnr = true

    contour.statusline.setup { mode = 2, {
      --- @format disable
      -- left filetype
      { "%2* %y %*", left = true, min_width = 15 },
      -- center file name and modified
      "%=",
      c.Buf { modified_icon = settings.icons.dot },
      "%=",
      -- right position
      { "%2* %l,%c ", min_width = 15 },
      --- @format enable
    } }

    contour.tabline.setup { mode = 2, {
      highlight = "TabLine",
      -- cwd
      "%1* %{fnamemodify(getcwd(), ':t')} | %{strftime('%H:%M')} ",
      "%#TabLineFill#%=",
      c.TabBufs { close_icon = settings.icons.cross },
    } }
  end
}
