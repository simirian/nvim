-- simirian's NeoVim
-- basic vim options

local o = vim.opt
local g = vim.g
local vfn = vim.fn
local vfs = vim.fs
local autocmd = vim.api.nvim_create_autocmd

-- 1. important

-- o.compatible = false -- always nocompatible
-- TODO: cw/ce compatibility?
-- o.cpoptions = -- compatibility options, defaults are fine for me
-- o.paste = false -- obsolete
-- o.runtimepath -- don't want to mess with this :)
-- o.packpath -- I don't think this is used?
-- o.helpfile -- the default helpfile, maybe change this at some point?

-- 2. moving around, searching, and patterns

-- motions
o.whichwrap = "b,s,<,>" -- what movements wrap
o.startofline = true    -- go to start of line for c-d, gg, etc.
-- o.paragraphs =       -- works fine, don't mess with it
-- o.sections =         -- works fine, don't mess with it

-- :cd
-- o.path = -- path for `gf`, `:find`, etc.
o.cdhome = true     -- default on unix, make this universal
-- o.cdpath = -- nvim-manager does this for me
o.autochdir = false -- this seems awful

-- /
o.wrapscan = true                       -- search around EOF with n, N
o.incsearch = true                      -- highlight while typing search
o.magic = true                          -- breaks things if off, so leave on
o.regexpengine = 0                      -- automatic handling is good
o.ignorecase = true                     -- ignore case in search pattern
o.smartcase = true                      -- ignore case unless there are capitals
o.casemap = { "internal", "keepascii" } -- probably gu things?
o.maxmempattern = 1000                  -- max memory amount for searching

-- 3 tags
o.tagbsearch = true  -- faster tag search is most cases
o.taglength = 0      -- all characters are significant
-- o.tags =          -- how to search for tags
o.tagcase = "ignore" -- tagserach should ignore case
o.tagrelative = true -- relative tag paths
-- o.tagstack = -- not sure what the implications of this are
-- o.showfulltag = -- completion something, as above
-- o.tagfunc = -- function to use to search for tags

-- 4 displaying text
o.scroll = 20        -- scroll distange for c-d
o.scrolloff = 0      -- space from cursorline on top and bottom, just zz
o.wrap = false       -- set per-buffer
o.linebreak = true   -- break at 'breakat' chars
o.breakat = "\"'/- " -- characters to break on
o.breakindent = true -- preserve indentation at breaks
-- TODO: look into 'breakindentopt'
-- o.breakindentopt = -- idk how this works
o.showbreak = ". "  -- start of wrapped lines
o.sidescroll = 2    -- how much to scroll horizontally
o.sidescrolloff = 0 -- sidescroll padding
o.display = "uhex"  -- flags, this makes strange characters appear in unicode
-- o.fillchars = -- char for statusline / tabline fill (read :help)
-- o.cmdheight = 1 -- 0 would be nice but renders poorly with the statusline
-- o.columns = -- let this be automatic
-- o.lines = -- let this be automatic
-- o.window = -- scroll distance for C-f and C-b
-- o.lazyredraw = -- redraw only when explicitly called
o.redrawtime = 1000 -- search highlight timeout
o.writedelay = 0    -- delay for each written character
o.list = true       -- draw whitespace characters
o.listchars = {     -- characters to draw
  eol = "|",
  tab = "| ",
  leadmultispace = "|" .. string.rep("    ", 20),
  extends = "+",
  precedes = "+",
}
o.number = true          -- show line numbers
o.relativenumber = false -- relative line numbers
o.numberwidth = 1        -- width of numbercol
o.conceallevel = 0       -- conceal character level
o.concealcursor = ""     -- which modes to conceal in the cursorline

-- 5 syntax, highlighting, and spelling
--o.background = "dark" -- let color scheme set this
--o.filetype = "" -- autodetect this
o.syntax = "ON"          -- syntax highlight when treesitter does not override
o.synmaxcol = 3000       -- max col to look for syntax items
o.hlsearch = false       -- highlight search terms after search
o.termguicolors = true   -- use full colors in the terminal rather than ansi
o.cursorcolumn = false   -- highlight column with cursor
o.cursorline = true      -- highlight the line with the cursor
o.cursorlineopt = "line" -- how to highlight the cursorline
o.colorcolumn = "80"     -- vertical line to always highlight

