-- simirian's Neovim
-- calendar plugin

vim.g.calendir = vim.g.calendir or vim.env.HOME .. "/Documents/calendir"

--- Opens the daily document for the specified time.
--- @param date osdateparam The date to open the file of.
local function open(date)
  local time = os.time(date)
  vim.fn.mkdir(vim.g.calendir .. os.date("/%Y/%m", time), "p")
  vim.cmd.edit(vim.g.calendir .. os.date("/%Y/%m/%d.md", time))
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines == 1 and lines[1] == "" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { os.date("# Daily %Y-%m-%d", time) --[[@as string]] })
  end
end

--- Attempts to get the date of the currently open calendir file. If the current
--- buffer isn't a calendir file, then returns nil.
--- @return osdateparam?
local function getcurrent()
  local path = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  local calendirpath = vim.fs.normalize(vim.g.calendir)
  if path:find(calendirpath) ~= 1 then return end
  local year, month, day = path:match("(%d%d%d%d)/(%d%d)/(%d%d)%.md$")
  return { day = tonumber(day), month = tonumber(month), year = tonumber(year) }
end

vim.api.nvim_create_user_command("Calendir", function(args)
  if args.fargs[1] == "today" then
    open(os.date("*t") --[[@as osdateparam]])
  elseif args.fargs[1] == "yesterday" then
    local date = os.date("*t")
    open { year = date.year, month = date.month, day = date.day - 1 }
  elseif args.fargs[1] == "tomorrow" then
    local date = os.date("*t")
    open { year = date.year, month = date.month, day = date.day + 1 }
  elseif args.fargs[1] == "previous" then
    local date = getcurrent()
    if date then
      date.day = date.day - 1
      open(date)
    end
  elseif args.fargs[1] == "next" then
    local date = getcurrent()
    if date then
      date.day = date.day + 1
      open(date)
    end
  end
end, {
  desc = "Calendir command.",
  nargs = 1,
  complete = function(arglead, cmdline, curpos)
    if curpos ~= #cmdline then return end
    return vim.tbl_filter(function(e)
      return e:sub(1, #arglead) == arglead
    end, { "today", "yesterday", "tomorrow", "previous", "next" })
  end,
})
