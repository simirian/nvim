--- simirian's NeoVim
--- autopairs and surrounds

local M = {}

-- ((autopairs)) ---------------------------------------------------------------

--- Rule for pairing (and also deleting) items.
--- @class Pairs.Rule
--- The single character starting pattern for the rule, used for invocation as
--- the lhs of a keymap.
--- @field open string
--- The single character end of the pattern, or a function that closes the pair.
--- @field close string|fun(): string?
--- function that checks if the cursor is inside the pair.
--- @field check? fun(before: string, after: string): boolean

--- List of pairs.
--- @type table<string, Pairs.Rule>
local rules = {
  parens = { open = "(", close = ")" },
  brackets = { open = "[", close = "]" },
  braces = { open = "{", close = "}" },
  angles = { open = "<", close = ">" },
  dquote = { open = '"', close = '"' },
  quote = { open = "'", close = "'" },
  grave = { open = "`", close = "`" },
  aster = { open = "*", close = "*" },
  -- html and xml tags
  tag = {
    open = ">",
    close = function()
      local line = vim.api.nvim_get_current_line()
      local curpos = vim.api.nvim_win_get_cursor(0)
      local tagname = line:sub(1, curpos[2]):match("<([^<>%s]+)[^<>]*$")
      if tagname then
        if line:sub(curpos[2] + 1):find("</" .. tagname .. ">", 1, true) then return ">" end
        return ("></%s><esc>F>a"):format(tagname)
      end
    end,
    check = function(before, after)
      local tagname = before:match("<([^<>%s]+)[^<>]*>$")
      return tagname and after:find("</" .. tagname .. ">", 1, true) == 1
    end,
  },
}

--- Map of file types to their pair rules.
--- @type table<string, string[]|boolean>
local ft = {
  default = { "parens", "brackets", "braces", "dquote", "quote" },
  text = { "parens", "brackets", "braces", "dquote" },
  markdown = { "parens", "brackets", "braces", "dquote", "grave", "aster" },
  html = { "parens", "brackets", "braces", "dquote", "tag" },
  TelescopePrompt = false,
}

--- Map of closing characters to the number of times they can be typed over this
--- insert mode session.
--- @type table<string, integer>
local paircounts = {}

--- Generates a callback for opening a pair.
--- @param pair Pairs.Rule Pair to make a callback for.
--- @return string?
local function open(pair)
  paircounts[pair.close] = paircounts[pair.close] and paircounts[pair.close] + 1 or 1
  return pair.open .. pair.close .. "<left>"
end

--- Generates a callback for closing a pair.
--- @param pair Pairs.Rule Pair to make a callback for
--- @return string?
local function close(pair)
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if line:sub(col + 1, col + 1) == pair.close and paircounts[pair.close] then
    paircounts[pair.close] = paircounts[pair.close] > 1 and paircounts[pair.close] - 1 or nil
    return "<right>"
  end
end

--- Deletes a simple pair if the cursor is between two simple pair ends.
--- @return string keymap
local function bs()
  local line = vim.api.nvim_get_current_line()
  local curpos = vim.api.nvim_win_get_cursor(0)
  local before, after = line:sub(curpos[2], curpos[2]), line:sub(curpos[2] + 1, curpos[2] + 1)
  for _, pair in ipairs(vim.b.pairs_rules --[[@as Pairs.Rule[] ]]) do
    if pair.open == before and pair.close == after then
      paircounts[pair.close] = paircounts[pair.close] and paircounts[pair.close] > 1 and paircounts[pair.close] - 1
          or nil
      return "<bs><del>"
    end
  end
  return "<bs>"
end

