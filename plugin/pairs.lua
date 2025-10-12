--- simirian's Neovim
--- autopair and surround plugin

--- Rule for pairing (and also deleting) items.
--- @class Pairs.Pair
--- The character which is the start of the pair.
--- @field open string
--- The character which is the end of the pair.
--- @field close string
--- A lua pattern which matches characters after which the pair will not be
--- completed when the opneing character is typed.
--- @field notafter? string

--- List of pairs.
--- @type table<string, Pairs.Pair>
local pairchars = {
  parens = { open = "(", close = ")" },
  brackets = { open = "[", close = "]" },
  braces = { open = "{", close = "}" },
  angles = { open = "<", close = ">" },
  dquote = { open = '"', close = '"' },
  quote = { open = "'", close = "'", notafter = "[\\%a]" },
  grave = { open = "`", close = "`" },
}

local pairnames = {
  ["("] = "parens",
  [")"] = "parens",
  ["["] = "brackets",
  ["]"] = "brackets",
  ["{"] = "braces",
  ["}"] = "braces",
  ["<"] = "angels",
  [">"] = "angles",
  ['"'] = "dquote",
  ["'"] = "quote",
  ["`"] = "grave",
}

-- ((autopairs)) ---------------------------------------------------------------

--- Map of file types to their pair rules.
--- @type table<string, string[]|boolean>
local ft = {
  default = { "parens", "brackets", "braces", "dquote", "quote" },
  markdown = { "parens", "brackets", "braces", "dquote", "quote", "grave" },
  TelescopePrompt = false,
  PAIRTEST = { "parens", "brackets", "braces", "angles", "dquote", "quote", "grave" },
}

--- Map of closing characters to the number of times they can be typed over this
--- insert mode session.
--- @type table<string, integer>
local paircounts = {}

--- Generates an expr keymap function to open or close a symmetrical pair.
--- @param pair Pairs.Pair The rule to generate the keymap function for.
--- @return fun(): string
local function openclose(pair)
  return function()
    if vim.b.pairs_rules and vim.b.pairs_rules[pair.open] then
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if paircounts[pair.open] and line:sub(col + 1, col + 1) == pair.close then
        paircounts[pair.open] = paircounts[pair.open] > 1 and paircounts[pair.open] - 1 or nil
        return "<right>"
      elseif not pair.notafter or not line:sub(col, col):find(pair.notafter) then
        paircounts[pair.open] = paircounts[pair.open] and paircounts[pair.open] + 1 or 1
        return pair.open .. pair.close .. "<left>"
      end
    end
    return pair.open
  end
end

--- Generates an expr keymap function to open a asymmetrical pair.
--- @param pair Pairs.Pair The rule to generate the keymap function for.
--- @return fun(): string
local function open(pair)
  return function()
    if vim.b.pairs_rules and vim.b.pairs_rules[pair.open] then
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if not pair.notafter or not vim.api.nvim_get_current_line():sub(col, col):find(pair.notafter) then
        paircounts[pair.open] = paircounts[pair.open] and paircounts[pair.open] + 1 or 1
        return pair.open .. pair.close .. "<left>"
      end
    end
    return pair.open
  end
end

--- Generates an expr keymap function to close a asymmetrical pair.
--- @param pair Pairs.Pair The rule to generate the keymap function for.
--- @return fun(): string
local function close(pair)
  return function()
    if vim.b.pairs_rules and vim.b.pairs_rules[pair.open] then
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if paircounts[pair.open] and vim.api.nvim_get_current_line():sub(col + 1, col + 1) == pair.close then
        paircounts[pair.open] = paircounts[pair.open] > 1 and paircounts[pair.open] - 1 or nil
        return "<right>"
      end
    end
    return pair.close
  end
end

--- Deletes a simple pair if the cursor is between two simple pair ends.
--- @return string keymap
local function bs()
  local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
  local before, after = line:sub(col, col), line:sub(col + 1, col + 1)
  for _, pair in pairs(vim.b.pairs_rules --[[@as Pairs.Pair[] ]] or {}) do
    if pair.open == before and pair.close == after then
      if paircounts[pair.open] then
        paircounts[pair.open] = paircounts[pair.open] > 1 and paircounts[pair.open] - 1 or nil
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
  for _, pair in pairs(vim.b.pairs_rules --[[@as Pairs.Pair[] ]] or {}) do
    if pair.open == before and pair.close == after then
      return "<cr><up><end><cr>"
    end
  end
  return "<cr>"
end

for _, pair in pairs(pairchars) do
  if pair.open == pair.close then
    vim.keymap.set("i", pair.open, openclose(pair), {
      desc = "Auto-pair " .. pair.open .. pair.close,
      expr = true,
    })
  else
    vim.keymap.set("i", pair.open, open(pair), {
      desc = "Auto-open " .. pair.open .. pair.close,
      expr = true,
    })
    vim.keymap.set("i", pair.close, close(pair), {
      desc = "Auto-close " .. pair.open .. pair.close,
      expr = true,
    })
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
    for _, pairname in pairs(ftrules) do
      local pair = pairchars[pairname]
      bufrules[pair.open] = pair
    end
    vim.b.pairs_rules = bufrules
  end,
})

-- ((surround)) ----------------------------------------------------------------

--- This is true when inside a keymap, if getcharpair should update.
--- @type boolean
local keymap = false

--- @type Pairs.Pair
local paira

