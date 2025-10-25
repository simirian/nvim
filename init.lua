--------------------------------------------------------------------------------
--                          simirian's Neovim                                 --
--                                                          .O.       T.      --
--    .o888o. 8^88^8 8.   .8 8^88^8 888880. 8^88^8   .8.   | \OO.     TTT     --
--    88   ``   88   888o888   88   88   88   88   .8' '8. |  \OOO.   TTT     --
--    `^888o.   88   88 8 88   88   888888    88   88ooo88 |  |'OOOO. TTT     --
--    __   88   88   88   88   88   88   88   88   88```88 |  |  'OOOOTTT     --
--    `^888^` 8u88u8 88   88 8u88u8 88   88 8u88u8 88   88 |  |    'OOTTT     --
--                                                          '.|      'T'      --
--                       github.com/simirian/nvim                             --
--------------------------------------------------------------------------------

vim.cmd.colorscheme("yicks")

-- ((options)) -----------------------------------------------------------------

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

vim.o.swapfile = false
vim.o.shada = ""

--- @diagnostic disable-next-line: undefined-field
if vim.uv.os_uname().sysname == "Windows_NT" then
  vim.o.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
  vim.o.shellcmdflag = "-Command $PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  vim.o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
  vim.o.shellquote, vim.o.shellxquote = "", ""
end

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.g.calendir = vim.fs.normalize(vim.env.HOME .. "/Documents/vault/calendir")

vim.api.nvim_create_autocmd("FileType", {
  desc = "Set textwidth for text and markdown files.",
  pattern = { "text", "markdown" },
  callback = function()
    if vim.bo.textwidth == 0 then
      vim.bo.textwidth = 80
    end
  end,
})

vim.api.nvim_create_autocmd( "FileType", {
  desc = "Set spell only in text and markdown files.",
  callback = function()
    if vim.bo.ft == "text" or vim.bo.ft == "markdown" then
      vim.wo.spell = true
    else
      vim.wo.spell = false
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Ensure colorcolumn matches textwidth.",
  callback = function()
    local tw = vim.bo.textwidth
    vim.wo.colorcolumn = tw == 0 and "81" or "+1"
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen" }, {
  desc = "Enter insert mode upon entering a terminal buffer.",
  pattern = "term://*",
  command = "startinsert",
})
vim.api.nvim_create_autocmd("TermLeave", {
  desc = "Leave insert mode when leaving a terminal buffer.",
  command = "stopinsert",
})

-- ((keymaps)) -----------------------------------------------------------------

vim.keymap.set("", " ", "<Nop>")
vim.g.mapleader = " "
vim.g.localleader = " "

vim.keymap.set("", "<C-h>", "gT", { desc = "Go to previous tab page." })
vim.keymap.set("", "<C-j>", "<C-w>w", { desc = "Focus previous window." })
vim.keymap.set("", "<C-k>", "<C-w>W", { desc = "Focus next window." })
vim.keymap.set("", "<C-l>", "gt", { desc = "Go to next tab page." })
vim.keymap.set("t", "<C-h>", "<C-\\><C-o>gT", { desc = "Go to previous tab page." })
vim.keymap.set("t", "<C-j>", "<C-\\><C-o><C-w>w", { desc = "Go to previous window." })
vim.keymap.set("t", "<C-k>", "<C-\\><C-o><C-w>W", { desc = "Go to next window." })
vim.keymap.set("t", "<C-l>", "<C-\\><C-o>gt", { desc = "Go to next tab page." })

vim.keymap.set("i", "jj", "<esc>", { desc = "Escape insert mode." })
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Leave terminal mode." })

vim.keymap.set("", "<leader>p", '"+p', { desc = "Paste from system clipboard." })
vim.keymap.set("", "<leader>P", '"+P', { desc = "Paste from system clipboard." })
vim.keymap.set("", "<leader>y", '"+y', { desc = "Yank to system clipboard." })
vim.keymap.set("", "<leader>Y", '"+Y', { desc = "Yank to system clipboard." })

vim.keymap.set("", "U", "<C-r>", { desc = "Redo." })
vim.keymap.set("", "-", ":e %:p:s?[/\\\\]$??:h<cr>", { desc = "Open current buffer's parent.", silent = true })
vim.keymap.set("", "_", ":e .<cr>", { desc = "Open nvim's current directory.", silent = true })

-- ((lazy.nvim)) ---------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
--- @diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system { "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  rocks = { enabled = false },
  spec = {
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "main",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter").setup()
        vim.api.nvim_create_autocmd("FileType", {
          desc = "Enable treesitter in supported buffers.",
          callback = function() pcall(vim.treesitter.start) end,
        })
      end
    },
  },
}
