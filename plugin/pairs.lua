--- simirian's Neovim
--- autopairs and surrounds

-- ((autopairs)) ---------------------------------------------------------------

--- Rule for pairing (and also deleting) items.
--- @class Pairs.Rule
--- The character which is the start of the pair.
--- @field open string
--- The character which is the end of the pair.
--- @field close string
--- A lua pattern which matches characters after which the pair will not be
--- completed when the opneing character is typed.
--- @field notafter string

--- List of pairs.
--- @type table<string, Pairs.Rule>
local rules = {
  parens = { open = "(", close = ")", notafter = "\\" },
  brackets = { open = "[", close = "]", notafter = "\\" },
  braces = { open = "{", close = "}", notafter = "\\" },
  angles = { open = "<", close = ">", notafter = "\\" },
  dquote = { open = '"', close = '"', notafter = "\\", },
  quote = { open = "'", close = "'", notafter = "[\\%a]" },
  grave = { open = "`", close = "`", notafter = "\\" },
  aster = { open = "*", close = "*", notafter = "[\\%d]" },
  equal = { open = "=", close = "=", notafter = "[\\%d]" },
  under = { open = "_", close = "_", notafter = "[\\%a]" },
  caret = { open = "^", close = "^", notafter = "[\\%d]" },
  bar = { open = "|", close = "|", notafter = "\\" },
  tilde = { open = "~", close = "~", notafter = "\\" },
}

--- Map of file types to their pair rules.
--- @type table<string, string[]|boolean>
local ft = {
  default = { "parens", "brackets", "braces", "dquote", "quote" },
  markdown = { "parens", "brackets", "braces", "dquote", "quote", "grave", "aster", "under" },
  TelescopePrompt = false,
  PAIRTEST = { "parens", "brackets", "braces", "angles", "dquote", "quote", "grave", "aster", "equal", "under", "caret", "bar", "tilde" },
}

--- Map of closing characters to the number of times they can be typed over this
--- insert mode session.
--- @type table<string, integer>
local paircounts = {}

--- Generates an expr keymap function to open or close a symmetrical pair.
--- @param rule Pairs.Rule The rule to generate the keymap function for.
--- @return fun(): string
local function openclose(rule)
  return function()
    if vim.b.pairs_rules and vim.b.pairs_rules[rule.open] then
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if paircounts[rule.open] and line:sub(col + 1, col + 1) == rule.close then
        paircounts[rule.open] = paircounts[rule.open] > 1 and paircounts[rule.open] - 1 or nil
        return "<right>"
      elseif not line:sub(col, col):find(rule.notafter) then
        paircounts[rule.open] = paircounts[rule.open] and paircounts[rule.open] + 1 or 1
        return rule.open .. rule.close .. "<left>"
      end
    end
    return rule.open
  end
end

--- Generates an expr keymap function to open a asymmetrical pair.
--- @param rule Pairs.Rule The rule to generate the keymap function for.
--- @return fun(): string
local function open(rule)
  return function()
    if vim.b.pairs_rules and vim.b.pairs_rules[rule.open] then
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if not vim.api.nvim_get_current_line():sub(col, col):find(rule.notafter) then
        paircounts[rule.open] = paircounts[rule.open] and paircounts[rule.open] + 1 or 1
        return rule.open .. rule.close .. "<left>"
      end
    end
    return rule.open
  end
end

--- Generates an expr keymap function to close a asymmetrical pair.
--- @param rule Pairs.Rule The rule to generate the keymap function for.
--- @return fun(): string
local function close(rule)
  return function()
    if vim.b.pairs_rules and vim.b.pairs_rules[rule.open] then
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if paircounts[rule.open] and vim.api.nvim_get_current_line():sub(col + 1, col + 1) == rule.close then
        paircounts[rule.open] = paircounts[rule.open] > 1 and paircounts[rule.open] - 1 or nil
        return "<right>"
      end
    end
    return rule.close
  end
end

