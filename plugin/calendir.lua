-- simirian's Neovim
-- calendar plugin

vim.g.calendir = vim.g.calendir or vim.env.HOME .. "/Documents/calendir"

--- @class osdate: osdateparam

--- @alias Calendir.Precision "year"|"month"|"week"|"day"|"hour"|"min"|"sec"
local precisions = { "year", "month", "day", "hour", "min", "sec" }

--- Offsets each component of a date by an offset and return a real date.
--- @param date osdateparam The date to apply the offset to.
--- @param field Calendir.Precision The field in the date to offset.
--- @param mag integer How much to offset the specified field.
--- @return osdate
local function offset(date, field, mag)
  if field == "week" then
    date.day = date.day + 7 * mag
  else
    date[field] = date[field] + mag
  end
  return os.date("*t", os.time(date)) --[[@as osdate]]
end

--- Parses an ISO 8601 date. Does not exactly follow the standard when it comes
--- to week years becase that is too painful and not strictly required.
--- @param str string The ISO 8601 date string.
--- @return osdate?
--- @return Calendir.Precision?
local function parseiso(str)
  local date = {}
  date.year = tonumber(str:sub(1, 4))
  if not date.year then return end
  date.month = tonumber(str:sub(6, 7))
  date.day = tonumber(str:sub(9, 10))
  date.hour = tonumber(str:sub(12, 13))
  date.min = tonumber(str:sub(15, 16))
  date.sec = tonumber(str:sub(18, 19))
  local precision = precisions[#vim.tbl_keys(date)]
  date.month = date.month or 1
  date.day = date.day or 1
  return os.date("*t", os.time(date)) --[[@as osdate]], precision
end

--- Checks if a date is actually a real date that exists.
--- @param date osdateparam The date to check
--- @return boolean
local function realdate(date)
  local real = os.date("*t", os.time(date))
  return real.year == date.year and real.yday == date.yday
      and real.hour == date.hour and real.min == date.min and real.sec == date.sec
end

---Checks if the first date is before the second date.
---@param a osdateparam The date which should be first.
---@param b osdateparam The date which should be second.
---@return boolean
local function before(a, b)
  return os.time(a) < os.time(b)
end

--- Checks if the given dates are the same.
--- @param a osdateparam The first date to check.
--- @param b osdateparam The second date to check.
--- @return boolean
local function samedate(a, b)
  return a.year == b.year and a.month == b.month and a.day == b.day
end

--- Attempts to get the date of the currently open calendir buffer.
--- @return osdate?
--- @return Calendir.Precision?
local function getcurrent()
  if vim.b.calendir_date and vim.b.calendir_type then
    return vim.b.calendir_date, vim.b.calendir_type
  end
  local bufname = vim.fs.normalize(vim.fn.expand(vim.api.nvim_buf_get_name(0)))
  local s, e = bufname:find(vim.fs.normalize(vim.fn.expand(vim.g.calendir)), 1, true)
  if s == 1 then
    local date, type = parseiso(bufname:match("[^/\\].*$", e + 1))
    if not date or not type then return end
    vim.b.calendir_date = date
    vim.b.calendir_type = type .. "file"
    return date, type .. "file"
  end
end

--- Checks if a journal entry exists for the given day.
--- @param date osdateparam The date of the entry to check.
--- @return boolean
local function exists(date)
  local path = vim.fs.normalize(vim.g.calendir .. os.date("/%Y/%m/%d.md", os.time(date)))
  --- @diagnostic disable-next-line: undefined-field
  return vim.uv.fs_stat(path) ~= nil
end

--- Edits a file in the calendir directory instead of opening it as a calendar.
--- @param bang boolean If :edit should be :edit!.
--- @param date osdateparam The date to edit.
--- @param precision? Calendir.Precision The level of precision to edit.
local function edit(bang, date, precision)
  precision = precision or "day"
  local subpath = ({
    year = ("/%04d"):format(date.year),
    month = ("/%04d/%02d"):format(date.year, date.month),
  })[precision] or ("/%04d/%02d/%02d.md"):format(date.year, date.month, date.day)
  local path = vim.fs.normalize(vim.g.calendir .. subpath)
  if not pcall(vim.cmd --[[@as fun()]], "edit" .. (bang and "! " or " ") .. path) then
    vim.notify(vim.v.errmsg, vim.log.levels.ERROR, {})
    return
  end
  if precision == "year" or precision == "month" then
    vim.fn.mkdir(path, "p")
  else
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines == 1 and lines[1] == "" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { os.date("# Daily %F", os.time(date)) --[[@as string]] })
    end
    vim.cmd("sil w ++p")
  end
  vim.b.calendir_date = date
  vim.b.calendir_type = ({
    year = "yearfile",
    month = "monthfile",
  })[precision] or "dayfile"