o.spell = false          -- spellcheck
o.spelllang = "en"       -- spellcheck language
--o.spellfile = "" -- file to add ok words to
--o.spellcapcheck = "" -- idk what this does
--o.spelloptions = "noplainbuffer" -- idk what this does either
--o.spellsuggest = "best" -- functions to use for getting suggestions
--o.mkspellmem = "4600000,2000,500" -- memory to use for :mkspell before compressing

-- 6 multiple windows
--o.laststatus = 2 -- handled by contour
--o.statusline = "" -- handled by contour
o.statuscolumn = ""      -- format for left column
o.equalalways = false    -- make all windows even when adding new ones
o.eadirection = "both"   -- direction to apply above
o.winfixheight = false   -- keep window height despite 'equalalways'
o.winfixwidth = false    -- keep window width despite 'equalalways'
o.winheight = 20         -- min height for current window
o.winminheight = 0       -- min height for non current windows
o.winwidth = 20          -- min width for current window
o.winminwidth = 0        -- min width for non current windows
o.helpheight = 20        -- default help window height
o.previewheight = 12     -- default preview window height
--o.previewwindow = false -- true for preview windows
o.hidden = true          -- don't unload abandoned buffers
o.switchbuf = "useopen"  -- how to switch in the quickfix list
o.splitbelow = true      -- split downwards
o.splitright = true      -- vsplit to the right
o.splitkeep = "cursor"   -- how to manage scroll when splitting
o.scrollbind = false     -- scroll in tandem with other bound windows
o.scrollopt = "ver,jump" -- how to bind scrolls
o.scrollopt = {          -- how to bind scrolls
  "ver",                 -- match vertical positions
  "jump",                -- match based on first line
}
o.cursorbind = false     -- also bind cursor position

-- 7 multiple tab pages
--o.showtabline = 2 -- managed by contour
--o.tabline = "" -- managed by contour
o.tabpagemax = 20 -- max tab pages

-- 8 terminal
o.scrolljump = 1 -- minimal scroll distance
--o.guicursor = "" -- gui mode cursor
o.title = true   -- show terminal info in the window's title
o.titlelen = 80  -- percentage of columns to use as the terminal title
--o.titlestring = "" -- set terminal title to this
--o.titleold = "" -- reutrn teminal title to this after exiting
o.icon = false -- use icon
--o.iconstring = ""  -- idk how this works tbh

-- 9 using the mouse
o.mouse = "nvi"               -- modes with mouse enabled
o.mousemodel = "popup_setpos" -- what right click does
o.mousetime = 200             -- double click time

-- 10 messages and info
o.terse = false             -- use 'shortmess' with s instead
o.shortmess = "filmnrxoOFS" -- flags to shorten messages
o.showcmd = true            -- show visual selection
o.showcmdloc = "last"       -- where to show above
o.showmode = false          -- show mode in command line
o.ruler = false             -- show cursor position
o.rulerformat = ""          -- format of ruler, like 'statusline'
o.report = 2                -- report chenges of at least this many lines
o.verbose = 0               -- increase when debugging
o.verbosefile = ""          -- set to append messages to this file
o.more = true               -- page messages that are more than one screen
o.confirm = true            -- use confirm a dialogs
o.errorbells = false        -- bel on error
o.visualbell = false        -- use a visual bell instead of audio bell
o.belloff = "all"           -- don't use bells, they kinda suck
o.helplang = "en"           -- help language

-- 11 selecting text
o.selection = "inclusive" -- include last character in selection operations
o.selectmode = ""         -- when to use select mode (never)
o.clipboard = ""          -- what clipboard to use, default is fine
o.keymodel = ""           -- special motion keys should not mess with selections

-- 12 editing text
o.undolevels = 1000                                -- this is default and that is amazing
o.undofile = false                                 -- don't bother saving
o.undodir =
    vfs.normalize(vfn.stdpath("data") .. "/undo/") -- undofile path
