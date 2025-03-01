--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                  ~ opts ~                                  --
--------------------------------------------------------------------------------

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

o.cursorcolumn = false
o.cursorline = true
o.cursorlineopt = "both"

o.laststatus = 2
o.showtabline = 2
o.number = true
o.signcolumn = "yes:1"

o.shortmess = "lmrOstTcCFS"
o.showcmd = false
o.showmode = false
o.confirm = true

o.guifont = "JetBrainsMono NFM:h9"
o.display = { "truncate", "uhex" }
o.fillchars = {
  horiz = " ",
  horizup = " ",
  horizdown = " ",
  vert = " ",
  vertleft = " ",
  vertright = " ",
  verthoriz = " ",
}
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
o.breakat = "/- "
o.showbreak = "^ "

o.virtualedit = { "block" }

o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 0
o.expandtab = true
o.shiftround = true

o.startofline = true
o.matchpairs = "(:),{:},[:],<:>"
o.whichwrap = "b,<,>,[,]"

o.ignorecase = true
o.smartcase = true
o.hlsearch = false
o.wrapscan = true

o.sidescrolloff = 1
o.smoothscroll = true

o.cdhome = true
o.isfname:remove { "[", "]" }
o.suffixesadd = { ".md" }

o.winaltkeys = "no"
o.termguicolors = true
o.title = true
o.titlestring = "%t %M NVIM"
o.mousemodel = "popup"
o.switchbuf = "useopen,uselast"
o.equalalways = false
o.wildignorecase = true

if vim.loop.os_uname().sysname == "Windows_NT" then
  o.shell        = vfn.executable("pwsh") == 1 and "pwsh" or "powershell"
  o.shellcmdflag =
  "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  o.shellredir   = "2>&1 | %%{ \"$_\" } | Out-File %s; exit $LastExitCode"
  o.shellpipe    = "2>&1 | %%{ \"$_\" } | tee.exe %s; exit $LastExitCode"
  o.shellquote   = ""
  o.shellxquote  = ""
end

-- disable unwanted providers
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

autocmd({ "BufEnter", "TermOpen" }, {
  pattern = "term://*",
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.cmd.startinsert()
  end
})
autocmd("TermLeave", { command = "stopinsert" })