--- Deletes a simple pair if the cursor is between two simple pair ends.
--- @return string keymap
local function bs()
  local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
  local before, after = line:sub(col, col), line:sub(col + 1, col + 1)
  for _, rule in pairs(vim.b.pairs_rules --[[@as Pairs.Rule[] ]] or {}) do
    if rule.open == before and rule.close == after then
      if paircounts[rule.open] then
        paircounts[rule.open] = paircounts[rule.open] > 1 and paircounts[rule.open] - 1 or nil
      end
      return "<bs><del>"
    end
  end
  return "<bs>"
end

--- Splits a pair over new lines if the cursor is betwen simple pair ends.
--- @return string keymap
local function cr()
  local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
  local before, after = line:sub(col, col), line:sub(col + 1, col + 1)
  print(before, after)
  for _, rule in pairs(vim.b.pairs_rules --[[@as Pairs.Rule[] ]] or {}) do
    if rule.open == before and rule.close == after then
      return "<cr><up><end><cr>"
    end
  end
  return "<cr>"
end

for _, rule in pairs(rules) do
  local opts = { desc = "Autopair " .. rule.open .. rule.close, expr = true }
  if rule.open == rule.close then
    vim.keymap.set("i", rule.open, openclose(rule), opts)
  else
    vim.keymap.set("i", rule.open, open(rule), opts)
    vim.keymap.set("i", rule.close, close(rule), opts)
  end
end

vim.keymap.set("i", "<cr>", cr, { desc = "Neatly split a pair over lines.", expr = true })
vim.keymap.set("i", "<bs>", bs, { desc = "Delete a pair.", expr = true })

local augroup = vim.api.nvim_create_augroup("pairs", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  desc = "Reset pair typeover counts and surround state.",
  group = augroup,
  callback = function() paircounts = {} end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Bind pairs to buffer.",
  group = augroup,
  callback = function()
    local ftrules = ft[vim.bo.ft]
    if ftrules == false then return end
    ftrules = ftrules --[[@as string[] ]] or ft.default
    local bufrules = {}
    for _, rulename in pairs(ftrules) do
      local rule = rules[rulename]
      bufrules[rule.open] = rule
    end
    vim.b.pairs_rules = bufrules
  end,
})

-- ((surround)) ----------------------------------------------------------------

--- A tuple which contains the open and close string for a pair.
--- @alias Pairs.OCTuple { open: string, close: string }

--- A class which represents a surrounding pair.
--- @class Pairs.MarkerSet
--- The sides to surround text with, or a function to generate them.
--- @field a Pairs.OCTuple|fun(): Pairs.OCTuple
--- The sides to be searched for when deleting surroundings, or a function to
--- generate them. Uses `a` as a fallback.
--- @field d? Pairs.OCTuple|fun(): Pairs.OCTuple

--- @type table<string, Pairs.MarkerSet>
local msets = {
  ["("] = { a = { open = "(", close = ")" }, d = { open = "%(", close = "%)" } },
  [")"] = { a = { open = "( ", close = " )" }, d = { open = "%(%s*", close = "%s*%)" } },
  ["["] = { a = { open = "[", close = "]" }, d = { open = "%[", close = "%]" } },
  ["]"] = { a = { open = "[ ", close = " ]" }, d = { open = "%[%s*", close = "%s*%]" } },
  ["{"] = { a = { open = "{", close = "}" } },
  ["}"] = { a = { open = "{ ", close = " }" }, d = { open = "{%s*", close = "%s*}" } },
  ["<"] = { a = { open = "<", close = ">" } },
  [">"] = { a = { open = "< ", close = " >" }, d = { open = "<%s*", close = "%s*>" } },
  ['"'] = { a = { open = '"', close = '"' } },
  ["'"] = { a = { open = "'", close = "'" } },
  ["`"] = { a = { open = "`", close = "`" } },
  -- tags (T for space)
  ["t"] = {
    a = function()
      local tagname = vim.fn.input("t ")
      return { open = "<" .. tagname .. ">", close = "</" .. tagname .. ">" }
    end,
    d = function()
      local tagname = vim.fn.input("t "):gsub("%%", "%%%%")
      return { open = "<" .. tagname .. "[^<>]*>", close = "</" .. tagname .. ">" }
    end,
  },
  ["T"] = {
    a = function()
      local tagname = vim.fn.input("T ")
      return { open = "<" .. tagname .. "> ", close = " </" .. tagname .. ">" }
    end,
    d = function()
      local tagname = vim.fn.input("T "):gsub("%%", "%%%%")
      return { open = "<" .. tagname .. "[^<>]*>%s*", "%s*</" .. tagname .. ">" }
    end,
  },
  -- p prompt (P for space)
  ["p"] = {
    a = function()
      local text = vim.fn.input("p ")
      return { open = text, close = text }
    end,
    d = function()
      local text = vim.fn.input("p "):gsub("%%", "%%%%")
      return { open = text, close = text }
    end,
  },
  ["P"] = {
    a = function()
      local text = vim.fn.input("P ")
      return { open = text .. " ", close = " " .. text }
    end,
    d = function()
      local text = vim.fn.input("P "):gsub("%%", "%%%%")
      return { open = text .. "%s*", close = "%s*" .. text }
    end,
  },
}

