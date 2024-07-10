-- simirian's NeoVim
-- basic vim options

local o = vim.opt
local g = vim.g
local vfn = vim.fn
local autocmd = vim.api.nvim_create_autocmd

-- CONTENTS
-- appearance: windows, lines, columns
-- display: folding, wrap
-- editing: tabs, spelling, completion, indentation
-- movement: search, scrolling
-- files: backup
-- sessions
-- application: language, mouse
-- features: quickfix, shell

-- appearance ------------------------------------------------------------------
o.background = "dark"

-- textwidth colorcolumn
autocmd("BufWinEnter", {
  callback = function()
    local tw = vim.bo.textwidth
    if tw == 0 then
      vim.wo.colorcolumn = "81"
    else
      vim.wo.colorcolumn = "+1"
    end
  end
})

o.cursorcolumn = false
o.cursorline = true
o.cursorlineopt = "both"

o.cmdheight = 1
o.redrawtime = 500

o.splitbelow = true
o.splitright = true
o.splitkeep = "cursor"

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
  "o-r:hor20",
  "i-c-ci:ver25",
}
o.guifont = "JetBrainsMono NFM:h9"
-- o.guifontwide =
-- o.guioptions = -- unknown option??
-- o.guitablabel =
-- o.guitabtooltop =
-- o.linespace =

o.pumblend = 0
o.pumheight = 0
o.pumwidth = 15
o.menuitems = 25

-- TODO: move these?
o.report = 2
o.more = true
o.shortmess = "lmrOstTCFS"
o.showcmd = true -- visual selection size
o.showcmdloc = "last"
o.showmode = false
o.confirm = true

-- appearance :: windows -------------------------------------------------------
o.equalalways = false
o.eadirection = "both"
o.winheight = 20
o.helpheight = 20
o.cmdwinheight = 12
o.previewheight = 12
o.winwidth = 20
o.winminheight = 0
o.winminwidth = 0
o.winblend = 0

-- appearance :: lines ---------------------------------------------------------
-- o.laststatus =
-- o.statusline =
-- o.winbar =
-- o.showtabline =
-- o.tabline =
o.ruler = false
o.rulerformat = ""

-- appearance :: column
-- o.statuscolumn =
o.number = true
o.relativenumber = false
o.numberwidth = 1
o.signcolumn = "yes:1"
o.foldcolumn = "0"

-- display ---------------------------------------------------------------------
o.display = { "lastline", "uhex" }
o.list = true
o.listchars = {
  eol = "|",
  tab = "| ",
  leadmultispace = "|" .. string.rep("    ", 20),
  extends = "+",
  precedes = "+",
}
-- o.isprint =

o.concealcursor = ""
o.conceallevel = 0

o.ambiwidth = "single"
o.emoji = true
o.termbidi = false
o.arabicshape = true

-- display :: folding ----------------------------------------------------------
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldmarker = "{{{,}}}"
o.foldenable = false
o.foldminlines = 4
o.foldnestmax = 8
o.foldclose = ""
-- o.foldlevel =
-- o.foldlevelstart =
-- o.foldignore =
-- o.foldtext =
o.foldopen = {
  "block",
  "insert",
  "mark",
  "quickfix",
  "search",
  "tag",
  "undo",
}

-- display :: wrap -------------------------------------------------------------
o.wrap = false
o.wrapmargin = 0
o.linebreak = true
o.breakat = "\"'/- "
o.breakindent = true
o.breakindentopt = { min = 20 }
o.showbreak = "^ "

autocmd("FileType", {
  pattern = { "text", "markdown" },
  callback = function()
    vim.wo.wrap = true
    if vim.bo.textwidth == 0 then
      vim.bo.textwidth = 80
    end
  end
})

-- editing ---------------------------------------------------------------------
o.casemap = { "internal", "keepascii" }
-- o.comments =
-- o.commentstring =
o.delcombine = false
-- o.digraph =
o.joinspaces = false
o.nrformats = { "octal", "hex", "bin" }
o.quoteescape = "\\"
-- o.textwidth =
o.gdefault = false
o.inccommand = "nosplit"
o.tildeop = true
-- o.operatorfunc =

o.showmatch = false
o.matchtime = 2

o.allowrevins = false
o.revins = false

o.selection = "inclusive"
o.selectmode = ""
o.virtualedit = { "block" }

o.undolevels = 1000
o.undoreload = 10000
-- o.undodir =

-- editing :: tabs -------------------------------------------------------------
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 0
-- o.vartabstop =
-- o.varsofttabstop =
o.expandtab = true
o.shiftround = true
o.smarttab = true

-- editing :: spelling ---------------------------------------------------------
o.spell = false
o.spelllang = "en"
-- o.spellfile =
o.spelloptions = { "camel" }
-- o.spellsuggest =
-- o.spellcapcheck =

-- editing :: completion -------------------------------------------------------
-- o.omnifunc =
-- o.complete =
-- o.completefunc =
-- o.completeopt =
-- o.completeslash =
o.showfulltag = false
-- o.dictionary =
-- o.thesaurus =
-- o.thesaurusfunc =
o.infercase = true

-- editing :: indentation ------------------------------------------------------
o.autoindent = true
o.smartindent = false
o.copyindent = false
o.preserveindent = false
-- o.indentexpr =
-- o.indentkeys =

o.cindent = false
-- o.cinkeys =
-- o.cinoptions =
-- o.cinscopedecls =
-- o.cinwords =

-- o.lisp =
-- o.lispoptions =
-- o.lispwords =

-- movement --------------------------------------------------------------------
o.jumpoptions = ""
-- o.paragraphs =
-- o.sections =
o.startofline = true

