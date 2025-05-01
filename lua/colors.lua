-- simirian's NeoVim
-- color schemes helpers

local M = {}
local H = {}

--- A color scheme that can be used by the colors module.
--- @class ColorScheme
--- The cholor scheme's hues. This table should include roygcbvm for red,
--- orange, yellow, green, cyan, blue, violet, and magenta in lowercase for
--- dark variants and uppercase for light variants.
--- @field c { [string]: string }
--- The color scheme's bases, which should be an array from most background to
--- most foreground oriented colors.
--- @field b string[]
--- The color schemes' accents which should be the names of hues, as in one of
--- the letters roygcbvm.
--- @field a string[]

--- The currently active palette for H.hl()
--- @type { [string]: string }
H.palette = {}

--- @type { [string]: vim.api.keyset.highlight|string }
H.highlights = {
  -- :h highlight-groups
  Unknown = { fg = "cG", bg = "cM" },

  Error = { fg = "cR" },
  Warning = { fg = "cO" },
  Info = { fg = "cB" },
  Hint = { fg = "cC" },
  Ok = { fg = "cG" },

  QuickFixLine = { fg = "cg", bg = "b2" },
  Directory = { fg = "A1" },

  Cursor = { fg = "b6", bg = "b1" },
  lCursor = "Cursor",
  CursorIM = "Cursor",
  TermCursor = { fg = "b1", bg = "b6" },
  TermCursorNC = "TermCursor",

  CursorLine = { bg = "b2" },
  CursorColumn = "CursorLine",
  ColorColumn = "CursorLine",

  DiffAdd = { fg = "b1", bg = "cg" },
  DiffChange = { fg = "b1", bg = "cc" },
  DiffDelete = { fg = "b1", bg = "cr" },
  DiffText = { fg = "b6" },

  Search = { fg = "b1", bg = "A1" },
  CurSearch = "Search",
  IncSearch = "Search",
  Substitute = "Search",

  LineNr = { fg = "b4" },
  LineNrAbove = "LineNr",
  LineNrBelow = "LineNr",
  CursorLineNr = { fg = "A1" },
  FoldColumn = "LineNr",
  CursorLineFold = "CursorLineNr",
  SignColumn = "LineNr",
  CursorLineSign = "CursorLineNr",

  Normal = { fg = "b5", bg = "b1" },
  NormalNC = "Normal",
  NonText = { fg = "b4" },
  Conceal = { fg = "b6" },
  Whitespace = "NonText",
  SpecialKey = "NonText",
  EndOfBuffer = { fg = "b3" },
  Folded = "NonText",
  MatchParen = { fg = "b6" },

  WinSeparator = { fg = "b3", bg = "b3" },
  NormalFloat = { bg = "b2" },
  FloatTitle = "NormalFloat",
  FloatBorder = { fg = "b4", bg = "b2" },

  MsgArea = "Normal",
  ErrorMsg = "Error",
  WarningMsg = "Warning",
  ModeMsg = { fg = "cY" },
  MsgSeparator = "WinSeparator",
  MoreMsg = { fg = "cb" },
  Question = "MoreMsg",
  Title = "MoreMsg",

  StatusLine = { fg = "A1", bg = "b3", reverse = false },
  StatusLineNC = { fg = "b5", bg = "b3", reverse = false },
  WinBar = "StatusLine",
  WinBarNC = "StatusLineNC",
  TabLine = { fg = "b5", bg = "b2" },
  TabLineSel = { fg = "b1", bg = "A1" },
  TabLineFill = "StatusLine",
  User1 = { fg = "b1", bg = "A1" },
  User2 = { fg = "A1", bg = "b2" },
  User3 = { fg = "A2", bg = "b2" },
  User4 = { fg = "A3", bg = "b2" },
  User5 = { fg = "A4", bg = "b2" },

  Pmenu = { fg = "b5", bg = "b2" },
  PmenuSel = { fg = "A1", bg = "b3" },
  PmenuKind = "Pmenu",
  PmenuKindSel = "PmenuSel",
  PmenuExtra = "Pmenu",
  PmenuExtraSel = "PmenuSel",
  PmenuSbar = { bg = "b3" },
  PmenuThumb = { bg = "A1" },
  WildMenu = "PmenuSel",

  SpellBad = { sp = "cR", undercurl = true },
  SpellCap = { sp = "cY", underdashed = true },
  SpellLocal = { sp = "cG", underdashed = true },
  SpellRare = { sp = "cC", underdashed = true },

  Visual = { bg = "b3" },
  VisualNOS = "Visual",

  -- syntax :h group-name
  Comment = { fg = "b4" },

  Constant = { fg = "a1" },
  Variable = { fg = "A1" },
  String = { fg = "a4" },
  Character = { fg = "A4" },
  SpecialChar = "Character",
  Boolean = { fg = "a2" },
  Number = { fg = "a3" },
  Float = { fg = "a3" },

  Identifier = { fg = "b5" },
  Function = { fg = "A3" },

  Statement = { fg = "A2" },
  Operator = { fg = "a2" },
  Conditional = "Statement",
  Repeat = "Statement",
  Label = "Statement",
  Keyword = "Statement",
  Exception = "Statement",

  PreProc = { fg = "Q3" },
  Include = "PreProc",
  Define = "PreProc",
  Macro = "PreProc",
  PreCondit = "PreProc",

  Type = { fg = "A3" },
  StorageClass = "Type",
  Structure = "Type",
  Typedef = "Type",

  Delimiter = { fg = "b5" },
  Special = "Delimiter",
  Tag = { fg = "A4" },
  SpecialComment = { fg = "a1" },
  Debug = { fg = "cC" },
  Underlined = { underline = true },
  Ignore = { italic = true, fg = "b4" },
  Todo = { fg = "A1" },

  -- :h diagnostic-highlights
  DiagnosticError = "Error",
  DiagnosticWarn = "Warning",
  DiagnosticInfo = "Info",
  DiagnosticHint = "Hint",
  DiagnosticOk = "Ok",
  DiagnosticUnderlineError = { sp = "cR", undercurl = true },
  DiagnosticUnderlineWarn = { sp = "cO", undercurl = true },
  DiagnosticUnderlineInfo = { sp = "cB", undercurl = true },
  DiagnosticUnderlineHint = { sp = "cC", undercurl = true },
  DiagnosticUnderlineOk = { sp = "cG", undercurl = true },
  DiagnosticDeprecated = { fg = "b4" },

  -- :h treesitter-highlight-groups TODO
  ["@variable"] = "Variable",
  ["@label"] = { fg = "a4" },
  ["@punctuation"] = { fg = "b5" },

  ["@comment"] = "Comment",
  ["@comment.documentation"] = "Comment",
  ["@comment.error"] = "Error",
  ["@comment.warning"] = "Warning",
  ["@comment.todo"] = "Todo",
  ["@comment.note"] = "Info",

  ["@markup.heading"] = { fg = "A1" },
  ["@markup.link"] = { fg = "A4" },
  ["@markup.raw"] = { fg = "b4" },

  -- :h lsp-semantic-tokens
  ["@lsp.type.variable"] = "Variable",
}

