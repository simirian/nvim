-- simple vim options
-- by simirian

vim.o.cursorline = true
vim.o.showmode = false
vim.o.wrap = false

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99

vim.o.tabstop = 2
vim.o.shiftwidth = 0
vim.o.expandtab = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false

vim.o.path = ".,,**"
vim.opt.isfname:remove { "[", "]" }
vim.opt.suffixesadd = { ".md" }

--- @diagnostic disable-next-line: undefined-field
if vim.loop.os_uname().sysname == "Windows_NT" then
  vim.o.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
  vim.o.shellcmdflag = "-Command $PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  vim.o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
  vim.o.shellquote, vim.o.shellxquote = "", ""
end

-- disable unwanted providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.api.nvim_create_autocmd("FileType", {
  desc = "Set textwidth for text and markdown files.",
  pattern = { "text", "markdown" },
  callback = function()
    if vim.bo.textwidth == 0 then
      vim.bo.textwidth = 80
    end
    vim.wo.spell = true
  end
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Ensure colorcolumn matches textwidth.",
  callback = function()
    local tw = vim.bo.textwidth
    vim.wo.colorcolumn = tw == 0 and "81" or "+1"
  end
})

vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen" }, {
  desc = "Enter insert mode upon entering a terminal buffer.",
  pattern = "term://*", command = "startinsert"
})
vim.api.nvim_create_autocmd("TermLeave", {
  desc = "Leave insert mode when leaving a terminal buffer.",
  command = "stopinsert"
})