end

--- Opens a calendar buffer based on the date and precision level.
--- @param bang boolean If :edit should be :edit!.
--- @param date osdateparam The date to edit.
--- @param precision Calendir.Precision The level of precision to open.
local function cal(bang, date, precision)
  local time = os.time(date)
  local isodate = ({
    year = os.date("%Y", time),
    month = os.date("%Y-%m", time),
    day = os.date("%F", time),
    hour = os.date("%F %H", time),
    min = os.date("%F %R", time),
    sec = os.date("%F %T", time),
  })[precision]
  vim.cmd("edit" .. (bang and "! " or " ") .. "calendir://" .. isodate)
end

--- The namespace used by this plugin.
local namespace = vim.api.nvim_create_namespace("calendir")

--- Names of days of the week, to be used in monthly calendars.
local daynames = ""
for wday = 1, 7 do
  daynames = daynames .. os.date(" %a ", os.time { year = 1970, month = 1, day = 3 + wday })
end

--- Names of months of the year, to be used in yearly calendars.
local monthnames = ""
for month = 1, 12 do
  monthnames = monthnames .. os.date(" %b ", os.time { year = 1970, month = month, day = 1 })
end

--- Populates the given buffer with a full-year calendar.
--- @param bufnr integer The buffer number.
--- @param date osdateparam A date in the year.
local function yearcal(bufnr, date)
  vim.b[bufnr].calendir_type = "year"
  vim.b[bufnr].calendir_date = date
  vim.b[bufnr].bufname = os.date("%Y", os.time(date))
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false

  local lines = { monthnames }
  for day = 1, 28 do
    table.insert(lines, ("%4d "):format(day):rep(12))
  end
  for day = 29, 31 do
    local line = ""
    for month = 1, 12 do
      local str = "     "
      if realdate { year = date.year, month = month, day = day } then
        str = ("%4d "):format(day)
      end
      line = line .. str
    end
  end
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false

  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  local today = os.date("*t")
  local function mark(month, day)
    local hasentry, hl = exists { year = date.year, month = month, day = day }
    if today.year == date.year and today.month == month and today.day == day then
      hl = hasentry and "CalToday" or "CalNoToday"
    elseif hasentry then
      hl = "CalDay"
    end
    vim.api.nvim_buf_set_extmark(bufnr, namespace, day, month * 5 - 5, {
      end_col = month * 5,
      hl_group = hl,
    })
  end
  for day = 1, 28 do
    for month = 1, 12 do
      mark(month, day)
    end
  end
  for day = 29, 31 do
    for month = 1, 12 do
      if realdate { year = date.year, month = month, day = day } then
        mark(month, day)
      end
    end
  end

  vim.keymap.set("", "<cr>", function()
    local curpos = vim.api.nvim_win_get_cursor(0)
    local month, day = math.floor(curpos[2] / 5) + 1, curpos[1] - 1
    edit(true, { year = date.year, month = month, day = day }, "day")
  end, { buffer = bufnr, desc = "Open journal entry." })
end

