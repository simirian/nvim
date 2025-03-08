local H = {}

--- Map of open characters to close characters.
H.open = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ['"'] = '"',
  ["'"] = "'",
  ["`"] = "`",
}

--- Map of close chars to open chars and the number of those close chars that
--- can be overwritten in this insertion.
H.close = {
  [")"] = { "(", 0 },
  ["]"] = { "[", 0 },
  ["}"] = { "{", 0 },
  ['"'] = { '"', 0 },
  ["'"] = { "'", 0 },
  ["`"] = { "`", 0 },
}

--- Feeds keys to nvim like maps without having to repeat annoying escapes.
--- @param map string The map that should happen.
--- @param remap? boolean If remappings should be allowed.
function H.feed(map, remap)
  local keys = vim.api.nvim_replace_termcodes(map, true, true, true)
  vim.api.nvim_feedkeys(keys, "n", remap or false)
end

--- Callback for typing the opening character of a pair, eg. "(".
--- @param char string The opening character typed.
function H.pairopen(char)
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local after = line:sub(col + 1, col + 1)
  if line:sub(col, col) ~= "\\" and after == "" or after:match("[%s%)%]}\"'`]") then
    local close = H.open[char]
    H.feed(char .. close .. "<left>")
    H.close[close][2] = H.close[close][2] + 1
  else
    H.feed(char)
  end
end

--- Callback for typing the closing character of a pair, eg ")".
--- @param char string The closing character typed.
function H.pairclose(char)
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if H.close[char][2] > 0 and line:sub(col + 1, col + 1) == char then
    H.feed("<right>")
    H.close[char][2] = H.close[char][2] - 1
  else
    H.feed(char)
  end
end

--- Callback for typing characters which both open and close pairs, eg. '"'.
--- @param char string The character which is being typed.
function H.openclose(char)
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if line:sub(col + 1, col + 1) == H.close[char][1] then
    H.feed("<right>")
  elseif line:sub(col, col) ~= "\\" then
    H.feed(char .. char .. "<left>")
  else
    H.feed(char)
  end
end

--- Callback to delete a pair.
function H.delpair()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local after = line:sub(col + 1, col + 1)
  if H.open[line:sub(col, col)] == after then
    H.feed("<bs><del>")
    if H.close[after][2] > 0 then
      H.close[after][2] = H.close[after][2] - 1
    end
  else
    H.feed("<bs>")
  end
end

--- Callback to separate a pair over a newline.
function H.pairenter()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(col, col)
  local after = line:sub(col + 1, col + 1)
  print("pair <cr>")
  if H.open[before] == after and before ~= after then
    H.feed("<cr><up><end><cr>")
  else
    H.feed("<cr>")
  end
end

local keys = require("keymaps")

-- set the basic pair functionality keymaps
for open, close in pairs(H.open) do
  if open == close then
    keys.add("pairs", {
      open,
      function() H.openclose(open) end,
      desc = "Open or close " .. open .. " pairs.",
      mode = "i"
    })
  else
    keys.add("pairs", { {
      open,
      function() H.pairopen(open) end,
      desc = "Automatically close " .. open .. ".",
      mode = "i",
    }, {
      close,
      function() H.pairclose(close) end,
      desc = "Write over " .. close .. " after an automatic pair close.",
      mode = "i",
    } })
  end
end
keys.add("pairs", { "<bs>", H.delpair, desc = "Delete a pair.", mode = "i" })
keys.add("pairs", { "<cr>", H.pairenter, desc = "Split pairs neatly over new lines.", mode = "i" })

keys.bind("pairs")

-- remove
vim.api.nvim_create_augroup("pairs", { clear = false })
vim.api.nvim_create_autocmd("InsertLeave", {
  desc = "Prevent overwriting close pairs from this insertion later.",
  group = H.augroup,
  callback = function()
    for _, close in pairs(H.close) do
      close[2] = 0
    end
  end,
})
