-- simirian's NeoVim
-- basic vim keybinds

local vim_map = vim.keymap.set

--- Map a vum command
--- @param vm vim-mode
--- @param lhs string pattern to change
--- @param rhs string what to change it to
local function map(vm, lhs, rhs)
  vim_map(vm, lhs, rhs, {
    noremap = true,
    silent = true,
  })
end

-- leader key
map("", "<Space>", "<Nop>")
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

-- NORMAL --
-- window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- normal cursor movement
map("n", "j", "gj")
map("n", "k", "gk")

-- line movement
map("n", "<A-j>", "<Cmd>move +1<CR>")
map("n", "<A-k>", "<Cmd>move -2<CR>")

-- quick navigation
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- resizing splits
map("n", "<C-Up>", "<Cmd>resize +1<CR>")
map("n", "<C-Down>", "<Cmd>resize -1<CR>")
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>")

-- use system clipboard
map("n", "<leader>p", "\"+p")

map("n", "gT", "<Cmd>tabedit %<CR>")
map("n", "U", "<C-r>")

-- INSERT --
map("i", "kj", "<Esc>")
map("i", "jk", "<Esc>")

-- VISUAL --
-- paste over keeps selection
map("x", "p", "\"_dP")

-- use system clipboard
map("x", "<leader>y", "\"+y")
map("x", "<leader>p", "\"+p")

-- indentation keeps selection
map("x", ">", ">gv")
map("x", "<", "<gv")
map("x", "=", "=gv")

-- tabs
-- moving text
map("x", "<A-j>", ":move '>+1<CR>gv")
map("x", "<A-k>", ":move '<-2<CR>gv")
