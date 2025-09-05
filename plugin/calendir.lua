-- simirian's Neovim
-- calendar plugin

vim.g.calendir = vim.g.calendir or vim.env.HOME .. "/Documents/calendir"

--- Opens the daily document for the specified time.
--- @param date osdateparam The date to open the file of.
--- @param bang boolean? If the command was executed with a bang.
local function open(date, bang)
  local time = os.time(date)
  local path = vim.g.calendir .. os.date("/%Y/%m/%d.md", time)
  if not pcall(vim.cmd --[[@as fun()]], "edit" .. (bang and "! " or " ") .. path) then
    vim.notify(vim.v.errmsg, vim.log.levels.ERROR, {})
  else
    vim.b.calendir_date = vim.b.calendir_date or date
    vim.b.calendir_type = vim.b.calendir_type or "journal"
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines == 1 and lines[1] == "" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { os.date("# Daily %Y-%m-%d", time) --[[@as string]] })
    end
    vim.fn.mkdir(vim.g.calendir .. os.date("/%Y/%m", time), "p")
  end
end

--- Attempts to get the date of the currently open calendir buffer. The first
--- return specifies the type of buffer is open, with nil for if one isn't open.
--- If the first return isn't nil, then the second will be a date to open/update
--- that buffer.
--- @return "year"|"month"|"journal"? type
--- @return osdate? date
local function getcurrent()
  return vim.b.calendir_type, vim.b.calendir_date
end

vim.api.nvim_create_autocmd("BufNew", {
  desc = "Set calendir journal buffer name and type.",
  pattern = vim.fs.normalize(vim.g.calendir .. "/*/*/*.md"),
  callback = function()
    vim.b.calendir_type = "journal"
    local year, month, day = vim.api.nvim_buf_get_name(0):match("[/\\](%d+)[/\\](%d+)[/\\](%d+).md$")
    vim.b.calendir_date = { year = tonumber(year), month = tonumber(month), day = tonumber(day) }
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Set calendir journal buffer name and type.",
  callback = function()
    local buffers = vim.api.nvim_list_bufs()
    for _, buffer in ipairs(buffers) do
      local bufname = vim.api.nvim_buf_get_name(buffer)
      if vim.startswith(vim.fs.normalize(bufname), vim.fs.normalize(vim.g.calendir)) then
        local year, month, day = bufname:match("[/\\](%d+)[/\\](%d+)[/\\](%d+).md$")
        vim.b[buffer].calendir_type = "journal"
        vim.b[buffer].calendir_date = { year = year, month = month, day = day }
      end
    end
  end,
})

--- Checks if a journal entry exists for the given day.
--- @param date osdateparam The date of the entry to check.
--- @return boolean
local function exists(date)
  local path = vim.fs.normalize(vim.g.calendir .. os.date("/%Y/%m/%d.md", os.time(date)))
  --- @diagnostic disable-next-line: undefined-field
  return vim.loop.fs_stat(path) ~= nil
end

--- Offsets each component of a date by an offset and return a real date.
--- @param date osdate The date to apply the offset to.
--- @param off { year: integer, month: integer, day: integer } The offset.
--- @return osdate date
local function offset(date, off)
  return os.date("*t", os.time {
    year = date.year + (off.year or 0),
    month = date.month + (off.month or 0),
    day = date.day + (off.day or 0),
  }) --[[@as osdate]]
end

--- The namepsace used by this plugin.
--- @type integer
local namespace = vim.api.nvim_create_namespace("calendir")

--- Map from years or months to buffer numbers.
--- @type table<string, integer>
local calendars = {}

--- Creates a buffer for a calendar collection.
--- @param name string The name of the calendar.
--- @return integer bufnr
local function makecalbuf(name)
  local bufnr = calendars[name]
  if not bufnr then
    bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(bufnr, "calendir:///" .. name)
    calendars[name] = bufnr
  end
  return bufnr
end

--- Names of months of the year, to be used in yearly calendars.
local monthnames = ""
for month = 1, 12 do
  monthnames = monthnames .. os.date(" %b ", os.time { year = 1970, month = month, day = 1 })
end

--- Opens a calendar year buffer.
--- @param year integer The year to display.
--- @param bang boolean? If the command was executed with a bang.
local function yearcalendar(year, bang)
  local bufnr = makecalbuf(tostring(year))
  vim.b[bufnr].calendir_date = { year = year, month = 1, day = 1 }
  vim.b[bufnr].calendir_type = "year"
  vim.bo[bufnr].modifiable = true
  local lines = { monthnames }
  for day = 1, 28 do
    table.insert(lines, ("%4d "):format(day):rep(12))
  end
  for day = 29, 31 do
    local line = ""
    for month = 1, 12 do
      if os.date("*t", os.time { year = year, month = month, day = day }).month == month then
        line = ("%s %3d "):format(line, day)
      else
        line = line .. "     "
      end
    end
    table.insert(lines, line)
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].modifiable = false
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  for day = 1, 31 do
    for month = 1, 12 do
      if os.date("*t", os.time { year = year, month = month, day = day }).month == month then
        local today, hasentry, hl = os.date("*t"), exists { year = year, month = month, day = day }
        if year == today.year and month == today.month and day == today.day then
          hl = hasentry and "CalToday" or "CalNoToday"
        elseif hasentry then
          hl = "CalDay"
        end
        vim.api.nvim_buf_set_extmark(bufnr, namespace, day, month * 5 - 5, { end_col = month * 5, hl_group = hl })
      end
    end
  end
  vim.keymap.set("", "gf", function()
    local curpos = vim.api.nvim_win_get_cursor(0)
    local month = math.floor(curpos[2] / 5) + 1
    local day = curpos[1] - 1
    open { year = year, month = month, day = day }
  end, { buffer = bufnr, desc = "Open journal entry." })
  if not pcall(vim.cmd --[[@as fun()]], bufnr .. "b" .. (bang and "!" or "")) then
    vim.notify(vim.v.errmsg, vim.log.levels.ERROR, {})
  end