o.undoreload = 10000                               -- lines to save for buffer reaload
--o.modified = false -- this is handled automatically
--o.readonly = false -- this is also handled automatically
--o.modifiable = true -- *also* handled automatically
o.textwidth = 0  -- default 0 to prevent autoformat wrapping
o.wrapmargin = 0 -- leave no margin when wrapping
o.backspace = {  -- delete through these items
  "indent",      -- delete through indents
  "eol",         -- delete through end of lines
  "start",       -- delete through startinsert, but not on <C-w>
}
-- TODO: manage this elsewhere? is this needed with treesitter?
o.comments = {              -- comment patterns
  "s1b:/*",                 -- c begin
  "mb:*",                   -- c middle
  "exb:*/",                 -- c end
  "b://",                   -- common comment type
  "b:///",                  -- rust doc comment
  "b:#",                    -- script comment, require space for macros
  "b:--",                   -- lua comments
  "b:---",                  -- lua doc annotations
}
o.formatoptions = "tcroqlj" -- this is default as of right now
o.formatlistpat = ""        -- for use with "n" in above
o.formatexpr = ""           -- used with gq to format lines

--o.complete = ".,w,b,u,t" -- I think this is default? I'll let cmp handle this
--o.completeopt = "menu,preview" -- same as above
--o.completefunc = "" -- generic completiono function
--o.omnifunc = "" -- file type completion
o.pumheight = 0                  -- max popup menu height
o.pumwidth = 20                  -- max popup menu width
o.dictionary = {}                -- dict files for completion
o.thesaurus = {}                 -- thesaurus files for completion
o.thesaurusfunc = ""             -- used for thesaurus completion
o.infercase = false              -- infer case in dictionary and thesaurus completions
o.digraph = false                -- insert digraphs with funky keystrokes
o.tildeop = true                 -- treat ~ like an operator (wait for motion)
o.operatorfunc = ""              -- called for g@
o.showmatch = false              -- briefly show bracket match
o.matchtime = 5                  -- tenths of a second to show above
o.matchpairs = "(:),{:},[:],<:>" -- matches for %
o.joinspaces = false             -- use extra spaces after '.' when joining lines
o.nrformats = {                  -- number formats for <C-a> and <C-x>
  "bin",                         -- 0b binary numbers
  "octal",                       -- 0 octal numbers
  "hex",                         -- 0x hexadecimal numbers
}

-- 13 tabs and indenting
o.tabstop = 2            -- rendered tab size
o.softtabstop = 2        -- spaces for pressing <Tab>
o.vartabstop = {}        -- sets tabsize for sequential tabs
o.varsofttabstop = {}    -- spaes for sequential softtabstops
o.shiftwidth = 0         -- spces used for >> uses tabstop
o.smarttab = false       -- use shiftwidth when tabbing at start of line
o.expandtab = true       -- use spaces where tabs don't matter
o.autoindent = true      -- automatically fix indentation
o.smartindent = false    -- this causes more problems than good
o.copyindent = false     -- imitate whitespace structure
o.preserveindent = false -- preserve whitespace structure

-- cindent TODO: figure out how this works
o.cindent = false -- don't use cindent by default
--o.cinoptions = "" -- options for above, see :help cinoptions-values
--o.cinkeys = "" -- keys to trigger cindent on
o.cinwords = { -- words to indent on
  "if",
  "else",
  "while",
  "do",
  "for",
  "case",           -- swapped switch for this
}
o.cinscopedecls = { -- thest are for c++ scopes and are not labels
  "public",
  "protected",
  "private",
}

o.indentexpr = "" -- evaluate this expression to get line indentation
o.indentkeys = "" -- keys to trigger above

--o.lisp = false -- this should be set automatically
--o.lispwords = {} -- defaults are fine I'm sure
--o.lispoptions = "" -- as above

-- 14 folding
o.foldenable = false     -- default folds to open
o.foldlevel = 99         -- keep folds open
o.foldlevelstart = 99    -- start with folds open
o.foldcolumn = "0"       -- width of foldcolumn
--o.foldtext = "" -- how to display a closed fold
o.foldclose = ""         -- should folds be autoclosed
o.foldopen = {           -- when to open folds
  "block",               -- block navigation
  "insert",              -- entering insert
  "mark",                -- jumping to marks
  "quickfix",            -- using the quickfix list
  "search",              -- / searching
  "tag",                 -- jumping to tags
  "undo",                -- undos
}
o.foldminlines = 2       -- minimum lines to make a fold
--o.commentstring = "" -- how to display folded comments
o.foldmethod = "indent"  -- how to get folds
o.foldexpr = ""          -- expression to get folds when above is expr
o.foldignore = "#"       -- lines starting with this inherit foldlevel
o.foldmarker = "{{{,}}}" -- markers for folding
o.foldnestmax = 4        -- max fold depth for indent and syntax