o.matchpairs = { "(:)", "{:}", "[:]", "<:>" }
o.whichwrap = "b,<,>,[,]"
o.backspace = { "indent", "eol", "start" }

-- o.define =
-- o.include =
-- o.includeexpr =
-- o.iskeyword =
-- o.isident =

-- movement :: search ----------------------------------------------------------
o.incsearch = true
o.ignorecase = true
o.regexpengine = 0
o.smartcase = true
o.hlsearch = false
o.wrapscan = true

-- movement :: scrolling -------------------------------------------------------
-- o.window =
-- o.scroll =
o.scrolloff = 0
o.sidescroll = 1
o.sidescrolloff = 1
o.scrolljump = 1
-- o.scrollopt =
o.scrollback = 10000
o.smoothscroll = true

-- files -----------------------------------------------------------------------
-- o.fileencodings =
-- o.fileformats =
o.fixendofline = true
o.cdhome = true
-- o.cdpath =
-- o.charconvert =
-- o.browsedir = "current"
o.isfname:remove { "[", "]" }
o.fileignorecase = false
o.suffixesadd = { ".lua", ".md" }

o.modeline = true
o.modelineexpr = false
o.modelines = 1

o.fsync = true
o.autochdir = false
o.autoread = true
o.autowrite = false
o.autowriteall = false
o.write = true
o.writeany = false

-- flies :: backup -------------------------------------------------------------
o.writebackup = true
o.backup = false
o.backupext = "~"
-- o.backupcopy =
-- o.backupdir = 
-- o.backupskip =

-- sessions --------------------------------------------------------------------
-- o.sessionoptions =
-- o.shada =
-- o.shadafile =
o.updatecount = 200
o.updatetime = 4000
-- o.viewdir =
o.viewoptions = { "curdir", "folds" }
-- o.directory = -- for swapfiles

-- application -----------------------------------------------------------------
o.clipboard = {}
-- o.opendevice = unknown option??
o.pyxversion = 3
-- o.termpastefilter =
o.encoding = "utf-8"
o.winaltkeys = "no"

o.termguicolors = true
o.termsync = true
o.ttimeout = true
o.ttimeoutlen = 50

o.loadplugins = true
-- o.packpath =
-- o.runtimepath =
o.exrc = false

o.belloff = "all"
o.errorbells = false
o.visualbell = false

o.title = true
o.titlelen = 30
-- o.titleold =
-- o.titlestring =
o.icon = false
-- o.iconstring =

-- application :: language -----------------------------------------------------
-- o.keymap =
o.keymodel = ""
-- o.langmap =
-- o.langmenu =
o.langremap = false
-- o.imdisable = unknown option?
-- o.imcmdline = unknown option?
o.iminsert = 0
o.imsearch = -1

-- application :: mouse --------------------------------------------------------
o.mouse = "a"
o.mousefocus = false
o.mousehide = true
o.mousemodel = "popup"
o.mousemoveevent = false
o.mousescroll = { "ver:4", "hor:6" }
-- o.mouseshape =
o.mousetime = 200

-- features --------------------------------------------------------------------
-- o.cpoptions =
-- o.eventignore =
-- o.helpfile =
o.helplang = "en"
-- o.path =
o.hidden = true
o.history = 10000
-- o.keywordprg =
o.magic = true
o.maxfuncdepth = 100
o.maxmempattern = 1000
-- o.mkspellmem =
-- o.quickfixtextfunc =
o.redrawdebug = ""
o.switchbuf = "useopen"
o.synmaxcol = 3000
o.syntax = ""
o.tabpagemax = 10
o.writedelay = 0

o.debug = ""
o.verbose = 0
o.warn = true
-- o.verbosefile =

o.timeout = true
o.timeoutlen = 1000
o.maxmapdepth = 100

-- o.equalprg =
-- o.formatexpr =
-- o.formatlistpat =
-- o.formatoptions =
-- o.formatprg =

-- o.tagbsearch =
o.tagcase = "followscs"
-- o.tagfunc =
o.taglength = 0
-- o.tagrelative =
-- o.tags =
-- o.tagstack = 

-- o.wildchar =
-- o.wildcharm =
o.wildmenu = true
o.wildmode = "full"
o.wildoptions = { "pum", "tagfile" }
o.cedit = "<C-f>"

o.wildignore = ""
o.wildignorecase = false
-- o.suffixes =

-- o.diffexpr =
o.diffopt = {
  "filler",
  "context:4",
  "vertical",
  "closeoff",
  "hiddenoff",
  "foldcolumn:0",
  "internal",
}
-- o.patchexpr =
o.patchmode = ".old"

-- features :: quickfix --------------------------------------------------------
-- o.makeprg =
-- o.errorformat =
-- o.grepprg =
-- o.grepformat =
-- o.makeef =
-- o.makeencoding =
-- o.errorfile =

-- features :: shell -----------------------------------------------------------
if vfn.has("win32") == 1 then
  o.shell        = vfn.executable("pwsh") == 1 and "pwsh" or "powershell"
  o.shellcmdflag =
  "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
  o.shellpipe    = "2>&1 | %%{ \"$_\" } | Tee-Object %s; exit $LastExitCode"
  o.shellredir   = "2>&1 | %%{ \"$_\" } | Out-File %s; exit $LastExitCode"

  o.shellquote   = ""
  o.shellslash   = false
  o.shelltemp    = true
  o.shellxescape = ""
  o.shellxquote  = ""
end

-- disable unwanted providers
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

-- terminal --------------------------------------------------------------------
autocmd({ "BufEnter", "TermOpen" }, {
  pattern = "term://*",
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.cmd.startinsert()
  end
})
autocmd("TermLeave", { command = "stopinsert" })
