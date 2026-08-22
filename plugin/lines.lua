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

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local isterm = bufname:sub(1, 7) == "term://"
  local name = vim.b[bufnr].bufname or
      (isterm and vim.fs.normalize(bufname:match("^term://(.-)//")) or "%f")
  local ico, hl = unpack(vim.b[bufnr].icon or {})
  if not ico or not hl then
    if isterm then
      ico, hl = "", "IconLime"
    else
      ico, hl = require("icons").get(vim.fs.basename(bufname))
    end
  end
  local center = " %#" .. hl .. "#" .. ico .. " %*" .. name .. " %n " .. (vim.bo[bufnr].modified and " " or "") .. "%*"

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

local tablistbuf = vim.api.nvim_create_buf(false, true)
local ns = vim.api.nvim_create_namespace("lines")

vim.api.nvim_create_autocmd({ "TabNew", "TabEnter", "VimResized", "UIEnter" }, {
  desc = "Update tablines.",
  group = augroup,
  callback = function()
    local curtab = vim.api.nvim_get_current_tabpage()
    local tablist = vim.api.nvim_list_tabpages()

    local str = ""
    for i in ipairs(tablist) do
      str = str .. " " .. i .. " "
    end

    vim.api.nvim_buf_clear_namespace(tablistbuf, ns, 0, -1)
    vim.api.nvim_buf_set_lines(tablistbuf, 0, -1, false, { str })
    local last = 0
    for n, id in ipairs(tablist) do
      local first = last
      last = last + (n < 10 and 3 or 4)
      vim.api.nvim_buf_set_extmark(tablistbuf, ns, 0, first, {
        end_col = last,
        hl_group = id == curtab and "TabLineSel" or "TabLine",
      })
    end

    local config = {
      relative = "tabline",
      width = vim.fn.strdisplaywidth(str),
      height = 1,
      row = 0,
      col = vim.o.columns,
      anchor = "NE",
      hide = false,
      border = "none",
      style = "minimal",
      focusable = false,
    }
    if vim.t.tablinewin then
      vim.api.nvim_win_set_config(vim.t.tablinewin, config)
    else
      local openconfig = vim.tbl_extend("error", config, { win = vim.api.nvim_tabpage_list_wins(0)[0] })
      vim.t.tablinewin = vim.api.nvim_open_win(tablistbuf, false, openconfig)
    end
  end,
})

vim.o.statusline = "%!v:lua.Statusline()"
vim.o.laststatus = 2
vim.o.showtabline = 0
