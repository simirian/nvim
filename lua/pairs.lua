--- simirian's NeoVim
--- autopairs

local M = {}
local H = {}

--- Public rule presets for useful rules.
--- @type table<string, Pairs.Rule>
M.rules = {
  parens = { type = "simple", open = "(", close = ")" },
  brackets = { type = "simple", open = "[", close = "]" },
  braces = { type = "simple", open = "{", close = "}" },
  quote = { type = "simple", open = '"', close = '"' },
  triquote = { type = "regex", open = '"""$', close = '"""' },
  apostrophe = { type = "simple", open = "'", close = "'" },
  tripostrophe = { type = "regex", open = "'''$", close = "'''" },
  grave = { type = "simple", open = "`", close = "`" },
  trigrave = { type = "regex", open = "```$", close = "```" },
  ccomment = { type = "regex", open = "/%*$", close = "*/" },
  tag = { type = "regex", open = "<([^%s<>]+)[^<>]*>$", close = "</%1>" },
  tagcomment = { type = "regex", open = "<!%-%-$", close = "-->" },
}

--- Defualt pair rules.
--- @type table<string, Pairs.Rule[]>
H.rules = {
  default = {
    M.rules.parens,
    M.rules.brackets,
    M.rules.braces,
    M.rules.quote,
    M.rules.apostrophe,
    M.rules.grave,
    M.rules.ccomment,
  },
  html = {
    M.rules.tagcomment,
    M.rules.tag,
    M.rules.quote,
  },
  markdown = {
    M.rules.parens,
    M.rules.brackets,
    M.rules.braces,
    M.rules.quote,
    M.rules.trigrave,
  }
}

--- Map of closing characters to the number of times they can be typed over this
--- insert mode session.
--- @type table<string, integer>
H.paircounts = {}

--- @type { coord: integer[], type: "none"|"absolute"|"offset" }
H.surroundstate = { coord = { 0, 0 }, type = "none" }

--- Rule for pairing (and also deleting) items.
--- @class Pairs.Rule
--- The type of rule it is.
--- @field type "simple"|"tag"|"regex"
--- The starting pattern for the rule.
--- @field open string
--- The ending pattern of the rule.
--- @field close string

--- The context needed to asses pair invocation.
--- @class Pairs.Context
--- The character causing invocation.
--- @field char string
--- The part of the line before the cursor.
--- @field before string
--- The part of the line after the cursor.
--- @field after string

--- Feeds keys to nvim like maps without having to repeat annoying escapes.
--- @param map string The map that should happen.
function H.feed(map)
  vim.api.nvim_feedkeys(vim.keycode(map), "n", false)
end

--- Checks if there is a simple rule in the list which char closes.
--- @param rules Pairs.Rule[] The pairs to check.
--- @param char string The character to check if it closes.
--- @return boolean closes
function H.char_closes(rules, char)
  for _, rule in ipairs(rules) do
    if rule.type == "simple" and rule.close == char then return true end
  end
  return false
end

--- Gets the current position that pairs should close from based on the current
--- surround state.
--- @return integer[] position
function H.get_close_pos()
  local curpos = vim.api.nvim_win_get_cursor(0)
  if H.surroundstate.type == "offset" then
    return {
      curpos[1] + H.surroundstate.coord[1],
      curpos[2] + H.surroundstate.coord[2],
    }
  end
  if H.surroundstate.type == "absolute" then
    return H.surroundstate.coord
  end
  return curpos
end

--- Gets the context around the cursor.
--- @return Pairs.Context
function H.get_context()
  local curpos = vim.api.nvim_win_get_cursor(0)
  local closepos = H.get_close_pos()
  return {
    before = vim.api.nvim_get_current_line():sub(1, curpos[2]),
    after = vim.api.nvim_buf_get_lines(0, closepos[1] - 1, closepos[1], false)[1]:sub(closepos[2] + 1),
    char = vim.v.char,
  }
end

--- Inserts text acter the cursor.
--- @param char string The character which triggered autopairing.
--- @param text string The text to insert.
function H.paircomplete(char, text)
  vim.v.char = ""
  vim.schedule(function()
    local curpos = vim.api.nvim_win_get_cursor(0)
    local curline = vim.api.nvim_get_current_line()
    vim.api.nvim_buf_set_lines(0, curpos[1] - 1, curpos[1], false, {
      curline:sub(1, curpos[2]) .. char .. curline:sub(curpos[2] + 1)
    })
    vim.api.nvim_win_set_cursor(0, { curpos[1], curpos[2] + 1 })
    local closepos = H.get_close_pos()
    local closeline = vim.api.nvim_buf_get_lines(0, closepos[1] - 1, closepos[1], false)[1]
    vim.api.nvim_buf_set_lines(0, closepos[1] - 1, closepos[1], false, {
      closeline:sub(1, closepos[2]) .. text .. closeline:sub(closepos[2] + 1)
    })
  end)
end

--- Steps over the next character.
function H.stepover()
  H.feed("<right>")
  vim.v.char = ""
end

--- Attempts to perform a regex autopairing. Returns true if the auto-pairing
--- was actually performed.
--- @param rule Pairs.Rule The regex rule to check and apply.
--- @param context Pairs.Context The context in which to execute the rule.
--- @return boolean paired
function H.regex(rule, context)
  local matches = { (context.before .. context.char):match(rule.open) }
  if #matches == 0 then return false end
  local rep = rule.close:gsub("%%%%", "\n")
  for i, match in ipairs(matches) do
    match = match:gsub("%%", "\n")
    rep = rep:gsub("%%" .. i, match)
  end
  H.paircomplete(context.char, rep:gsub("\n", "%%"))
  return true
