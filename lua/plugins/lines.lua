-- simirian's NeoVim
-- lines icons for statusline and tabline

local vfn = vim.fn
local icons = require("icons")

-- plugin {{{1
return {
  "nvim-contour",
  dev = true,
  opts = {
    -- buffer {{{2
    buffer = {
      filetype = "icon",
      default_name = "U.N. Owen",
      modified_icon = icons.dot,
      show_bufnr = true,
    },
    -- buffer list {{{2
    buflist = {
      modified_icon = false,
      show_bufnr = false,
      filter = function(bufnr)
        local bi = vfn.getbufinfo(bufnr)[1]
        return bi.listed == 1 and bi.loaded == 1 and bi.hidden ~= 1
            and vim.tbl_contains(vfn.tabpagebuflist(vfn.tabpagenr()), bufnr)
      end,
    },
    tablist = {
      modified_icon = icons.dot,
      close_icon = icons.cross,
    },
    -- diagnostics {{{2
    diagnostics = {
      highlight = {
        error = "ContourError",
        warn  = "ContourWarn",
        info  = "ContourInfo",
        hint  = "ContourHint",
        base  = "User2",
      },
      icons = {
        error = icons.error,
        warn  = icons.warning,
        info  = icons.info,
        hint  = icons.hint,
        base  = icons.diagnostics,
      },
    },
    -- statusline {{{2
    show_statusline = "always",
    statusline = {
      highlight = "",
      {
        highlight = "",
        left = true,
        min_width = 10,
        { component = "diagnostics" },
      },
      "%=",
      { component = "buffer" },
      "%=",
      { "%#User2# %l,%c ", min_width = 10 },
    },
    -- tabline {{{2
    show_tabline = "always",
    tabline = {
      highlight = "tablinefill",
      {
        left = true,
        min_width = 30,
        "%1* %{fnamemodify(getcwd(), ':t')} | %{strftime('%H:%M')} %*",
      },
      "%=",
      { component = "buflist" },
      "%=",
      {
        min_width = 30,
        { component = "tablist" },
      },
    },
  },
}
-- vim:fdm=marker
