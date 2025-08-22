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

--- Checks if a journal entry exists for the given day.
--- @param date osdateparam The date of the entry to check.
--- @return boolean
local function exists(date)
  local path = vim.fs.normalize(vim.g.calendir .. os.date("/%Y/%m/%d.md", os.time(date)))
  --- @diagnostic disable-next-line: undefined-field
  return vim.loop.fs_stat(path) ~= nil
end

--- The namepsace used by this plugin.
--- @type integer
local namespace = vim.api.nvim_create_namespace("calendir")

--- Map from years to buffer numbers.
--- @type table<integer, integer>
local yearbuffers = {}

--- Opens a calendar year buffer.
--- @param year integer The year to open the calendar for.
local function yearcalendar(year)
  local bufnr = yearbuffers[year]
  if not bufnr then
    bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(bufnr, "calendir:/" .. year)
    yearbuffers[year] = bufnr
  end
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].modifiable = true
  local lines = { "" }
  for month = 1, 12 do
    lines[1] = lines[1] .. os.date(" %b ", os.time { year = year, month = month, day = 1 })
  end
  for day = 1, 31 do
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
        local today = os.date("*t")
        local hl
        if year == today.year and month == today.month and day == today.day then
          hl = exists{year = year, month = month, day = day} and "CalToday" or "CalNoToday"
        else
          hl = exists { year = year, month = month, day = day } and "CalDay" or nil
        end
        vim.api.nvim_buf_set_extmark(bufnr, namespace, day, month * 5 - 5, {
          end_col = month * 5,
          hl_group = hl
        })
      end
    end
  end
  vim.keymap.set("", "gf", function()
    local curpos = vim.api.nvim_win_get_cursor(0)
    local month = math.floor(curpos[2] / 5) + 1
    local day = curpos[1] - 1
    open({year = year, month = month, day = day})
  end, {buffer = bufnr, desc = "Open journal entry."})
  vim.cmd("buffer! " .. bufnr)
end

vim.api.nvim_create_user_command("Calendir", function(args)
  if args.args == "today" then
    open(os.date("*t") --[[@as osdateparam]])
  elseif args.args == "yesterday" then
    local date = os.date("*t")
    open { year = date.year, month = date.month, day = date.day - 1 }
  elseif args.args == "tomorrow" then
    local date = os.date("*t")
    open { year = date.year, month = date.month, day = date.day + 1 }
  elseif args.args == "previous" then
    local date = getcurrent()
    if date then
      date.day = date.day - 1
      open(date)
    end
  elseif args.args == "next" then
    local date = getcurrent()
    if date then
      date.day = date.day + 1
      open(date)
    end
  else
    local year = tonumber(args.args:sub(1, 4))
    local month = tonumber(args.args:sub(6, 7))
    if not year then
      yearcalendar(tonumber(os.date("%Y")) --[[@as integer]])
    elseif not month then
      yearcalendar(year)
    else
      -- month calendar
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
