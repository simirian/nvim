-- simirian's NeoVim
-- basic vim options

local o = vim.opt
local g = vim.g
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- editor appearance
o.colorcolumn = "80"
o.number = true
o.relativenumber = true
o.numberwidth = 2
o.scrolloff = 4
o.sidescrolloff = 4
o.signcolumn = "yes"
o.cmdheight = 1
o.showmode = false
o.showtabline = 2
o.cursorline = true
o.wrap = false

-- show whitespace characters as follows
o.list = true
o.listchars = {
  eol = "↩",
  tab = "▏ ",
  leadmultispace = "▏ ",
  extends = "+",
  precedes = "+",
}

-- file options
o.encoding = "utf8"
o.fileencoding = "utf8"
o.fileformats = "unix,dos" -- line endings

-- colors
o.syntax = "ON"
o.termguicolors = true

-- search
o.ignorecase = true
o.smartcase = true -- ignores case unless there are capitals
o.incsearch = true
o.hlsearch = false
o.wrapscan = true

-- indentation
o.expandtab = true -- use spaces where tabs don't matter
o.tabstop = 2 -- tab size
o.softtabstop = 2 -- simulated tab size
o.shiftwidth = 0 -- uses tabstop

-- splits
o.splitright = true
o.splitbelow = true

-- disable unwanted providers
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

-- misc
o.timeoutlen = 3000 -- timeout length in ms
o.updatetime = 50 -- time before completions in ms

-- nvim should use powershell on windows
if vim.fn.has("win32") == 1 then
  vim.o.shell = "powershell"
  vim.o.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  vim.o.shellredir = "2>&1 | %%{ \"$_\" } | Out-File %s; exit $LastExitCode"
  vim.o.shellpipe  = "2>&1 | %%{ \"$_\" } | Tee-Object %s; exit $LastExitCode"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end

-- autocommands
-- plaintext files should wrap
augroup("filetype", { clear = false })
autocmd("FileType", {
  pattern = { "text", "markdown" },
  group = "filetype",
  command = "setlocal wrap",
})

-- terminal specific settings
augroup("terminal", { clear = false })
autocmd({ "BufEnter", "TermOpen" }, {
  pattern = "term://*",
  group = "terminal",
  callback = function()
    vim.cmd("startinsert")
    vim.cmd("setlocal nonumber norelativenumber")
  end
})
autocmd("BufLeave", {
  pattern = "term://*",
  group = "terminal",
  command = "stopinsert",
})

