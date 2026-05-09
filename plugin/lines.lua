-- simirian's Neovim
-- status and tab line plugin

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

  local left = ""
  if next(vim.lsp.get_clients { bufnr = bufnr }) then
    left = vim.diagnostic.status(bufnr)
  else
    left = "%#User2#" .. (vim.wo[winid].spell and "  " or "  ") .. "%{wordcount().words} %*"
  end

  local fname = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
  local ico, hl = require("icons").get(fname)
  local bufname = vim.b[bufnr].bufname or "%t"
  local center = " %#" ..hl .. "#" .. ico .. " %*" .. bufname .. " %n " .. (vim.bo[bufnr].modified and " " or "") .. "%*"

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

local timer = vim.uv.new_timer()
if timer then
  timer:start(61000 - os.date("*t").sec * 1000, 60000, vim.schedule_wrap(function()
    vim.cmd.redrawstatus()
    vim.cmd.redrawtabline()
  end))
end

--- Tabline generating function.
--- @return string tabline
function Tabline()
  local left = "%#User1# " .. vim.fs.basename(vim.uv.cwd()) .. os.date(" | %R ")

  local right = ""
  local curtab = vim.api.nvim_get_current_tabpage()
  for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
    local tabnr = vim.api.nvim_tabpage_get_number(tabid)
    if tabid == curtab then
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
