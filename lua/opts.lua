-- simple vim options
-- by simirian

local o = vim.opt
local g = vim.g
local vfn = vim.fn
local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
  pattern = { "text", "markdown" },
  callback = function()
    if vim.bo.textwidth == 0 then
      vim.bo.textwidth = 80
    end
    vim.wo.spell = true
  end
})
-- textwidth colorcolumn
autocmd("BufWinEnter", {
  callback = function()
    local tw = vim.bo.textwidth
    vim.wo.colorcolumn = tw == 0 and "81" or "+1"
  end
})

o.cursorline = true

o.guicursor = {
  "n-v-sm:block",
  "o-r-cr:hor20",
  "i-c-ci:ver25",
}

o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevelstart = 99

o.wrap = false
o.linebreak = true

o.tabstop = 2
o.shiftwidth = 0
o.expandtab = true

o.ignorecase = true
o.smartcase = true
o.hlsearch = false
o.wrapscan = true

o.sidescrolloff = 1
o.smoothscroll = true

o.isfname:remove { "[", "]" }
o.suffixesadd = { ".md" }

o.termguicolors = true
o.switchbuf = "useopen,uselast"

if vim.loop.os_uname().sysname == "Windows_NT" then
  o.shell = vfn.executable("pwsh") == 1 and "pwsh" or "powershell"
  o.shellcmdflag =
  "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  o.shellredir = "2>&1 | %%{ \"$_\" } | Out-File %s; exit $LastExitCode"
  o.shellpipe = "2>&1 | %%{ \"$_\" } | tee.exe %s; exit $LastExitCode"
  o.shellquote = ""
  o.shellxquote = ""
end

-- disable unwanted providers
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

autocmd({ "BufEnter", "TermOpen" }, { pattern = "term://*", command = "startinsert" })
autocmd("TermLeave", { command = "stopinsert" })
