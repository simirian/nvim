--- simirian's Neovim
--- generic picker module

--- Generates the list of items to display.
--- @type fun(prompt: string, set: fun(items: any[])): any[]?
local generate

--- Maps from items to their display lines.
--- @type fun(item: any): string
local display

--- The function called to confirm the selection.
--- @type fun(item: any, idx: integer)
local confirm

--- The list of items which get rendered.
--- @type any[]
local items

--- The index of the selected item.
--- @type integer
local n

--- The start of the frame which gets displayed.
--- @type integer?
local frame

--- Buffer used for input.
--- @type integer
local ibuf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_name(ibuf, "Pick Input")

--- Buffer used for listing.
--- @type integer
local lbuf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_name(lbuf, "Pick List")

--- The window used to display the input buffer.
--- @type integer?
local iwin

--- The window used to display the list buffer.
--- @type integer?
local lwin

--- Opens the picker windows.
--- @param title string The title of the input window.
local function openwins(title)
  iwin = iwin or vim.api.nvim_open_win(ibuf, true, {
    relative = "editor",
    row = math.floor(vim.o.lines / 10),
    col = math.floor(vim.o.columns / 10),
    width = math.floor(vim.o.columns * 8 / 10),
    height = 1,
    border = "solid",
    style = "minimal",
    title = title,
    title_pos = title and "center",
  })
  vim.wo[iwin].winhighlight = "NormalFloat:PickInput,FloatBorder:PickInput"
  vim.wo[iwin].statuscolumn = "%#PickInput#   "
  lwin = lwin or vim.api.nvim_open_win(lbuf, false, {
    relative = "editor",
    row = math.floor(vim.o.lines / 10 + 3),
    col = math.floor(vim.o.columns / 10),
    width = math.floor(vim.o.columns * 8 / 10),
    height = math.floor(vim.o.lines * 8 / 10 - 5),
    border = "solid",
    style = "minimal",
  })
  vim.wo[lwin].cursorline = true
  vim.wo[lwin].winhighlight = "NormalFloat:PickList,FloatBorder:PickList,CursorLine:Search"
end

--- Closes the picker windows.
local function closewins()
  if iwin then
    iwin = vim.api.nvim_win_hide(iwin)
  end
  if lwin then
    lwin = vim.api.nvim_win_hide(lwin)
  end
end

--- Renders only the lines around the cursor for the sake of speed.
local function displayframe()
  --- @cast lwin integer
  frame = frame or vim.api.nvim_win_get_height(lwin)
  local nlines = vim.api.nvim_buf_line_count(lbuf)
  local start = nlines == 1 and 1 or nlines + 1
  local lines = {}
  for i = start, frame do
    if items[i] then
      table.insert(lines, display(items[i]))
    end
  end
  vim.bo[lbuf].modifiable = true
  vim.api.nvim_buf_set_lines(lbuf, start - 1, -1, false, lines)
  vim.bo[lbuf].modifiable = false
  vim.api.nvim_win_set_cursor(lwin, { n, 0 })
end

--- Sets the input buffer's item list to the
--- @param newitems any[] The items to set as the list's items.
local function setlist(newitems)
  items, n, frame = newitems, 1, nil
  vim.bo[lbuf].modifiable = true
  vim.api.nvim_buf_set_lines(lbuf, 0, -1, false, {})
  displayframe()
end

--- Sets the input buffer's contents.
--- @param line string The line to set the input window's text to.
local function setinput(line)
  vim.api.nvim_buf_set_lines(ibuf, 0, -1, false, { line })
end

--- The auroup used by this plugin.
--- @type integer
local augroup = vim.api.nvim_create_augroup("pick", { clear = true })

vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
  desc = "Update picker item list.",
  group = augroup,
  buffer = ibuf,
  callback = function()
    local line = vim.api.nvim_get_current_line()
    local newitems = generate(line, vim.schedule_wrap(setlist))
    if type(newitems) == "table" then
      setlist(newitems)
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Enter insert mode when entering the input buffer.",
  group = augroup,
  buffer = ibuf,
  callback = function()
    vim.cmd.startinsert()
    vim.api.nvim_win_set_cursor(0, {
      vim.api.nvim_win_get_cursor(0)[1],
      #vim.api.nvim_get_current_line()
    })
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  desc = "Close picker when leaving the input buffer.",
  group = augroup,
  buffer = ibuf,
  callback = function()
    closewins()
    vim.cmd.stopinsert()
  end,
})

vim.keymap.set({ "i", "n" }, "<cr>", function()
  confirm(items[n], n)
end, { desc = "Confirm picker selection.", buffer = ibuf })

vim.keymap.set("n", "<esc>", function()
  closewins()
end, { desc = "Close the picker.", buffer = ibuf })