--- Populates the buffer with a month calendar.
--- @param bufnr integer The buffer number.
--- @param date osdateparam A date in the month.
local function monthcal(bufnr, date)
  vim.b[bufnr].calendir_type = "month"
  vim.b[bufnr].calendir_date = date
  vim.b[bufnr].bufname = os.date("%B %Y", os.time(date))
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false

  local first = os.date("*t", os.time(date)) --[[@as osdate]]
  while first.wday ~= 1 do
    first = offset(first, "day", -1)
  end
  local last = os.date("*t", os.time { year = date.year, month = date.month + 1, day = 1 }) --[[@as osdate]]
  while last.wday ~= 1 do
    last = offset(last, "day", 1)
  end
  local lines = { daynames }
  local iter = vim.deepcopy(first)
  while before(iter, last) do
    local lead = iter.wday == 1 and "" or table.remove(lines)
    table.insert(lines, ("%s%4d "):format(lead, iter.day))
    iter = offset(iter, "day", 1)
  end
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false

  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  local lnum, today = 0, os.date("*t")
  iter = first
  while before(iter, last) do
    lnum = iter.wday == 1 and lnum + 1 or lnum
    local hasentry, hl = exists(iter)
    if samedate(iter, today --[[@as osdate]]) then
      hl = hasentry and "CalToday" or "CalNoToday"
    elseif iter.month ~= date.month then
      hl = hasentry and "CalOther" or "CalNoOther"
    elseif hasentry then
      hl = "CalDay"
    end
    vim.api.nvim_buf_set_extmark(bufnr, namespace, lnum, (iter.wday - 1) * 5, {
      end_col = iter.wday * 5,
      hl_group = hl,
    })
    iter = offset(iter, "day", 1)
  end

  vim.keymap.set("", "<cr>", function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local day = tonumber(line:sub(math.floor(col / 5) * 5, math.floor(col / 5 + 1) * 5))
    edit(true, { year = date.year, month = date.month, day = day --[[@as integer]] }, "day")
  end, { buffer = bufnr, desc = "Open journal entry." })
end

--- Populates the given buffer with a week calendar.
--- @param bufnr integer The buffer number.
--- @param date osdateparam A date in the week.
local function weekcal(bufnr, date)
  vim.notify("not yet implemented", vim.log.levels.WARN, {})
end

--- Populates the given buffer with a day calendar.
--- @param bufnr integer The buffer number.
--- @param date osdateparam Any date.
local function daycal(bufnr, date)
  vim.notify("not yet implemented", vim.log.levels.WARN, {})
end

vim.api.nvim_create_autocmd("BufReadCmd", {
  desc = "Implements :e for calendir:// buffers.",
  pattern = "calendir://*",
  callback = function(e)
    local date, precision = parseiso(e.match:match("calendir://(.*)"))
    if not date then
      vim.schedule(function()
        vim.notify("Invalid calendir date format. See `:h calendir-format`.", vim.log.levels.ERROR, {})
      end)
      return
    end
    if precision == "year" then
      yearcal(e.buf, date)
    elseif precision == "month" then
      monthcal(e.buf, date)
    end
  end,
})

vim.api.nvim_create_user_command("Calendir", function(args)
  if args.args == "today" then
    edit(args.bang, os.date("*t") --[[@as osdate]], "day")
  elseif args.args == "yesterday" then
    edit(args.bang, offset(os.date("*t") --[[@as osdate]], "day", -1), "day")
  elseif args.args == "tomorrow" then
    edit(args.bang, offset(os.date("*t") --[[@as osdate]], "day", 1), "day")
  elseif args.args:sub(1, 1):match("[+-]") then
    local date, type = getcurrent()
    local off = tonumber(args.args)
    if not date or not type or not off then return end
    local file = vim.endswith(type --[[@as string]], "file")
    type = type:match("(.*)file$") or type
    if file then
      edit(args.bang, offset(date --[[@as osdate]], type, off), type)
    else
      cal(args.bang, offset(date --[[@as osdate]], type, off), type)
    end
  else
    local date, type = parseiso(args.args)
    if not date or not type then return end
    if type == "day" then
      edit(args.bang, date)
    else
      cal(args.bang, date, type)
    end
  end
end, {
  desc = "Calendir command.",
  nargs = "?",
  bang = true,
  complete = function(arglead, cmdline, curpos)
    if curpos ~= #cmdline then return end
    return vim.tbl_filter(function(e)
      return vim.startswith(e, arglead)
    end, { "today", "yesterday", "tomorrow", "previous", "next" })
  end,
})