--- Queries the user for a character and returns the marker set associated with
--- that character or nil if there isn't one.
--- @param source string The source to print on the command line.
--- @return Pairs.MarkerSet
local function getmarkset(source)
  vim.api.nvim_echo({ { source .. " " } }, false, {})
  local char = vim.fn.getchar()
  if type(char) == "number" then
    char = string.char(char)
  end
  return msets[char]
end

--- Surround operator function. Should never be called manually, only from
--- 'opfunc' internally.
--- TODO: update indentation/formatting over surround
--- @param mode "char"|"line"|"block"
function Surround(mode)
  -- get markers to add
  local set = getmarkset("s")
  local add = set and (type(set.a) == "function" and set.a() or set.a)
  if not add then return end
  -- add markers based on operator mode and mark positions
  local selectstart = vim.api.nvim_buf_get_mark(0, "[")
  local selectend = vim.api.nvim_buf_get_mark(0, "]")
  local lines = vim.api.nvim_buf_get_lines(0, selectstart[1] - 1, selectend[1], false)
  if mode == "char" then
    if #lines == 1 then
      lines[1] = table.concat {
        lines[1]:sub(1, selectstart[2]),
        add.open,
        lines[1]:sub(selectstart[2] + 1, selectend[2] + 1),
        add.close,
        lines[1]:sub(selectend[2] + 2),
      }
    else
      lines[1] = lines[1]:sub(1, selectstart[2]) .. add.open .. lines[1]:sub(selectstart[2] + 1)
      lines[#lines] = lines[#lines]:sub(1, selectend[2] + 1) .. add.close .. lines[#lines]:sub(selectend[2] + 2)
    end
    vim.api.nvim_buf_set_lines(0, selectstart[1] - 1, selectend[1], false, lines)
  elseif mode == "line" then
    table.insert(lines, 1, add.open)
    table.insert(lines, add.close)
    vim.api.nvim_buf_set_lines(0, selectstart[1] - 1, selectend[1], false, lines)
  else -- "block"
    selectend[2] = selectend[2] == #lines[#lines] and -1 or selectend[2]
    lines = vim.tbl_map(function(line)
      return table.concat {
        line:sub(1, selectstart[2]),
        add.open,
        line:sub(selectstart[2] + 1, selectend[2] >= 0 and selectend[2] + 1 or nil),
        add.close,
        line:sub(selectend[2] >= 0 and selectend[2] + 2 or #line + 1),
      }
    end, lines)
    vim.api.nvim_buf_set_lines(0, selectstart[1] - 1, selectend[1], false, lines)
  end
end

--- Callback to set up the surround operator.
local function asurround()
  vim.o.opfunc = "v:lua.Surround"
  return "g@"
end

--- Finds the given markers around the cursor on the current line.
--- @param mopen string Lua pattern of the opening marker.
--- @param mclose string Lua pattern of the cloding marker.
--- @return integer[]? openpos
--- @return integer[]? closepos
local function findmarkers(mopen, mclose)
  local line = vim.api.nvim_get_current_line()
  local curpos = vim.api.nvim_win_get_cursor(0)
  local before, after = line:sub(1, curpos[2]), line:sub(curpos[2] + 1)
  local closepos = { after:find(mclose) }
  if #closepos ~= 2 then return end
  local find, openpos = { before:find(mopen) }, {}
  while #find > 0 do
    openpos = find
    find = { before:find(mopen, find[1] + 1) }
  end
  if #openpos ~= 2 then return end
  return openpos, closepos
end

--- Callabck that deletes surroundings.
local function dsurround()
  -- get markers to search for
  local set = getmarkset("ds")
  if not set then return end
  local delete = set.d or set.a
  delete = type(delete) == "function" and delete() or delete
  if not delete then return end
  -- search for last matching before and first matching after
  local openpos, closepos = findmarkers(delete.open, delete.close)
  if not openpos or not closepos then return end
  -- remove markers from line
  local curpos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_buf_set_lines(0, curpos[1] - 1, curpos[1], false, { table.concat {
    line:sub(1, openpos[1] - 1),
    line:sub(openpos[2] + 1, closepos[1] + curpos[2] - 1),
    line:sub(closepos[2] + curpos[2] + 1),
  } })
end

--- Callback that changes surroundings.
local function csurround()
  -- get markers to search for
  local set = getmarkset("cst")
  if not set then return end
  local delete = set.d or set.a
  delete = type(delete) == "function" and delete() or delete
  if not delete then return end
  -- search for last matching before and first matching after
  local openpos, closepos = findmarkers(delete.open, delete.close)
  if not openpos or not closepos then return end
  -- get markers to replace with
  set = getmarkset("csr")
  local add = set and (type(set.a) == "function" and set.a() or set.a)
  if not add then return end
  -- replace old markers with new markers
  local line = vim.api.nvim_get_current_line()
  local curpos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(0, curpos[1] - 1, curpos[1], false, { table.concat {
    line:sub(1, openpos[1] - 1),
    add.open,
    line:sub(openpos[2] + 1, closepos[1] + curpos[2] - 1),
    add.close,
    line:sub(closepos[2] + curpos[2] + 1),
  } })
end

vim.keymap.set("", "s", asurround, { desc = "Surround operator.", expr = true })
vim.keymap.set("", "ss", function()
  local curpos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_mark(0, "[", curpos[1], curpos[2], {})
  vim.api.nvim_buf_set_mark(0, "]", curpos[1], curpos[2], {})
  Surround("line")
end, { desc = "Surround current line." })
vim.keymap.set("n", "S", function()
  local curpos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_buf_set_mark(0, "[", curpos[1], curpos[2], {})
  vim.api.nvim_buf_set_mark(0, "]", curpos[1], #line, {})
  Surround("char")
end, { desc = "Surround to end of line." })
vim.keymap.set("v", "S", function()
  local opstart = vim.fn.getpos("v")
  local opend = vim.fn.getpos(".")
  if opstart[2] > opend[2] then
    opstart, opend = opend, opstart
  end
  vim.api.nvim_buf_set_mark(0, "[", opstart[2], opstart[3], {})
  if vim.api.nvim_get_mode().mode:sub(1, 1) == "" then
    local line = vim.api.nvim_buf_get_lines(0, opend[2] - 1, opend[2], false)[1]
    vim.api.nvim_buf_set_mark(0, "]", opend[2], #line, {})
    Surround("block")
  else
    vim.api.nvim_buf_set_mark(0, "]", opend[2], opend[3], {})
    Surround("line")
  end
  vim.cmd.normal("<esc>")
end, { desc = "Suround visual lines." })
vim.keymap.set("n", "ds", dsurround, { desc = "Delete surroundings." })
vim.keymap.set("n", "cs", csurround, { desc = "Change surroundings." })
