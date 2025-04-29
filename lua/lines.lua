-- lua statusline and tabline
-- by simirian

local icons = require("icons")

local M = {}
local H = {}

function H.icon(fname)
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    return devicons.get_icon(fname, fname:match("%.([^%.]+)$"), { default = true })
  end
end

H.ns = vim.api.nvim_create_namespace("LinesHighlight")
H.augroup = vim.api.nvim_create_augroup("Lines", { clear = false })
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  desc = "Update statusline diagnostics.",
  group = H.augroup,
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

--- Renders diagnostic information for the statusline.
--- @param bufnr integer The buffer to render diagnostics for.
--- @return string statusline
--- @return integer width
function H.diagnostics(bufnr)
  local diagnostics = vim.diagnostic.get(bufnr)
  -- error, warn, info, hint
  local counts = { 0, 0, 0, 0 }
  for _, diagnostic in ipairs(diagnostics) do
    counts[diagnostic.severity] = counts[diagnostic.severity] + 1
  end
  if counts[1] == 0 and counts[2] == 0 and counts[3] == 0 and counts[4] == 0 then
    return "%#User2# " .. icons.diagnostic.status .. " 0 ", 5
  else
    local str = "%#User2# "
    local width = 1
    for s, c in ipairs(counts) do
      if c > 0 then
        str = str .. icons.diagnostic[({
          "error",
          "warning",
          "info",
          "hint"
        })[s]] .. " " .. c .. " "
        width = width + 4
      end
    end
    return str, width
  end
end

--- Gets a string to represent a buffer in the status line.
--- @param bufnr integer The buffer to render a string for.
--- @param current boolean if the buffer should be rendered as currently active.
--- @return string statusline
--- @return integer width
function H.buffer(bufnr, current)
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  local hl = current and "StatusLine" or "StatusLineNC"
  local fname = vim.fs.basename(bufname)
  local icon, icohl = H.icon(fname)
  if not fname or fname == "" then
    fname = "U.N. Owen"
  end
  local fg = vim.api.nvim_get_hl(0, { name = icohl }).fg
  if not fg then
    fg = vim.api.nvim_get_hl(0, { name = current and "StatusLine" or "StatusLineNC" }).fg
  end
  vim.api.nvim_set_hl(0, "LineIco" .. bufnr, {
    fg = ("#%06x"):format(fg),
    bg = ("#%06x"):format(vim.api.nvim_get_hl(0, { name = hl }).bg),
  })
  local modified = vim.bo[bufnr].modified and " " .. icons.shapes.dot or ""

  icon = icon .. " "
  fname = fname .. " "
  local width = vim.fn.strwidth(icon .. fname .. bufnr .. modified) + 2
  return ("%%#%s# %s%%#%s#%s%d%s "):format("LineIco" .. bufnr, icon, hl, fname, bufnr, modified), width
end

--- Renderd the current buffer position for the statusline.
--- @param winid integer The window to render the statusline for.
--- @return string statusline
--- @return integer width
function H.ruler(winid)
  local stl = " %l/%L %c "
  local width = vim.api.nvim_eval_statusline(stl, { winid = winid }).width
  return "%#User2#" .. stl, width
end

--- Statusline generating function.
--- @return string statusline
function M.statusline()
  local winid = vim.g.statusline_winid
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local width = vim.api.nvim_win_get_width(winid)
  local hl = bufnr == vim.api.nvim_get_current_buf() and "%#StatusLine#" or "%##"

  local left, lwidth = H.diagnostics(bufnr)
  local center, cwidth = H.buffer(bufnr, winid == vim.api.nvim_get_current_win())
  local right, rwidth = H.ruler(winid)

  local lspace = (" "):rep(math.floor((width - cwidth) / 2) - lwidth)
  local rspace = (" "):rep(width - rwidth - math.ceil((width + cwidth) / 2))
  return left .. hl .. lspace .. center .. hl .. rspace .. right
end

--- Generates a directory and clock string for the tabline.
--- @return string tabline
--- @return integer width
function H.dirclock()
  --- uv does exist and have the function cwd()
  --- @diagnostic disable-next-line: undefined-field
  local str = "%#User1# " .. vim.fs.basename(vim.loop.cwd()) .. vim.fn.strftime(" | %H:%M ")
  local eval = vim.api.nvim_eval_statusline(str, { use_tabline = true })
  return str, eval.width
end

--- Renders a list of the current vim tabs for the tabline.
--- @return string tabline
--- @return integer width
function H.tablist()
  local str = ""
  local width = 0
  local curtab = vim.api.nvim_get_current_tabpage()
  for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
    str = str .. (curtab == tabnr and "%#TabLineSel#" or "%#TabLine#") .. " " .. tabnr .. " "
    width = width + 3
    for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
      local bufnr = vim.api.nvim_win_get_buf(winnr)
      if vim.bo[bufnr].modified then
        str = str .. icons.shapes.dot .. " "
        width = width + 2
        break
      end
    end
  end
  return str, width
end

--- Tabline generating function.
--- @return string tabline
function M.tabline()
  local left, lwidth = H.dirclock()
  local right, rwidth = H.tablist()

  return left .. "%#TabLineFill#" .. (" "):rep(vim.o.columns - lwidth - rwidth) .. right
end

vim.o.statusline = "%!v:lua.require'lines'.statusline()"
vim.o.laststatus = 2
vim.o.tabline = "%!v:lua.require'lines'.tabline()"
vim.o.showtabline = 2

local timer = vim.loop.new_timer()
timer:start(61000 - os.date("*t").sec * 1000, 60000, function()
  vim.schedule(function()
    vim.cmd.redrawstatus()
    vim.cmd.redrawtabline()
  end)
end)

return M
