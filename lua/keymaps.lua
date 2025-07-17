-- simirian's NeoVim
-- keymaps

-- set leader key
vim.keymap.set("", " ", "<Nop>")
vim.g.mapleader = " "
vim.g.localleader = " "

-- window and tab navigation
vim.keymap.set("", "<C-h>", "gT", { desc = "Go to previous tab page." })
vim.keymap.set("", "<C-j>", "<C-w>w", { desc = "Focus previous window." })
vim.keymap.set("", "<C-k>", "<C-w>W", { desc = "Focus next window." })
vim.keymap.set("", "<C-l>", "gt", { desc = "Go to next tab page." })
vim.keymap.set("t", "<C-h>", "<C-\\><C-o>gT", { desc = "Go to previous tab page." })
vim.keymap.set("t", "<C-j>", "<C-\\><C-o><C-w>w", { desc = "Go to previous window." })
vim.keymap.set("t", "<C-k>", "<C-\\><C-o><C-w>W", { desc = "Go to next window." })
vim.keymap.set("t", "<C-l>", "<C-\\><C-o>gt", { desc = "Go to next tab page." })

-- quick escape
vim.keymap.set("i", "jj", "<esc>", { desc = "Escape insert mode." })
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Leave terminal mode." })

-- clipboard
vim.keymap.set("", "<leader>p", "\"+p", { desc = "Paste from system clipboard." })
vim.keymap.set("", "<leader>y", "\"+y", { desc = "Yank to system clipboard." })

-- indenting
vim.keymap.set("v", "<tab>", ">gv", { desc = "Indent selected liens" })
vim.keymap.set("v", "<S-tab>", "<gv", { desc = "Unindent selected lines" })

-- misc mappings
vim.keymap.set("", "U", "<C-r>", { desc = "Redo." })
-- funky character found with <C-v><C-BS> in insert mode with 'display' uhex
vim.keymap.set("i", "\x08", "<C-w>", { desc = "Delete back a word." })
vim.keymap.set("", "-", ":e %:h<cr>", { desc = "Open current buffer's parent." })
vim.keymap.set("", "_", ":e .<cr>", { desc = "Open nvim's current directory." })
