-- lua statusline and tabline
-- by simirian

local function get_icon(fname)
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    return devicons.get_icon(fname, fname:match("[^%./\\]+$"), { default = true })
  end
  return "?", "Normal"
end

local augroup = vim.api.nvim_create_augroup("Lines", { clear = false })
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  desc = "Update statusline diagnostics.",
  group = augroup,
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

--- Statusline generating function.
--- @return string statusline
function Statusline()
  local winid = vim.g.statusline_winid
  local bufnr = vim.api.nvim_win_get_buf(winid)

  local left = "%#User2#"
  local stats = ""
  local counts = { 0, 0, 0, 0 }
  local icons = { "  ", "  ", "  ", " 󰌵 " }
  for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
    counts[diagnostic.severity] = counts[diagnostic.severity] + 1
  end
  for severity, count in ipairs(counts) do
    if count > 0 then
      stats = stats .. icons[severity] .. count
    end
  end
  if stats == "" then
    stats = "  0"
  end
  left = left .. stats .. " %*"

  local fname = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
  local ico, hl = get_icon(fname)
  vim.api.nvim_set_hl(0, "LineIco" .. bufnr, {
    fg = ("#%06x"):format(vim.api.nvim_get_hl(0, { name = hl }).fg or 0xffffff),
    bg = ("#%06x"):format(vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg or 0)
  })
  local center = " %#LineIco" .. bufnr .. "#" .. ico .. " %*%t %n " .. (vim.bo[bufnr].modified and " " or "") .. "%*"

  local right = "%#User2# %l/%L %c "

  local leftwidth = vim.api.nvim_eval_statusline(left, { winid = winid }).width
  local rightwidth = vim.api.nvim_eval_statusline(right, { winid = winid }).width
  if leftwidth > rightwidth then
    right = (" "):rep(leftwidth - rightwidth) .. right
  else
    left = left .. (" "):rep(rightwidth - leftwidth)
  end
  return left .. "%=" .. center .. "%=" .. right
end

--- @diagnostic disable-next-line: undefined-field
local timer = vim.loop.new_timer()
timer:start(61000 - os.date("*t").sec * 1000, 60000, function()
  vim.schedule(function()
    vim.cmd.redrawstatus()
    vim.cmd.redrawtabline()
  end)
end)

--- Tabline generating function.
--- @return string tabline
function Tabline()
  --- @diagnostic disable-next-line: undefined-field
  local left = "%#User1# " .. vim.fs.basename(vim.loop.cwd()) .. os.date(" | %H:%M ")

  local right = ""
  local curtab = vim.api.nvim_get_current_tabpage()
  for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
    if tabnr == curtab then
      right = right .. "%#TabLineSel# " .. tabnr .. " %#TabLine#"
    elseif right == "" then
      right = right .. "%#TabLine# " .. tabnr .. " "
    else
      right = right .. " " .. tabnr .. " "
    end
  end

  return left .. "%#TabLineFill#%=" .. right
end

vim.o.statusline = "%!v:lua.Statusline()"
vim.o.laststatus = 2
vim.o.tabline = "%!v:lua.Tabline()"
vim.o.showtabline = 2