-- 15 diff mode
--o.diff = false -- is this a diff window
o.diffopt = {        -- how to run diffs
  "filler",          -- add spaces where things don't align
  "context:4",       -- 4 lines around diffs
  "vertical",        -- split vertically
  "closeoff",        -- leave diff mode when a window changes
  "foldcolumn:2",    -- foldcolumn width
  "internal",        -- use internal diff engine
  "algorithm:myers", -- diff algorithm
}
o.diffexpr = ""      -- expression to get a diff file
o.patchexpr = ""     -- expression to patch a file

-- 16 mapping
o.maxmapdepth = 1000 -- how are the defaults so high
o.timeout = true     -- should mappings timeout
o.timeoutlen = 3000  -- timeout length in ms
o.ttimeout = true    -- timeout partway through a keycode
o.ttimeoutlen = 50   -- timeout length in ms

-- 17 reading and writing files
o.modeline = true      -- read modeline
o.modelineexpr = false -- keep off for security
o.modelines = 5        -- lnies to check for modelines
--o.binary = false -- set per file
o.endofline = true     -- last line has an eol
o.endoffile = false    -- last line ends with 
o.fixendofline = true  -- adds eol at the end of a file that doesn't have it
o.bomb = false         -- prepend byte order mars
--o.fileformat = dos -- set per file
o.fileformats = {      -- line terminator formats
  "unix",              -- linux (not mac)
  "dos",               -- windows
}
--o.write = true -- set per file (!readonly)
o.writebackup = true   -- write a backup, then overwrite
o.backup = false       -- keep backup after overwrite
--o.backupskip = "" -- automatically finds system temp dir
o.backupcopy = "auto"  -- when to make backups
o.backupdir =          -- where to save backups
    vfs.normalize(vfn.stdpath("data") .. "/backup/")
o.backupext = "~"      -- backup file extension
o.autowrite = false    -- write when switching buffers
o.autowriteall = false -- above but for more commands
o.writeany = false     -- write without confirmation
o.autoread = true      -- read when modified externally
o.patchmode = ""       -- extension for old patched files
o.fsync = true         -- sync file after write

-- 18 the swap file
o.directory = -- where to save swapfiles
    vfs.normalize(vfn.stdpath("data") .. "/swap/")
--o.swapfile = false -- set per buffer
o.updatecount = 20 -- characters to update a swapfile
o.updatetime = 100 -- dead time (ms) needed for update

-- 19 command line editing
o.history = 200 -- default is 10000 which is pointless
--o.wildchar = "<Tab>" -- idk what this does tbh
--o.wildcharm = 0 -- or this
o.wildmode = "full" -- how to complete items
o.suffixes = {      -- low priority file extensions, cmp  ignores these
  ".bak",           -- I think these are defaults
  "~",
  ".o",
  ".h",
  ".info",
  ".swp",
  ".obj",
}
o.suffixesadd = {        -- suffixes added for gf
  ".lua",                -- for requires
  ".md",                 -- for obsidian
}
o.wildignore = {}        -- patterns to ignore in completion
o.fileignorecase = true  -- ignore case when searching files
o.wildignorecase = false -- don't ignore when using wildcards
o.wildmenu = false       -- don't use wildmenu, we have nvim-cmp
o.cedit = "<C-f>"        -- key to open command-line window
o.cmdwinheight = 10      -- height of command window

