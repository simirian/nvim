--- simirian's NeoVim
--- autopairs and surrounds

local M = {}

-- autopairs -------------------------------------------------------------------

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
  local before = line:sub(curpos[2], curpos[2])
  local after = line:sub(curpos[2] + 1, curpos[2] + 1)
  for _, pair in ipairs(vim.b.pairs_rules --[[@as Pairs.Rule[] ]]) do
    if pair.open == before and pair.close == after then
      paircounts[pair.close] = paircounts[pair.close] and paircounts[pair.close] > 1 and paircounts[pair.close] - 1 or nil
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
  local before = line:sub(1, curpos[2])
  local after = line:sub(curpos[2] + 1)
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

function M.pairdisable()
  vim.api.nvim_create_augroup("pairs", {clear = true})
end