end

--- Checks() if a simple rule should be applied, and if it should then it is
--- executed and this return true. If it should not be applied then this returns
--- false and does nothing else.
--- @param rule Pairs.Rule The regex rule to check and apply.
--- @param context Pairs.Context The context in which to execute the rule.
--- @return boolean paired
function H.simple(rule, context)
  local ac = context.after:sub(1, 1)
  if H.surroundstate.type == "absolute" then print("absolute", vim.inspect(H.surroundstate.coord)) end
  if H.surroundstate.type == "none"
      and context.char == rule.close and ac == rule.close
      and H.paircounts[rule.close] and H.paircounts[rule.close] > 0
  then
    H.stepover()
    H.paircounts[rule.close] = H.paircounts[rule.close] - 1
    return true
  end
  if context.char == rule.open
      and (ac == ""
        or ac:match("[%s%.]")
        or H.char_closes(vim.b.pairs_rules or {}, ac))
  then
    H.paircomplete(context.char, rule.close)
    H.paircounts[rule.close] = H.paircounts[rule.close] and H.paircounts[rule.close] + 1 or 1
    return true
  end
  return false
end

--- Callback for InsertCharPre which delegates pairing to one of the pairing
--- functions, supplying them with the rule and context. Accepts the first pair
--- which matches in b:pairs_rules.
function H.autopair()
  local context = H.get_context()
  for _, rule in ipairs(vim.b.pairs_rules or {}) do
    if H[rule.type](rule, context) then
      return
    end
  end
end

--- Deletes a simple pair if the cursor is between two simple pair characters.
function H.del()
  local context = H.get_context()
  for _, rule in ipairs(vim.b.pairs_rules or {}) do
    if rule.type == "simple"
        and rule.open == context.before:sub(#context.before)
        and rule.close == context.after:sub(1, 1)
    then
      if H.paircounts[rule.close] and H.paircounts[rule.close] > 0 then
        H.paircounts[rule.close] = H.paircounts[rule.close] - 1
      end
      local closepos = H.get_close_pos()
      local line = vim.api.nvim_buf_get_lines(0, closepos[1] - 1, closepos[1], false)[1]
      vim.api.nvim_buf_set_lines(0, closepos[1] - 1, closepos[1], false, {
        line:sub(1, closepos[2]) .. line:sub(closepos[2] + 2)
      })
    end
  end
  H.feed("<bs>")
end

--- Splits a pair over new lines if the cursor is betwen simple pair ends.
function H.cr()
  local function docr()
    H.feed("<cr><up><end><cr>")
  end
  local context = H.get_context()
  for _, rule in ipairs(vim.b.pairs_rules or {}) do
    if rule.type == "simple"
        and rule.open == context.before:sub(#context.before)
        and rule.close == context.after:sub(1, 1)
    then
      docr()
      return
    elseif rule.type == "regex" then
      local matches = { context.before:match(rule.open) }
      if #matches > 0 then
        local rep = context.after:gsub("%%%%", "\n")
        for i, match in ipairs(matches) do
          rep = rep:gsub("%%" .. i, match:gsub("%%", "\n"))
        end
        rep = rep:gsub("\n", "%%")
        if context.after:sub(1, #rep) == rep then
          docr()
          return
        end
      end
    end
  end
  H.feed("<cr>")
end

--- Operator function for surrounding text.
--- @param mode "line"|"char"|"block" The selection mode.
function M._opfunc(mode)
  -- TODO line and block surround
  if mode ~= "char" then return end
  local start = vim.api.nvim_buf_get_mark(0, "[")
  local stop = vim.api.nvim_buf_get_mark(0, "]")
  stop[2] = stop[2] + 1
  if start[1] == stop[1] then
    H.surroundstate = { coord = { stop[1] - start[1], stop[2] - start[2] }, type = "offset" }
  else
    H.surroundstate = { coord = stop, type = "absolute" }
  end
  vim.cmd.startinsert()
end

--- Sets the defeult and override rules, as well as activating the autocommands
--- and setting keymaps.
function M.setup(opts)
  opts = opts or {}
  vim.api.nvim_create_augroup("pairs", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    desc = "Attach pairs to buffer.",
    group = H.augroup,
    callback = function()
      local ft = vim.bo.filetype
      vim.b.pairs_rules = opts[ft] or opts.default or H.rules[ft] or H.rules.default
    end
  })
  vim.api.nvim_create_autocmd("InsertCharPre", {
    desc = "Autopair completion.",
    group = H.augroup,
    callback = H.autopair,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    desc = "Reset pair typeover counts and surround state.",
    group = H.augroup,
    callback = function()
      H.paircounts = {}
      H.surroundstate = { coord = { 0, 0 }, type = "none" }
    end
  })

  vim.keymap.set("i", "<bs>", H.del, { desc = "Delete a pair." })
  vim.keymap.set("i", "<cr>", H.cr, { desc = "Neatly split a pair over lines." })
  vim.keymap.set("", "s", "<cmd>set opfunc=v:lua.require'pairs'._opfunc<cr>g@",
    { desc = "Surround operator." })
end

return M
