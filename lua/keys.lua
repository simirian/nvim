--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                  ~ keys ~                                  --
--------------------------------------------------------------------------------

-- default mapping options
local default_opts = { noremap = true, silent = true }

-- leader key
vim.keymap.set("", "<Space>", "<Nop>", default_opts)
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

--- @alias keymap { [1]: string, [2]: string, desc: string, mode?: vim-mode|vim-mode[], opts?: table }

--- @type keymap[]
local maps = {
  -- window and tab navigation
  { "<C-h>",     "gT",                desc = "Go to previous tab page." },
  { "<C-j>",     "<C-w>w",            desc = "Focus previous window." },
  { "<C-k>",     "<C-w>W",            desc = "Focus next window." },
  { "<C-l>",     "gt",                desc = "Go to next tab page." },
  { "<C-h>",     "<C-\\><C-O>gT",     desc = "Go to previous tab page.",     mode = "t", },
  { "<C-j>",     "<C-\\><C-O><C-w>w", desc = "Go to previous window.",       mode = "t", },
  { "<C-k>",     "<C-\\><C-O><C-w>W", desc = "Go to next window.",           mode = "t", },
  { "<C-l>",     "<C-\\><C-O>gt",     desc = "go to next tab page.",         mode = "t", },
  -- resizing windows
  { "<C-Up>",    "1<C-w>+",           desc = "Increase window height." },
  { "<C-Down>",  "1<C-w>-",           desc = "Decrease window height." },
  { "<C-Left>",  "2<C-w><",           desc = "Increase window width." },
  { "<C-Right>", "2<C-w>>",           desc = "Decrease window width." },
  -- move lines
  { "<A-j>",     ":move +1<cr>",      desc = "Move line down." },
  { "<A-k>",     ":move -2<cr>",      desc = "Move line up" },
  { "<A-j>",     ":move '>+1<CR>gv",  desc = "Move lines down.",             mode = "x" },
  { "<A-k>",     ":move '<-2<CR>gv",  desc = "Move lines up.",               mode = "x" },
  -- quick escape
  { "kj",        "<Esc>",             desc = "Escape insert mode.",          mode = "i" },
  { "jk",        "<Esc>",             desc = "Escape insert mode.",          mode = "i" },
  -- use system clipboard
  { "<leader>p", "\"+p",              desc = "Paste from system clipboard.", mode = { "n", "x" } },
  { "<leader>y", "\"+y",              desc = "Yank to system clipboard.",    mode = { "n", "x" } },
  -- indentation keeps selection
  --[[
  { ">",         ">gv",               mode = "x" },
  { "<",         "<gv",               mode = "x" },
  { "=",         "=gv",               mode = "x" },
  -- cursor movement
  { "j",         "gj" },
  { "k",         "gk" },
  ]]
  -- quick navigation
  { "<C-d>",     "<C-d>zz",           desc = "Scroll up." },
  { "<C-u>",     "<C-u>zz",           desc = "Scroll down." },
  -- misc mappings
  { "U",         "<C-r>",             desc = "Redo." },
  { "p",         "\"_dP",             desc = "Yank into system clipboard.",  mode = "x" },
  { "<C-f>",     "<Esc>gwapa",        desc = "Format in insert mode.",       mode = "i" },
  -- funky character found with <C-v><C-BS> in insert mode with 'display' uhex
  { "\x08",      "<C-w>",             desc = "Delete back a word.",          mode = "i" },
}

local M = {}

function M.setup()
  for _, v in ipairs(maps) do
    local ok = true
    if not v[1] then
      vim.notify("Keymapping has no lhs:" .. vim.inspect(v),
        vim.log.levels.ERROR, {})
      ok = false
    end
    if not v[2] then
      vim.notify("Keymapping has no rhs:" .. vim.inspect(v),
        vim.log.levels.ERROR, {})
      ok = false
    end

    if ok then
      local mo = vim.tbl_deep_extend("force",
        {}, default_opts, v.opts or {}, { desc = v.desc })
      vim.keymap.set(v.mode or "n", v[1], v[2], mo)
    end
  end
end

return M