--- Splits a pair over new lines if the cursor is betwen simple pair ends.
--- @return string keymap
local function cr()
  local line = vim.api.nvim_get_current_line()
  local curpos = vim.api.nvim_win_get_cursor(0)
  local before, after = line:sub(1, curpos[2]), line:sub(curpos[2] + 1)
  for _, pair in ipairs(vim.b.pairs_rules --[[@as Pairs.Rule[] ]]) do
    if pair.check and pair.check(before, after)
        or pair.open == before:sub(#before) and pair.close == after:sub(1, 1)
    then
      return "<cr><up><end><cr>"
    end
  end
  return "<cr>"
end

--- Generates a function for pairing after a character input. The function finds
--- the first pair rule which ends or starts with the typed character and
--- actually returns a successful keymap rhs.
--- @param char string The character to pair from.
--- @return fun(): string?
local function pair(char)
  return function()
    for _, rule in ipairs(vim.b.pairs_rules --[[@as Pairs.Rule[] ]]) do
      if rule.close == char then
        local rhs = close(rule)
        if rhs then return rhs end
      elseif rule.open == char then
        if type(rule.close) == "function" then
          local rhs = rule.close()
          if rhs then return rhs end
        else
          local rhs = open(rule)
          if rhs then return rhs end
        end
      end
    end
    return char
  end
end

--- Enables auto pairing with this module.
function M.pairenable()
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
      local bufrules = ft[vim.bo.ft]
      if bufrules == false then return end
      vim.b.pairs_rules = vim.tbl_map(function(e) return rules[e] end, bufrules or ft.default --[[@as string[] ]])

      local maps = {}
      for _, rule in ipairs(vim.b.pairs_rules --[[@as Pairs.Rule[] ]]) do
        if not maps[rule.open] then
          vim.keymap.set("i", rule.open, pair(rule.open),
            { desc = "Complete automatic pairing.", expr = true, buffer = 0 })
          maps[rule.open] = true
        end
        if type(rule.close) == "string" and not maps[rule.close] then
          vim.keymap.set("i", rule.close --[[@as string]], pair(rule.close --[[@as string]]),
            { desc = "Complete automatic pairing.", expr = true, buffer = 0 })
          maps[rule.close] = true
        end
      end

      vim.keymap.set("i", "<cr>", cr, { desc = "Neatly split a pair over lines.", expr = true, buffer = 0 })
      vim.keymap.set("i", "<bs>", bs, { desc = "Delete a pair.", expr = true, buffer = 0 })
    end,
  })
end

M.pairenable()

--- Disables further auto pairing with this module.
function M.pairdisable()
  vim.api.nvim_create_augroup("pairs", { clear = true })
end

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
  if mode == "char" then
    local lines = vim.api.nvim_buf_get_lines(0, selectstart[1] - 1, selectend[1], false)
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
    local lines = vim.api.nvim_buf_get_lines(0, selectstart[1] - 1, selectend[1], false)
    table.insert(lines, 1, add.open)
    table.insert(lines, add.close)
    vim.api.nvim_buf_set_lines(0, selectstart[1] - 1, selectend[1], false, lines)
  else -- "block"
    local lines = vim.api.nvim_buf_get_lines(0, selectstart[1] - 1, selectend[1], false)
    selectend[2] = selectend[2] == #lines[#lines] and -1 or selectend[2]
    lines = vim.tbl_map(function(line)
      return table.concat {
        line:sub(1, selectstart[2]),
        add.open,
        line:sub(selectstart[2] + 1, selectend[2] >= 0 and selectend[2] + 2 or nil),
        add.close,
        line:sub(selectend[2] >= 0 and selectend[2] + 3 or #line + 1),
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
  local find, openpos = { before:find(mopen) }, nil
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

--- Enable surround keymaps in this module.
function M.surroundenable()
  vim.keymap.set("", "s", asurround, { desc = "Surround operator.", expr = true })
  vim.keymap.set("", "ss", function() return asurround() .. "_" end, { desc = "Surround current line.", expr = true })
  vim.keymap.set("n", "ds", dsurround, { desc = "Delete surroundings." })
  vim.keymap.set("n", "cs", csurround, { desc = "Change surroundings." })
end

M.surroundenable()

--- Disable surround keymaps defined in this module.
function M.surrounddisable()
  vim.keymap.del("", "s")
  vim.keymap.del("", "ss")
  vim.keymap.del("n", "ds")
  vim.keymap.del("n", "cs")
end

return M
