-- simirian's NeoVim
-- basic vim keybinds

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

--- @alias keymap { [1]: string, [2]: string, mode?: vim-mode, opts?: table }

--- @type keymap[]
local maps = {
  -- window  navigation
  { "<C-h>",     "<C-w>h" },
  { "<C-j>",     "<C-w>j" },
  { "<C-k>",     "<C-w>k" },
  { "<C-l>",     "<C-w>l" },
  { "<C-h>",     "<C-\\><C-O><C-w>h", mode = "t" },
  { "<C-j>",     "<C-\\><C-O><C-w>j", mode = "t" },
  { "<C-k>",     "<C-\\><C-O><C-w>k", mode = "t" },
  { "<C-l>",     "<C-\\><C-O><C-w>l", mode = "t" },
  -- cursor movement
  { "j",         "gj" },
  { "k",         "gk" },
  -- quick navigation
  { "<C-d>",     "<C-d>zz" },
  { "<C-u>",     "<C-u>zz" },
  -- resizing splits
  { "<C-Up>",    "<Cmd>resize +1<CR>" },
  { "<C-Down>",  "<Cmd>resize -1<CR>" },
  { "<C-Left>",  "<Cmd>vertical resize -2<CR>" },
  { "<C-Right>", "<Cmd>vertical resize +2<CR>" },
  -- move lines
  { "<A-j>",     ":move +1<cr>" },
  { "<A-k>",     ":move -2<cr>" },
  { "<A-j>",     ":move '>+1<CR>gv",           mode = "x" },
  { "<A-k>",     ":move '<-2<CR>gv",           mode = "x" },
  -- quick escape
  { "kj",        "<Esc>",                      mode = "i" },
  { "jk",        "<Esc>",                      mode = "i" },
  -- use system clipboard
  { "<leader>p", "\"+p" },
  { "<leader>p", "\"+p",                       mode = "x" },
  { "<leader>y", "\"+y",                       mode = "x" },
  -- indentation keeps selection
  { ">",         ">gv",                        mode = "x" },
  { "<",         "<gv",                        mode = "x" },
  { "=",         "=gv",                        mode = "x" },
  -- misc mappings
  { "gT",        "<Cmd>tabedit %<CR>" },
  { "U",         "<C-r>" },
  { "p",         "\"_dP",                      mode = "x" },
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
      local mo = vim.tbl_deep_extend("force", {}, default_opts, v.opts or {})
      vim.keymap.set(v.mode or "n", v[1], v[2], mo)
    end
  end
end

return M
