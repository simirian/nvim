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

--- @diagnostic disable-next-line: undefined-field
if vim.loop.os_uname().sysname == "Windows_NT" then
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

vim.keymap.set("", "<leader>p", "\"+p", { desc = "Paste from system clipboard." })
vim.keymap.set("", "<leader>y", "\"+y", { desc = "Yank to system clipboard." })

vim.keymap.set("v", "<tab>", ">gv", { desc = "Indent selected liens" })
vim.keymap.set("v", "<S-tab>", "<gv", { desc = "Unindent selected lines" })

vim.keymap.set("", "U", "<C-r>", { desc = "Redo." })
vim.keymap.set("", "-", ":e %:h<cr>", { desc = "Open current buffer's parent." })
vim.keymap.set("", "_", ":e .<cr>", { desc = "Open nvim's current directory." })

-- ((commands)) ----------------------------------------------------------------

local function opendaily(time)
  local calendir = vim.fs.normalize(vim.env.HOME .. "/Documents/vault/daily")
  vim.fn.mkdir(calendir .. os.date("/%Y/%m", time), "p")
  vim.cmd.edit(calendir .. os.date("/%Y/%m/%d.md", time))
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines == 1 and lines[1] == "" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { os.date("# Daily %Y-%m-%d", time) --[[@as string]] })
  end
end

vim.api.nvim_create_user_command("Today", function()
  opendaily(os.time())
end, { desc = "Open today's daily note." })

vim.api.nvim_create_user_command("Yesterday", function()
  local date = os.date("*t")
  date.day = date.day - 1
  opendaily(os.time(date --[[@as osdateparam]]))
end, { desc = "Open yesterday's daily note." })

vim.api.nvim_create_user_command("Scratch", function(args)
  local bufname = "scratch"
  bufname = bufname .. ((args.count and args.count ~= 0) and args.count or "")
  local bufnr = vim.fn.bufnr(bufname)
  if bufnr == -1 then
    bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(bufnr, bufname)
  end
  if args.fargs[1] then
    vim.bo[bufnr].ft = args.fargs[1]
  end
  vim.cmd("buffer" .. (args.bang and "! " or " ") .. bufname)
end, { desc = "Open a scratch buffer.", count = 0, bang = true, bar = true, nargs = "?" })

vim.api.nvim_create_user_command("AnnabellLee", function(args)
  local bufnr = vim.fn.bufnr("annabel-lee")
  if bufnr == -1 then
    bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(bufnr, "annabel-lee")
    local oldul = vim.bo[bufnr].ul
    vim.bo[bufnr].ul = -1
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "*Annabel Lee* by Edgar Allen Poe",
      "",
      "It was many and many a year ago,",
      "   In a kingdom by the sea,",
      "That a maiden there lived whom you may know",
      "   By the name of Annabel Lee;",
      "And this maiden she lived with no other thought",
      "   Than to love and be loved by me.",
      "",
      "*I* was a child and *she* was a child,",
      "   In this kingdom by the sea,",
      "But we loved with a love that was more than love---",
      "   I and my Annabel Lee---",
      "With a love that the wingèd seraphs of Heaven",
      "   Coveted her and me.",
      "",
      "And this was the reason that, long ago,",
      "   In this kingdom by the sea,",
      "A wind blew out of a cloud, chilling",
      "   My beautiful Annabel Lee;",
      "So that her highborn kinsmen came",
      "   And bore her away from me,",
      "To shut her up in a sepulchre",
      "   In this kingdom by the sea.",
      "",
      "The angels, not half so happy in Heaven,",
      "   Went envying her and me---",
      "Yes!---that was the reason (as all men know,",
      "   In this kingdom by the sea)",
      "That the wind came out of the cloud by night,",
      "   Chilling and killing my Annabel Lee.",
      "",
      "But our love it was stronger by far than the love",
      "   Of those who were older than we---",
      "   Of many far wiser than we---",
      "And neither the angels in Heaven above",
      "   Nor the demons down under the sea",
      "Can ever dissever my soul from the soul",
      "   Of the beautiful Annabel Lee;",
      "",
      "For the moon never beams, without bringing me dreams",
      "   Of the beautiful Annabel Lee;",
      "And the stars never rise, but I feel the bright eyes",
      "   Of the beautiful Annabel Lee;",
      "And so, all the night-tide, I lie down by the side",
      "   Of my darling---my darling---my life and my bride,",
      "   In her sepulchre there by the sea---",
      "   In her tomb by the sounding sea.",
    })
    vim.bo[bufnr].ul = oldul
  end
  vim.bo[bufnr].ft = "markdown"
  vim.cmd("buffer" .. (args.bang and "! " or " ") .. bufnr)
end, { desc = "Open a scratch bufer with the text of Annabel Lee.", bang = true, bar = true })

-- ((lazy.nvim)) ---------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
--- @diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system { "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  rocks = { enabled = false },
  spec = {
    { "nvim-tree/nvim-web-devicons", lazy = true },
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
    {
      "nvim-telescope/telescope.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "nvim-treesitter/nvim-treesitter",
      },
      config = function()
        local telescope = require("telescope")
        telescope.setup {
          defaults = {
            prompt_prefix = "   ",
            mappings = {
              i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
                ["<Esc>"] = "close",
              },
            },
          },
        }
        local builtin = require("telescope.builtin")
        vim.keymap.set("", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]iles" })
        vim.keymap.set("", "<leader>fg", builtin.live_grep, { desc = "[f]ind [g]rep" })
        vim.keymap.set("", "<leader>fb", builtin.buffers, { desc = "[f]ind [b]uffer" })
        vim.keymap.set("", "<leader>fh", builtin.help_tags, { desc = "[f]ind [h]elp" })
      end,
    },
  },
}