--- @type Pairs.Pair
local paird

--- Queries the user for a character and returns the marker set associated with
--- that character or nil if there isn't one.
--- @param source string The source to print on the command line.
--- @return Pairs.Pair
local function getcharpair(source)
  vim.api.nvim_echo({ { source } }, false, {})
  local char = vim.fn.getchar()
  if type(char) == "number" then
    char = string.char(char)
  end
  return pairchars[pairnames[char or 0] or 0]
end

--- Surround operator function. Should never be called manually, only from
--- 'opfunc' internally. When the `keymap` variable is set, this function will
--- ask the user to input a pair character to use, otherwise (during . repeats)
--- it will use the last entered pair.
--- TODO: update indentation/formatting over surround
--- @param mode "char"|"line"|"block"
function Surround(mode)
  if keymap then
    keymap = false
    paira = getcharpair("s")
  end
  if not paira then return end
  local selectstart = vim.api.nvim_buf_get_mark(0, "[")
  local selectend = vim.api.nvim_buf_get_mark(0, "]")
  local lines = vim.api.nvim_buf_get_lines(0, selectstart[1] - 1, selectend[1], false)
  if mode == "char" then
    if #lines == 1 then
      lines[1] = table.concat {
        lines[1]:sub(1, selectstart[2]),
        paira.open,
        lines[1]:sub(selectstart[2] + 1, selectend[2] + 1),
        paira.close,
        lines[1]:sub(selectend[2] + 2),
      }
    else
      lines[1] = lines[1]:sub(1, selectstart[2]) .. paira.open .. lines[1]:sub(selectstart[2] + 1)
      lines[#lines] = lines[#lines]:sub(1, selectend[2] + 1) .. paira.close .. lines[#lines]:sub(selectend[2] + 2)
    end
    vim.api.nvim_buf_set_lines(0, selectstart[1] - 1, selectend[1], false, lines)
  elseif mode == "line" then
    table.insert(lines, 1, paira.open)
    table.insert(lines, paira.close)
    vim.api.nvim_buf_set_lines(0, selectstart[1] - 1, selectend[1], false, lines)
  else -- "block"
    selectend[2] = selectend[2] == #lines[#lines] and -1 or selectend[2]
    lines = vim.tbl_map(function(line)
      return table.concat {
        line:sub(1, selectstart[2]),
        paira.open,
        line:sub(selectstart[2] + 1, selectend[2] >= 0 and selectend[2] + 1 or nil),
        paira.close,
        line:sub(selectend[2] >= 0 and selectend[2] + 2 or #line + 1),
      }
    end, lines)
    vim.api.nvim_buf_set_lines(0, selectstart[1] - 1, selectend[1], false, lines)
  end
end

--- Finds the given markers around the cursor on the current line.
--- TODO: make this use text objects
--- @return integer[]? openpos
--- @return integer[]? closepos
local function findmarkers()
  local line = vim.api.nvim_get_current_line()
  local curpos = vim.api.nvim_win_get_cursor(0)
  local before, after = line:sub(1, curpos[2]), line:sub(curpos[2] + 1)
  local closepos = { after:find(paird.close) }
  if #closepos ~= 2 then return end
  local find, openpos = { before:find(paird.open) }, {}
  while #find > 0 do
    openpos = find
    find = { before:find(paird.open, find[1] + 1) }
  end
  if #openpos ~= 2 then return end
  return openpos, closepos
end

--- Callabck that deletes surroundings.
local function dsurround()
  if keymap then
    keymap = false
    paird = getcharpair("ds")
  end
  if not paird then return end
  local openpos, closepos = findmarkers()
  if not openpos or not closepos then return end
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
  if keymap then
    keymap = false
    local d, a = getcharpair("csd"), getcharpair("csa")
    if not d or not a then return end
    paird, paira = d, a
  end
  if not paird or not paira then return end
  local openpos, closepos = findmarkers()
  if not openpos or not closepos then return end
  local line = vim.api.nvim_get_current_line()
  local curpos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(0, curpos[1] - 1, curpos[1], false, { table.concat {
    line:sub(1, openpos[1] - 1),
    paira.open,
    line:sub(openpos[2] + 1, closepos[1] + curpos[2] - 1),
    paira.close,
    line:sub(closepos[2] + curpos[2] + 1),
  } })
end

vim.keymap.set("", "s", function()
  keymap = true
  vim.o.opfunc = "v:lua.Surround"
  return "g@"
end, { desc = "Surround operator.", expr = true })

vim.keymap.set("n", "ss", function()
  keymap = true
  vim.o.opfunc = "v:lua.Surround"
  return "g@_"
end, { desc = "Surround current line.", expr = true })

vim.keymap.set("n", "S", function()
  keymap = true
  vim.o.opfunc = "v:lua.Surround"
  return "g@$"
end, { desc = "Surround to end of line.", expr = true })

vim.keymap.set("v", "S", function()
  keymap = true
  vim.o.opfunc = "v:lua.Surround"
  if vim.api.nvim_get_mode().mode:sub(1, 1) == "" then
    return "$g@"
  elseif vim.api.nvim_get_mode().mode:sub(1, 1) == "v" then
    return "Vg@"
  end
  return "g@"
end, { desc = "Suround visual lines.", expr = true })

vim.keymap.set("n", "ds", dsurround, { desc = "Delete surroundings." })

vim.keymap.set("n", "cs", csurround, { desc = "Change surroundings." })