vim.keymap.set({ "i", "n" }, "<C-j>", function()
  if n == #items then
    n = 1
  else
    n = n + 1
    frame = n > frame and n or frame
  end
  displayframe()
end, { desc = "Select next item in list.", buffer = ibuf })

vim.keymap.set({ "i", "n" }, "<C-k>", function()
  if n == 1 then
    local nitems = #items
    n, frame = nitems, nitems
  else
    n = n - 1
  end
  displayframe()
end, { desc = "Select previous item in list.", buffer = ibuf })

--- Scores a string based on how well it matches a query. I made this up in an
--- hour. It has O(n) and does not match optimally, but it's fuzzy so who cares.
--- Basically designed to be as fast as possible. Probably breaks with utf-8.
--- @param item string The item to score.
--- @param query string The query to score based on.
local function score(item, query)
    local s = 0
    local qi = 1                 -- query index
    local qc = query:sub(qi, qi) -- query character
    local li = 0                 -- index of last match
    for i = 1, #item do
      local ic = item:sub(i, i)
      -- base score is 5 if exact match, 1 if case insensitive, and 0 otherwise
      local b = ic == qc and 5 or (ic:lower() == qc:lower() and 1 or 0)
      if b ~= 0 then
        --           v-- score less if it's been a while since the last match
        --                               v-- later chars are slightly less relevant
        s = s + (b / (i - li)) * (0.8 + 0.2 * (1 - i / #item))
        li, qi, qc = i, qi + 1, query:sub(qi + 1, qi + 1)
      end
    end
    -- penalize heavily for not completing the query
    s = s - (qi > #query and 0 or 10) * (#query - qi + 1)
    -- reward less for how much of the item wasn't matched
    return s * (0.8 + 0.2 * ((qi - 1) / #item))
end

--- Simple fuzzy finding algorithm.
--- @param list string[] List of strings to score.
--- @param query string The query string to score based on.
--- @return string[]
local function fuzz(list, query)
  list = vim.tbl_map(function(e)
    return { e, score(tostring(e), query) }
  end, list)
  list = vim.tbl_filter(function(e)
    return e[2] > 0
  end, list)
  table.sort(list, function(a, b)
    return a[2] > b[2]
  end)
  return vim.tbl_map(function(e) return e[1] end, list)
end

--- Filters/sorts selections based on mini.nvim's pick module, but also forces
--- fuzzy matching if the first character is a space, and ignores that space.
--- Uses the above fuzz() function as a fallback for when there isn't a prefix.
--- @param list string[] The list to be filtered.
--- @param query string The query to use to filter the list.
--- @return string[]
local function match(list, query)
  local function pmatch(s, q)
    local ok, found = pcall(string.match, s, q)
    return ok and found ~= nil
  end
  if query == "" then return list end
  local neg = query:sub(1, 1) == "!"
  local mode = neg and query:sub(2, 2) or query:sub(1, 1)
  local predicates = {
    ["'"] = function(e) return pmatch(e, query) ~= neg end,
    ["^"] = function(e) return pmatch(e, "^" .. query) ~= neg end,
    ["$"] = function(e) return pmatch(e, query .. "$") ~= neg end,
  }
  if predicates[mode] then
    query = query:sub(neg and 3 or 2)
    return vim.tbl_filter(predicates[mode], list)
  else
    return fuzz(list, query:sub(query:sub(1, 1) == " " and 2 or 1))
  end
end

--- Runs a command and collectes its output into an array of lines. Runs the
--- callback with the collected lines as input.
--- @param cmd string[] The command to run.
--- @param opts vim.SystemOpts The options, `stdout` will be overwritten.
--- @param cb fun(lines: string[]) The callback.
--- @return vim.SystemObj
local function cmdlines(cmd, opts, cb)
  local lines = {}
  local ended = true
  opts.text = true
  opts.stdout = function(err, data)
    if not err and data then
      if not ended then
        local lbs, lbe = data:find("[\r\n]+")
        lines[#lines] = lines[#lines] .. data:sub(1, lbs - 1)
        data = data:sub(lbe + 1)
      end
      vim.list_extend(lines, vim.split(data, "[\r\n]+", { trimempty = true }))
      ended = data:sub(#data):match("[\r\n]") ~= nil
    end
  end
  return vim.system(cmd, opts, function(args)
    if args.code == 0 then
      cb(lines)
    end
  end)
end

--- @class Pick.Args
--- Generates, filters, and sorts the list of items.
--- @field generate fun(prompt: string, set: fun(items: any[])): any[]?
--- Generates the display strings for items. Defaults to tostring.
--- @field display? fun(item: any): string
--- Confirms the list of items.
--- @field confirm fun(item: any, idx: integer)
--- Starting input. Defaults to an empty string.
--- @field input? string
--- Starting item list. Defaults to an empty array.
--- @field items? any[]
--- Title of the input window.
--- @field title? string

--- Opens the picker windows and sets picker variables.
--- @param args Pick.Args
local function pick(args)
  openwins(args.title)
  generate = args.generate
  display = args.display or tostring
  confirm = args.confirm
  setinput(args.input or "")
  setlist(args.items or {})
end

--- @diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(list, opts, on_choice)
  pick {
    generate = function(prompt)
      return match(list, prompt)
    end,
    display = function(item)
      return (opts.format_item or tostring)(item)
    end,
    confirm = function(item, idx)
      closewins()
      on_choice(item, idx)
    end,
    items = list,
    title = opts.prompt,
  }
end

--- Function to open a picker. Should call `pick()` with the correct arguments
--- to invoke the picker. If remember is true then the picker should start with
--- the last input already entered.
--- @alias Pick.Picker fun(remember?: boolean)

--- Map of picker names to their pickers.
--- @type table<string, Pick.Picker>
local pickers = {}

local grepprg --- @type vim.SystemObj
local grepinput = "" --- @type string
local grepitems = {} --- @type string[]
function pickers.grep(remember)
  pick {
    generate = function(prompt, set)
      grepinput = prompt
      if grepprg then grepprg:kill(15) end
      grepprg = cmdlines({ "rg", "--vimgrep", "-Se", prompt == "" and ".*" or prompt }, {}, function(lines)
        grepitems = lines
          set(grepitems)
      end)
    end,
    confirm = function(item)
      local name, line, col = item:match("^([^:]+):(%d+):(%d+):.*$")
      if name and line and col then
        closewins()
        vim.cmd.edit(name)
        vim.api.nvim_win_set_cursor(0, { tonumber(line), tonumber(col) })
      end
    end,
    input = remember and grepinput or "",
    items = remember and grepitems or {},
  }
end

local helpinput = "" --- @type string
local helpitems = {} --- @type string[]
function pickers.help(remember)
  pick {
    generate = function(prompt)
      helpinput = prompt
      helpitems = {}
      local files = vim.api.nvim_get_runtime_file("doc/tags", true)
      for _, file in ipairs(files) do
        --- @diagnostic disable: undefined-field
        local fd = vim.loop.fs_open(file, "r", 420)
        local size = vim.loop.fs_fstat(fd).size
        local contents = vim.loop.fs_read(fd, size)
        vim.loop.fs_close(fd)
        --- @diagnostic enable: undefined-field
        local entries = vim.split(contents, "[\r\n]+", { trimempty = true })
        helpitems = vim.list_extend(helpitems, vim.tbl_map(function(e) return e:match("^[^\t]*") end, entries))
      end
      helpitems = match(helpitems, prompt)
      return helpitems
    end,
    confirm = function(item)
      closewins()
      vim.cmd.help(item)
    end,
    input = remember and helpinput or "",
    items = remember and helpitems or {},
  }
end

local fileprg
local fileinput = ""
local fileitems = {}
function pickers.files(remember)
  pick {
    generate = function(prompt, set)
      fileinput = prompt
      if fileprg then fileprg:kill(15) end
      fileprg = cmdlines({"rg", "--files", "--iglob=!.git/", "-."}, {}, function(lines)
        fileitems = match(lines, prompt)
        set(fileitems)
      end)
    end,
    confirm = function(item)
      closewins()
      vim.cmd.edit(item)
    end,
    input = remember and fileinput or "",
    items = remember and fileitems or {},
  }
end

vim.api.nvim_create_user_command("Pick", function(args)
  pickers[args.args](args.bang)
end, {
  desc = "Use a picker.",
  nargs = "?",
  bang = true,
  complete = function(arglead, cmdline, curpos)
    if curpos ~= #cmdline then return end
    return vim.tbl_filter(function(e)
      return vim.startswith(e, arglead)
    end, vim.tbl_keys(pickers))
  end,
})

vim.keymap.set("n", "<leader>ff", function() pickers.files() end, { desc = "Find files." })
vim.keymap.set("n", "<leader>fF", function() pickers.files(true) end, { desc = "Find files with the last query." })
vim.keymap.set("n", "<leader>fh", function() pickers.help() end, { desc = "Find help." })
vim.keymap.set("n", "<leader>fH", function() pickers.help(true) end, { desc = "Find help with the last query." })
vim.keymap.set("n", "<leader>fg", function() pickers.grep() end, { desc = "Find with grep." })
vim.keymap.set("n", "<leader>fG", function() pickers.grep(true) end, { desc = "Find with the last grep query." })
