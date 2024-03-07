-- simirian's NeoVim
-- basic vim keybinds

local opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- leader key
map("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.localleader = " "

-- NORMAL --
-- window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- normal cursor movement
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)

-- line movement
map("n", "<A-j>", "<Cmd>move +1<CR>", opts)
map("n", "<A-k>", "<Cmd>move -2<CR>", opts)

-- quick navigation
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)

-- resizing splits
map("n", "<C-Up>", "<Cmd>resize +1<CR>", opts)
map("n", "<C-Down>", "<Cmd>resize -1<CR>", opts)
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", opts)
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", opts)

-- use system clipboard
map("n", "<leader>p", "\"+p", opts)

map("n", "gT", "<Cmd>tabedit %<CR>", opts)
map("n", "U", "<C-r>", opts)

-- INSERT --
map("i", "kj", "<Esc>", opts)
map("i", "jk", "<Esc>", opts)

-- VISUAL --
-- paste over keeps selection
map("v", "p", "\"_dP", opts)

-- use system clipboard
map("v", "<leader>y", "\"+y", opts)
map("v", "<leader>p", "\"+p", opts)

-- indentation keeps selection
map("v", ">", ">gv", opts)
map("v", "<", "<gv", opts)
map("v", "=", "=gv", opts)

-- tabs
-- moving text
map("v", "<A-j>", ":move '>+1<CR>gv", opts)
map("v", "<A-k>", ":move '<-2<CR>gv", opts)
