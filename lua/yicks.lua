--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                  ~ yicks ~                                 --
--                      lovely colors in different hues                       --
--------------------------------------------------------------------------------

local vfn = vim.fn

local M = {}
local H = {}

-- colors {{{1

-- accent colors {{{2
--- colors for the yicks color scheme
M.colors = {
  light_red     = "#bb473e",
  light_orange  = "#bb793e",
  light_yellow  = "#b0953e",
  light_green   = "#869130",
  light_cyan    = "#339988",
  light_blue    = "#3e94bb",
  light_violet  = "#9740bf",
  light_magenta = "#bb3ea2",

  red           = "#a12f2b",
  orange        = "#985b2a",
  yellow        = "#8d7725",
  green         = "#728121",
  cyan          = "#218172",
  blue          = "#286d8f",
  violet        = "#782c9b",
  magenta       = "#9e2989",
}

--- yicks.scheme{} {{{2
--- A yicks color scheme
--- @class yicks.scheme
--- 8 bases for the color scheme to use.
--- @field bases string[]
--- 4 accent colors for the scheme to use.
--- @field accents string[]

--- M.yicks_blue{} {{{2
--- @type yicks.scheme
M.yicks_blue = {
  bases = {
    "#201e24",
    "#28262c",
    "#383540",
    "#59576b",
    "#657181",
    "#79849a",
    "#8ea0af",
    "#9aadb7",
  },
  accents = { "blue", "magenta", "cyan", "violet" },
}

--- M.yicks_yellow{} {{{2
--- @type yicks.scheme
M.yicks_yellow = {
  bases = {
    "#272220",
    "#2e2927",
    "#433c37",
    "#6b5d57",
    "#816f65",
    "#9d887b",
    "#afa18e",
    "#bfb199",
  },
  accents = { "yellow", "red", "orange", "green" },
}

--- M.yicks_green{} {{{2
--- @type yicks.scheme
M.yicks_green = {} -- TODO: yicks_green

-- helper items  {{{1

--- H.p{} {{{2
--- Stores the currently active palette. Values are of the form cv where c is
--- the category and v is the value.
--- eg. b3 = #666666 for setting base 3
--- Categories are:
--- - b: bases
--- - a: accents
--- - A: alternate accents
--- - c: colors
--- - C: alternate colors
--- c/C adn a/A differ in lgiht/dark ness
--- @type { [string]: string }
H.p = {}

--- H.makep() {{{2
--- Populates the palette 'p' with values.
--- @param scheme yicks.scheme The color scheme to load.
function H.makep(scheme)
  local cscheme = vim.deepcopy(scheme)
  local light = vim.o.background == "light"
  if light then cscheme.bases = vfn.reverse(cscheme.bases) end
  for i, v in ipairs(cscheme.bases) do
    H.p["b" .. i] = v
  end
  for i, v in ipairs(cscheme.accents) do
    H.p["a" .. i] = M.colors[(light and "" or "light_") .. v]
    H.p["A" .. i] = M.colors[(light and "light_" or "") .. v]
  end
  for _, v in ipairs {
    "red", "orange", "yellow", "green", "cyan", "blue", "violet", "magenta"
  } do
    H.p["c" .. v:sub(1, 1)] = M.colors[(light and "" or "light_") .. v]
    H.p["C" .. v:sub(1, 1)] = M.colors[(light and "light_" or "") .. v]
  end
end

--- H.to_cterm() {{{2
--- Converts a color in `p` to a cterm color.
--- @param color string
--- @return integer
function H.to_cterm(color)
  local type = color:sub(1, 1):lower()
  local value = color:sub(2, 2)
  local light = vim.o.background == "light"
  if type == "b" then
    return ({ 0, 0, 8, 8, 7, 7, 15, 15 })[tonumber(value)]
  elseif type == "c" then
    return ({
      r = 4,
      o = 4,
      y = 6,
      g = 2,
      c = 3,
      b = 1,
      v = 5,
      m = 5,
    })[type] + (
    -- in light mode A is light
      ((light and color:sub(1, 1) == "A")
        -- in dark mode a is light
        or (not light and color:sub(1, 1) == "a"))
      -- if light, we add an offset of 8
      and 8 or 0
    )
  elseif type == "a" then
    -- accent
  end
  return 0
end

--- H.hl() {{{2
--- Highlights a group.
--- @param group string The group to highlight.
--- @param args vim.api.keyset.highlight|string The highlight options.
function H.hl(group, args)
  local cargs = vim.deepcopy(args)
  if type(cargs) == "string" then
    cargs = { link = cargs }
  elseif next(cargs) == nil then
    cargs = { default = true }
  else
    cargs.fg = H.p[cargs.fg]
    cargs.bg = H.p[cargs.bg]
    cargs.sp = H.p[cargs.sp]
  end
  vim.api.nvim_set_hl(0, group, cargs)
end

-- highlight groups {{{2
H.highlights = {
  -- metahighlights {{{3
  Unknown = { fg = "cg", bg = "cm" },
  Error = { fg = "cr" },
  Warning = { fg = "co" },
  Info = { fg = "cb" },
  Hint = { fg = "cc" },
  Ok = { fg = "cg" },

  QuickFixLine = { fg = "cg", bg = "b2" },
  -- WildMenu
  Directory = { fg = "a1" },

  -- cursor groups {{{3
  Cursor = { reverse = true, fg = "b1" },
  lCursor = "Cursor",
  CursorIM = "Cursor",
  CursorLine = { bg = "b2" },
  CursorColumn = "CursorLine",
  ColorColumn = "CursorLine",
  -- reverse by default, be we want that to be explicit
  TermCursor = { fg = "b8", reverse = true },
  TermCursorNC = { fg = "b5", reverse = true },

  -- diff groups {{{3
  DiffAdd = { fg = "b1", bg = "cg" },
  DiffChange = { fg = "b1", bg = "cc" },
  DiffDelete = { fg = "b1", bg = "cr" },
  DiffText = { fg = "b1", bg = "b8" },

  -- /search colors {{{3
  Search = { fg = "b1", bg = "a3" },
  -- format default is reverse, so remove that
  CurSearch = { fg = "b1", bg = "a3" },
  IncSearch = "CurSearch",
  Substitute = "CurSearch",

  -- left column {{{3
  LineNr = { fg = "b4" },
  LineNrAbove = "LineNr",
  LineNrBelow = "LineNr",
  CursorLineNr = { fg = "A1" },

  FoldColumn = "Normal",
  CursorLineFold = "CursorLineSign",

  SignColumn = "Normal",
  CursorLineSign = "CursorLineNr",

  -- text {{{3
  Normal = { fg = "b7", bg = "b1" },
  NormalNC = "Normal",
  Conceal = { fg = "b5", bg = "" },
  NonText = { fg = "b4" },
  Whitespace = "NonText",
  SpecialKey = "NonText",
  EndOfBuffer = "NonText",
  Folded = { fg = "b8", bg = "b3" },
  MatchParen = { fg = "b8", bg = "" },

  -- messages {{{3
  MsgArea = "Normal",
  ErrorMsg = { fg = "b1", bg = "cr" },
  WarningMsg = { fg = "b1", bg = "co" },
  ModeMsg = { fg = "cy" },
  MsgSeparator = { fg = "b7", bg = "b3" },
  MoreMsg = { fg = "cb" },
  Question = "MoreMsg",

  -- floats and windows {{{3
  Title = { fg = "a1" },
  WinSeparator = { fg = "b3", bg = "b3" },
  NormalFloat = { fg = "b7", bg = "b2" },
  FloatTitle = "WinSeparator",
  FloatBorder = "WinSeparator",

  -- lines {{{3
  -- fmt = "reverse" by default, so set to none to remove that
  StatusLine = { fg = "a1", bg = "b3", reverse = false },
  StatusLineNC = { fg = "b7", bg = "b3", reverse = false },
  WinBar = "StatusLine",
  WinBarNC = "StatusLineNC",
  TabLine = "StatusLineNC",
  TabLineFill = "TabLine",
  TabLineSel = { fg = "a1", bg = "b1" },
  User1 = { fg = "b1", bg = "a1" },
  User2 = { fg = "a1", bg = "b2" },

  -- popup menus {{{3
  Pmenu = { fg = "b7", bg = "b2" },
  PmenuSel = { fg = "a1", bg = "b3" },
  PmenuKind = "Pmenu",
  PmenuKindSel = "PmenuKind",
  PmenuExtra = "Pmenu",
  PmenuExtraSel = "PmenuSel",
  PmenuSbar = { bg = "b3" },
  PmenuThumb = { bg = "A1" },

  -- spellcheck {{{3
  SpellBad = { sp = "cr", undercurl = true },
  SpellCap = { sp = "cy", underdashed = true },
  SpellLocal = { sp = "cg", underdashed = true },
  SpellRare = { sp = "cc", underdashed = true },

  -- selections {{{3
  Visual = { bg = "b3" },
  VisualNOS = "Visual",

  -- code groups {{{3
  Comment = { fg = "b5" },

  Constant = { fg = "A1" },
  Variable = { fg = "a1" },
  String = { fg = "A4" },
  Character = { fg = "a4" },
  Boolean = { fg = "A2" },
  Number = { fg = "A3" },
  Float = { fg = "A3" },

  Identifier = { fg = "b6" },
  Function = { fg = "a3" },

  Statement = { fg = "a2" },
  Operator = { fg = "A2" },
  Conditional = "Statement",
  Repeat = "Statement",
  Repeat = "Statement",
  Label = "Statement",
  Keyword = "Statement",
  Exception = "Statement",

  PreProc = { fg = "a3" },
  PreProc = "PreProc",
  Include = "PreProc",
  Define = "PreProc",
  Macro = "PreProc",
  PreCondit = "PreProc",

  Type = { fg = "a3" },
  StorageClass = "Type",
  Structure = "Type",
  Typedef = "Type",

  -- special {{{3
  Special = { fg = "b6" },
  SpecialChar = "Character",
  Tag = { fg = "a4" },
  Delimiter = { fg = "b5" },
  SpecialComment = { fg = "b6" },
  Debug = { fg = "cc" },
  Underlined = { underline = true },
  Ignore = { italic = true, fg = "b6" },
  Todo = { fg = "cp", bg = "" },

  -- telescope {{{3
  TelescopeNormal = { fg = "b7", bg = "b2" },
  TelescopeBorder = { fg = "b2", bg = "b2" },
  TelescopeTitle = "TelescopeBorder",

  TelescopePromptNormal = { fg = "b7", bg = "b3" },
  TelescopePromptBorder = { fg = "b3", bg = "b3" },
  TelescopePromptTitle = "TelescopePromptBorder",

  TelescopeMatching = "CurSearch",
  TelescopeSelection = { fg = "", bg = "b3" },
  TelescopeSelectionCaret = { fg = "b3", bg = "b3" },

  -- diagnostics {{{3
  DiagnosticError = "Error",
  DiagnosticWarn = "Warning",
  DiagnosticInfo = "Info",
  DiagnosticHint = "Hint",
  DiagnosticOk = "Ok",

  DiagnosticUnderlineError = "DiagnosticError",
  DiagnosticUnderlineWarn = "DiagnosticWarning",
  DiagnosticUnderlineInfo = "DiagnosticInfo",
  DiagnosticUnderlineHint = "DiagnosticHint",
  DiagnosticUnderlineOk = "DiagnosticOk",

  -- nvim-tree {{{3
  NvimTreeSignColumn = "NormalFloat",

  -- treesitter {{{3
  ["@variable"] = "Variable",
  ["@lsp.type.variable"] = "Variable",
  ["@label"] = { fg = "a4" },
  ["@markup.link"] = { fg = "a4" },
}

--- yicks.set() {{{3
--- Sets the color scheme.
--- @param opts string|yicks.scheme The scheme to set, default yicks_yellow.
function M.set(opts)
  opts = opts or "yicks_yellow"
  if type(opts) == "string" then
    H.makep(M[opts])
  else
    H.makep(opts)
  end
  for group, hl in pairs(H.highlights) do
    H.hl(group, hl)
  end
end

-- footer {{{1
return M
-- vim:fdm=marker