end

--- Names of days of the week, to be used in monthly calendars.
local daynames = ""
for wday = 1, 7 do
  daynames = daynames .. os.date(" %a ", os.time { year = 1970, month = 1, day = 3 + wday })
end

---Checks if the first date is before the second date.
---@param a osdate The date which should be first.
---@param b osdate The date which should be second.
---@return boolean
local function before(a, b)
  return os.time(a --[[@as osdateparam]]) < os.time(b --[[@as osdateparam]])
end

--- Opens a month calendar buffer.
--- @param year integer The year.
--- @param month integer The month.
--- @param bang boolean? If the command was executed with a bang.
local function monthcalendar(year, month, bang)
  local date = { year = year, month = month, day = 1 }
  local bufnr = makecalbuf(os.date("%B %Y", os.time(date)) --[[@as string]])
  vim.b[bufnr].calendir_date = date
  vim.b[bufnr].calendir_type = "month"
  local first = os.date("*t", os.time(date)) --[[@as osdate]]
  while first.wday ~= 1 do
    first = offset(first, { day = -1 })
  end
  local last = os.date("*t", os.time { year = year, month = month + 1, day = 1 }) --[[@as osdate]]
  while last.wday ~= 1 do
    last = offset(last, { day = 1 })
  end
  local lines = { daynames }
  date = vim.deepcopy(first)
  while before(date, last) do
    local lead = date.wday == 1 and "" or table.remove(lines)
    table.insert(lines, ("%s%4d "):format(lead, date.day))
    date = offset(date, { day = 1 })
  end
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
  local lnum = 0
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  while before(first, last) do
    lnum = first.wday == 1 and lnum + 1 or lnum
    local today, hasentry, hl = os.date("*t"), exists(first --[[@as osdateparam]])
    if first.year == today.year and first.month == today.month and first.day == today.day then
      hl = hasentry and "CalToday" or "CalNoToday"
    elseif first.month ~= month then
      hl = hasentry and "CalOther" or "CalNoOther"
    elseif hasentry then
      hl = "CalDay"
    end
    vim.api.nvim_buf_set_extmark(bufnr, namespace, lnum, (first.wday - 1) * 5,
      { end_col = first.wday * 5, hl_group = hl })
    first = offset(first, { day = 1 })
  end
  vim.keymap.set("", "gf", function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local day = tonumber(line:sub(math.floor(col / 5) * 5, math.floor(col / 5 + 1) * 5))
    open { year = year, month = month, day = day --[[@as integer]] }
  end, { buffer = bufnr, desc = "Open journal entry." })
  if not pcall(vim.cmd --[[@as fun()]], bufnr .. "b" .. (bang and "!" or "")) then
    vim.notify(vim.v.errmsg, vim.log.levels.ERROR, {})
  end
end

vim.api.nvim_create_user_command("Calendir", function(args)
  if args.args == "today" then
    open(os.date("*t") --[[@as osdateparam]], args.bang)
  elseif args.args == "yesterday" then
    local date = os.date("*t")
    open({ year = date.year, month = date.month, day = date.day - 1 }, args.bang)
  elseif args.args == "tomorrow" then
    local date = os.date("*t")
    open({ year = date.year, month = date.month, day = date.day + 1 }, args.bang)
  elseif args.args == "previous" then
    local type, date = getcurrent()
    --- @cast date osdate
    if type == "year" then
      yearcalendar(date.year - 1, args.bang)
    elseif type == "month" then
      date = offset(date, { month = -1 })
      monthcalendar(date.year --[[@as integer]], date.month --[[@as integer]], args.bang)
    elseif type == "journal" then
      open(offset(date, { day = -1 }) --[[@as osdateparam]], args.bang)
    end
  elseif args.args == "next" then
    local type, date = getcurrent()
    --- @cast date osdate
    if type == "year" then
      yearcalendar(date.year + 1, args.bang)
    elseif type == "month" then
      date = offset(date, { month = 1 })
      monthcalendar(date.year --[[@as integer]], date.month --[[@as integer]], args.bang)
    elseif type == "journal" then
      open(offset(date, { day = 1 }) --[[@as osdateparam]], args.bang)
    end
  else
    local year, month, day = args.args:match("^%s*(%d+)/(%d+)/(%d+)%s*$")
    if year then
      open({ year = year, month = month, day = day }, args.bang)
      return
    end
    year, month = args.args:match("^%s*(%d+)/(%d+)%s*$")
    if year then
      monthcalendar(tonumber(year) --[[@as integer]], tonumber(month) --[[@as integer]], args.bang)
      return
    end
    year = args.args:match("^%s*(%d+)%s*$")
    if year then
      yearcalendar(tonumber(year) --[[@as integer]], args.bang)
    elseif args.args:match("^%s*$") then
      local today = os.date("*t")
      monthcalendar(today.year --[[@as integer]], today.month --[[@as integer]], args.bang)
    else
      vim.notify("Calendir: unreconized argument: " .. args.args, vim.log.levels.ERROR, {})
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
