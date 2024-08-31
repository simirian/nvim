--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                  ~ keys ~                                  --
--------------------------------------------------------------------------------

local M = {}
local H = {}

function H.error(msg)
  vim.notify("keymaps:\n    " .. msg:gsub("\n", "\n    "), vim.log.levels.ERROR)
end

-- leader key
vim.keymap.set("", " ", "<Nop>")
vim.g.mapleader = " "
vim.g.localleader = " "

--- @alias vim-mode string vim mode letters
--- | ""  # all
--- | "n" # normal
--- | "i" # insert
--- | "c" # command
--- | "v" # visual, select
--- | "x" # visual
--- | "s" # select
--- | "o" # operator
--- | "t" # terminal
--- | "l" # insert, command, lang-arg

--- Represents a keymap fot the user to define.
--- @class keymap
--- The left hand side, what triggers the mapping.
--- @field [1] string
--- The right hand side, what the mapping does.
--- @field [2] string
--- Description of the mapping for help information.
--- @field desc string
--- Mode in which this mapping applies.
--- @field mode? vim-mode|vim-moode[]
--- Buffer if this is a buffer local mapping.
--- @field buffer? integer
--- Prevent recursive mappings.
--- @field noremap? boolean
--- Do not wait if mapping is ambiguous
--- @field nowait? boolean
--- Do not print /search info. Consider using :sil for complete silence.
--- @field silent? boolean
--- Fails if a mapping with the given lhs already exists for this mode.
--- @field unique? boolean
local keymap = {
  mode = "n",
  noremap = true,
  silent = true,
}

--- @type keymap[]
M.maps = {
  -- window and tab navigation
  { "<C-h>",     "gT",                desc = "Go to previous tab page." },
  { "<C-j>",     "<C-w>w",            desc = "Focus previous window." },
  { "<C-k>",     "<C-w>W",            desc = "Focus next window." },
  { "<C-l>",     "gt",                desc = "Go to next tab page." },
  { "<C-h>",     "<C-\\><C-O>gT",     desc = "Go to previous tab page.",      mode = "t", },
  { "<C-j>",     "<C-\\><C-O><C-w>w", desc = "Go to previous window.",        mode = "t", },
  { "<C-k>",     "<C-\\><C-O><C-w>W", desc = "Go to next window.",            mode = "t", },
  { "<C-l>",     "<C-\\><C-O>gt",     desc = "go to next tab page.",          mode = "t", },
  -- resizing windows
  { "<C-Up>",    "1<C-w>+",           desc = "Increase window height." },
  { "<C-Down>",  "1<C-w>-",           desc = "Decrease window height." },
  { "<C-Left>",  "2<C-w><",           desc = "Decrease window width." },
  { "<C-Right>", "2<C-w>>",           desc = "Increase window width." },
  -- move lines
  { "<A-j>",     ":move +1<cr>",      desc = "Move line down." },
  { "<A-k>",     ":move -2<cr>",      desc = "Move line up" },
  { "<A-j>",     ":move '>+1<CR>gv",  desc = "Move lines down.",              mode = "x" },
  { "<A-k>",     ":move '<-2<CR>gv",  desc = "Move lines up.",                mode = "x" },
  -- quick escape
  { "kj",        "<Esc>",             desc = "Escape insert mode.",           mode = "i" },
  { "jk",        "<Esc>",             desc = "Escape insert mode.",           mode = "i" },
  -- use system clipboard
  { "<leader>p", "\"+p",              desc = "Paste from system clipboard.",  mode = { "n", "x" } },
  { "<leader>y", "\"+y",              desc = "Yank to system clipboard.",     mode = { "n", "x" } },
  -- misc mappings
  { "U",         "<C-r>",             desc = "Redo." },
  { "<C-f>",     "<Esc>gwapa",        desc = "Format in insert mode.",        mode = "i" },
  { "q:",        "<Nop",              desc = "I don't like command mode." },
  { "p",         "\"_dP",             desc = "Cleanly paste over selection.", mode = "x" },
  -- funky character found with <C-v><C-BS> in insert mode with 'display' uhex
  { "\x08",      "<C-w>",             desc = "Delete back a word.",           mode = "i" },
}

--- Setup keymaps specified on this module under a certain namespace.
--- @param ns? string One of this module's keymap namespaces.
--- @param buffer? boolean|integer The buffer to add keymaps to.
function M.setup(ns, buffer)
  ns = ns or "maps"
  buffer = buffer or false
  for _, map in ipairs(M[ns]) do
    local ok = true
    if not map[1] then
      H.error("Keymapping has no lhs:" .. vim.inspect(map))
      ok = false
    end
    if not map[2] then
      H.error("Keymapping has no rhs:" .. vim.inspect(map))
      ok = false
    end

    if ok then
      local tmp = vim.tbl_deep_extend("keep", map, keymap)
      local lhs = table.remove(tmp, 1)
      local rhs = table.remove(tmp, 1)
      local mode = tmp.mode
      tmp.mode = nil
      tmp.buffer = buffer
      vim.keymap.set(mode, lhs, rhs, tmp)
    end
  end
end

--- Removes all keymaps in a specified namespace.
--- @param ns string The namespace to remove from.
--- @param buffer? boolean|integer The buffer to remove keymaps from.
function M.remove(ns, buffer)
  if not ns then
    H.error("No namespace provided for remove()")
    return
  end
  if not M[ns] then
    H.error("Unrecognized namespace provided to remove(): " .. ns)
    return
  end
  buffer = buffer or false
  for _, v in ipairs(M[key]) do
    vim.keymap.del(v.mode, v[1], { buffer = buffer })
  end
end

return M