--- Sets the palette based on the color scheme palette/template.
--- @param colors ColorScheme The palette to use as the base.
function H.set_palette(colors)
  for name, color in pairs(colors.c) do
    H.palette["c" .. name] = color
  end
  for i, color in ipairs(colors.b) do
    H.palette["b" .. i] = color
  end
  for i, color in ipairs(colors.a) do
    H.palette["a" .. i] = colors.c[color]
    H.palette["A" .. i] = colors.c[color:upper()]
  end
end

--- Sets a highlight group
function H.hl(group, highlight)
  local opts = vim.deepcopy(highlight)
  if type(highlight) == "string" then
    opts = { link = highlight }
  else
    opts.fg = H.palette[opts.fg]
    opts.bg = H.palette[opts.bg]
    opts.sp = H.palette[opts.sp]
  end
  vim.api.nvim_set_hl(0, group, opts)
end

--- Sets nvim colors based on a color scheme palette.
--- @param colors ColorScheme The scheme template to use
function M.set(colors)
  vim.cmd.highlight("clear")
  H.set_palette(colors)
  for group, highlight in pairs(H.highlights) do
    H.hl(group, highlight)
  end
  vim.g.terminal_ansi_colors = {
    [0] = H.palette.b0,
    H.palette.cr,
    H.palette.cg,
    H.palette.cy,
    H.palette.cb,
    H.palette.cm,
    H.palette.cc,
    H.palette.b4,
    H.palette.b3,
    H.palette.cR,
    H.palette.cG,
    H.palette.cY,
    H.palette.cB,
    H.palette.cM,
    H.palette.cC,
    H.palette.b6,
  }
  for i = 1, 16 do
    vim.g["terminal_color_" .. i - 1] = vim.g.terminal_ansi_colors[i - 1]
  end
end

return M
