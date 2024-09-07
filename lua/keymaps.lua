--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                  ~ keys ~                                  --
--------------------------------------------------------------------------------

local M = {}
local H = {}

-- helper functions {{{1

--- H.error() {{{2
--- Prints an error message appropriate to the module.
--- @param msg string The error message.
function H.error(msg)
  vim.notify("keymaps:\n    " .. msg:gsub("\n", "\n    "), vim.log.levels.ERROR)
end

-- definitions {{{1
-- leader key {{{2
vim.keymap.set("", " ", "<Nop>")
vim.g.mapleader = " "
vim.g.localleader = " "

--- vim-mode {{{2
--- Valid mode letters for keymaps.
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

--- keymap {{{2
--- Represents a keymap fot the user to define.
--- @class keymap
--- The left hand side, what triggers the mapping.
--- @field [1] string
--- The right hand side, what the mapping does.
--- @field [2] string|fun()
--- Description of the mapping for help information.
--- @field desc string
--- Mode in which this mapping applies.
--- @field mode? vim-mode|vim-mode[]
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

--- M.maps {{{2
--- Default maps.
--- @type keymap[]
M.maps = {
  -- window and tab navigation {{{3
  { "<C-h>",     "gT",                desc = "Go to previous tab page." },
  { "<C-j>",     "<C-w>w",            desc = "Focus previous window." },
  { "<C-k>",     "<C-w>W",            desc = "Focus next window." },
  { "<C-l>",     "gt",                desc = "Go to next tab page." },
  { "<C-h>",     "<C-\\><C-O>gT",     desc = "Go to previous tab page.",      mode = "t", },
  { "<C-j>",     "<C-\\><C-O><C-w>w", desc = "Go to previous window.",        mode = "t", },
  { "<C-k>",     "<C-\\><C-O><C-w>W", desc = "Go to next window.",            mode = "t", },
  { "<C-l>",     "<C-\\><C-O>gt",     desc = "go to next tab page.",          mode = "t", },
  -- resizing windows {{{3
  { "<C-Up>",    "1<C-w>+",           desc = "Increase window height." },
  { "<C-Down>",  "1<C-w>-",           desc = "Decrease window height." },
  { "<C-Left>",  "2<C-w><",           desc = "Decrease window width." },
  { "<C-Right>", "2<C-w>>",           desc = "Increase window width." },
  -- move lines {{{3
  { "<A-j>",     ":move +1<cr>",      desc = "Move line down." },
  { "<A-k>",     ":move -2<cr>",      desc = "Move line up" },
  { "<A-j>",     ":move '>+1<CR>gv",  desc = "Move lines down.",              mode = "x" },
  { "<A-k>",     ":move '<-2<CR>gv",  desc = "Move lines up.",                mode = "x" },
  -- quick escape {{{3
  { "kk",        "<Esc>",             desc = "Escape insert mode.",           mode = "i" },
  -- registers {{{3
  { "<leader>p", "\"_d\"+P",          desc = "Paste from system clipboard.",  mode = { "n", "x" } },
  { "<leader>y", "\"+y",              desc = "Yank to system clipboard.",     mode = { "n", "x" } },
  { "p",         "\"_dP",             desc = "Cleanly paste over selection.", mode = "x" },
  -- indenting {{{3
  { "<Tab>",     ">gv",               desc = "Indent selected liens",         mode = "v" },
  { "<S-Tab>",   "<gv",               desc = "Unindent selected lines",       mode = "v" },
  -- misc mappings {{{3
  { "U",         "<C-r>",             desc = "Redo." },
  { "<C-f>",     "<Esc>m`gqap``a",    desc = "Format in insert mode.",        mode = "i" },
  { "cw",        "caw",               desc = "Change to next word." },
  -- funky character found with <C-v><C-BS> in insert mode with 'display' uhex
  { "\x08",      "<C-w>",             desc = "Delete back a word.",           mode = "i" },
}

-- module functions {{{1

--- M.setup() {{{2
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

--- M.remove() {{{2
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
  for _, v in ipairs(M[ns]) do
    vim.keymap.del(v.mode, v[1], { buffer = buffer })
  end
end

return M
-- vim:fdm=marker