-- 20 executing external commands
-- nvim should use powershell on windows
if vfn.has("win32") == 1 then
  o.shell        = "powershell"
  o.shellquote   = ""
  o.shellxquote  = ""
  o.shellxescape = ""
  o.shellcmdflag =
  "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  o.shellredir   = "2>&1 | %%{ \"$_\" } | Out-File %s; exit $LastExitCode"
  o.shelltemp    = true
  o.shellpipe    = "2>&1 | %%{ \"$_\" } | Tee-Object %s; exit $LastExitCode"
end

o.equalprg = ""       -- command for = operator
o.formatprg = ""      -- command for gq oparator
o.keywordprg = ":Man" -- command for K

-- 21 running make and jumping to errors (quickfix)
o.errorfile = "errors.err" -- error message output file
--o.errorformat = "" -- format of the errorfile, ass to mess with
o.makeprg = "make"         -- program for :make
o.makeef = ""              -- errorfile made, empty is a temp file
--o.grepprg = "" -- automatically changes according to platform
--o.grepformat = "" -- don't mess with this either
o.makeencoding = "" -- encoding of :grep and :make output, unconverted

-- 22 system specific
o.shellslash = false -- true kills telescope for some reason
--o.completeslash = "/"

-- 23 language specific
--o.isfname = "" -- chars that are in file names for gf
--o.isident = "" -- chars in identifiers
--o.iskeyword = "" -- chars in keywords
--o.isprint = "" -- printable characters
o.quoteescape = "\\"  -- string escape character

o.rightleft = false   -- display buffer right to left
o.rightleftcmd = ""   -- when to search in rightleft mode
o.revins = false      -- insert backwards
o.allowrevins = false -- allow revins mapping
o.aleph = 0           -- code for aleph
o.hkmap = false       -- use hebrew keyboard
o.hkmapp = false      -- use phonetic hebrew keyboard
o.arabic = false      -- writing in arabic
o.arabicshape = false -- shape arabic characters
o.termbidi = false    -- terminal handles bini
o.keymap = ""         -- keyboard mapping name
o.langmap = ""        -- set when switching to a language keyboard mode
o.langremap = false   -- apply above to mapped characters
o.iminsert = 0        -- when to use a language mapping
o.imsearch = -1       -- use above, same but for searching

-- 24 multi-byte characters
o.encoding = "utf8"     -- nvim internal char encodings
o.fileencoding = "utf8" -- current file encoding
--o.fileencodings = {} -- defaults are fine
o.charconvert = ""      -- expression for converting formats
o.delcombine = false    -- auto delete composing characters
o.maxcombine = 6        -- max composing characters to merge
o.ambiwidth = "double"  -- wide characters take double the space
o.emoji = true          -- display emojis at full width

-- 25 various
o.virtualedit = {    -- allow cursor on nonexistant characters
  "block",           -- anywhere for block editing
}
o.eventignore = {}   -- autocmd events to ignore
o.loadplugins = true -- should plugins be loaded
o.exrc = false       -- read .vimrc from cwd
o.secure = false     -- scripts are trusted
o.gdefault = false   -- run :s with /g
o.maxfuncdepth = 100 -- max funtion call depth
o.sessionoptions = { -- TODO figure out sessions
  "blank",           -- blank windows
  "buffers",         -- buffer list
  "help",            -- help windows
  "tabpages",        -- tabpages, default is only the current page
  "terminal",        -- terminal windows
  "winsize",         -- window sizes
}
o.viewoptions = {    -- options for :mkview
  "localoptions",    -- buffer local options
}
o.viewdir =          -- view file path
    vfs.normalize(vfn.stdpath("data") .. "/view/")
o.shada = ""         -- TODO figure out shada stuff
o.shadafile = "NONE" -- no override is fine
o.bufhidden = "hide" -- this is the default I think
--o.buftype = "" -- set automatically
--o.buflisted = true -- set automaticallu
o.debug = ""         -- don't need script debug mode
o.signcolumn = "yes:1" -- when to display the signcolumn
o.pyxversion = 3     -- default python version

-- disable unwanted providers
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

-- autocommands
-- plaintext files should wrap
autocmd("FileType", {
  pattern = { "text", "markdown" },
  callback = function()
    vim.wo.wrap = true
    if vim.bo.textwidth == 0 then
      vim.bo.textwidth = 80
    end
  end
})

-- terminal specific settings
autocmd({ "BufEnter", "TermOpen" }, {
  pattern = "term://*",
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.cmd("startinsert")
  end
})
autocmd("BufLeave", {
  pattern = "term://*",
  command = "stopinsert",
})
