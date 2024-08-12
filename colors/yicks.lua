----------------------------
--   yicks color scheme   --
-- soft oranges and blues --
--      by simirian       --
----------------------------

--- Palette colors.
--- @enum color
local p = {
  none = "",
  -- light colors
  lr = "#bb473e",
  lo = "#bb793e",
  ly = "#b0953e",
  lg = "#869130",
  lc = "#339988",
  lb = "#3e94bb",
  lv = "#9740bf",
  lm = "#bb3ea2",
  r = "#a12f2b",
  o = "#985b2a",
  y = "#8d7725",
  g = "#728121",
  c = "#218172",
  b = "#286d8f",
  v = "#782c9b",
  m = "#9e2989",
}

-- configure palette base colors based on g: settings
if vim.g.yicks_blue == true then
  p = vim.tbl_deep_extend("error", p, {
    b0 = "#201e24",
    b1 = "#28262c",
    b2 = "#383540",
    b3 = "#59576b",
    b4 = "#657181",
    b5 = "#79849a",
    b6 = "#8ea0af",
    b7 = "#9aadb7",
    -- accents table
    a = {
      p = p.b,
      s = p.lm,
      t = p.c,
      q = p.v,
      lp = p.lb,
      ls = p.m,
      lt = p.lc,
      lq = p.lv,
    },
  })
else
  p = vim.tbl_deep_extend("error", p, {
    b0 = "#272220",
    b1 = "#2e2927",
    b2 = "#433c37",
    b3 = "#6b5d57",
    b4 = "#816f65",
    b5 = "#9d887b",
    b6 = "#afa18e",
    b7 = "#bfb199",
    -- accents table
    a = {
      p = p.y,
      s = p.r,
      t = p.o,
      q = p.g,
      lp = p.ly,
      ls = p.lr,
      lt = p.lo,
      lq = p.lg,
    },
  })
end

--- Translation table from palette colors to cterm colors.
local cterm = {
  -- light colors
  lr = 9,
  lo = 9,
  ly = 11,
  lg = 10,
  lc = 14,
  lb = 12,
  lv = 13,
  lm = 13,
  -- dark colors
  r = 1,
  o = 1,
  y = 3,
  g = 2,
  c = 6,
  b = 4,
  v = 5,
  m = 5,
  -- base colors
  b0 = 0,
  b1 = 0,
  b2 = 8,
  b3 = 8,
  b4 = 7,
  b5 = 7,
  b6 = 15,
  b7 = 15,
}

--- Highlight group format types.
--- @enum format
local f = {
  b = "bold",
  ul = "underline",
  uc = "undercurl",
  ud = "underdouble",
  uo = "underdotted",
  ua = "underdashed",
  st = "strikethrough",
  rv = "reverse",
  vs = "inverse",
  i = "italic",
  so = "standout",
  alt = "altfont",
  nc = "nocombine",
  none = "NONE",
}

--- Converts a hex color to a cterm color based on the palette.
--- @param color color the hex color
--- @return integer|string cterm_color
local function to_cterm(color)
  if color == "" then return "" end
  for k, v in pairs(p) do
    if color == v then return cterm[k] end
  end
  return 13
end

--- @alias hlargs { fg?: color, bg?: color, sp?: color, fmt?: format }

--- Takes an argument and sets highlihgt groups based on it.
--- @param group string The croup to modify.
--- @param args string|hlargs What to change it to.
local function hl(group, args)
  if type(args) == "string" then
    vim.cmd("hi! link " .. group .. " " .. args)
    return
  end
  local command = "hi " .. group

  if args.fmt then
    command = command .. " gui=" .. args.fmt .. " cterm=" .. args.fmt
  end
  if args.fg then
    command = command .. " guifg=" .. args.fg
        .. " ctermfg=" .. to_cterm(args.fg)
  end
  if args.bg then
    command = command .. " guibg=" .. args.bg
        .. " ctermbg=" .. to_cterm(args.bg)
  end
  if args.sp then
    command = command .. " guisp=" .. args.sp
  end

  vim.cmd(command)
end

vim.cmd.hi("clear")
vim.g.colors_name = "yicks"
vim.o.termguicolors = true
vim.o.background = "dark"

-- metahighlights
hl("Unknown", { fg = p.lg, bg = p.lm })
hl("Error", { fg = p.lr, bg = "" })
hl("Warning", { fg = p.lo })
hl("Info", { fg = p.b })
hl("Hint", { fg = p.c })
hl("Ok", { fg = p.g })

-- QuickFixLine
-- WildMenu
hl("Directory", { fg = p.a.lp })

-- cursor groups
hl("Cursor", { fmt = f.rv, fg = p.b0 })
hl("lCursor", "Cursor")
hl("CursorIM", "Cursor")
hl("CursorLine", { bg = p.b1 })
hl("CursorColumn", "CursorLine")
hl("ColorColumn", "CursorLine")
-- reverse by default, be we want that to be explicit
hl("TermCursor", { fmt = f.rv, fg = p.b7 })
hl("TermCursorNC", "TermCursor")

-- diff groups
hl("DiffAdd", { fg = p.b0, bg = p.lg })
hl("DiffChange", { fg = p.b0, bg = p.lc })
hl("DiffDelete", { fg = p.b0, bg = p.lr })
hl("DiffText", { fg = p.b0, bg = p.b7 })

-- /search colors
hl("Search", { fg = p.b0, bg = p.a.lt })
-- format default is reverse, so remove that
hl("CurSearch", { fmt = f.none, fg = p.b0, bg = p.a.lt })
hl("IncSearch", "CurSearch")
hl("Substitute", "CurSearch")

-- left column
hl("LineNr", { fg = p.b3 })
hl("LineNrAbove", "LineNr")
hl("LineNrBelow", "LineNr")
hl("CursorLineNr", { fg = p.a.p })

hl("FoldColumn", "Normal")
hl("CursorLineFold", "CursorLineSign")

hl("SignColumn", "Normal")
hl("CursorLineSign", "CursorLineNr")

-- text
hl("Normal", { fg = p.b6, bg = p.b0 })
hl("NormalNC", "Normal")
hl("Conceal", { fg = p.b4, bg = "" })
hl("NonText", { fg = p.b3 })
hl("Whitespace", "NonText")
hl("SpecialKey", "NonText")
hl("EndOfBuffer", "NonText")
hl("Folded", { fg = p.b7, bg = p.b2 })
hl("MatchParen", { fg = p.b7, bg = "" })

-- messages
hl("MsgArea", "Normal")
hl("ErrorMsg", { fg = p.b0, bg = p.lr })
hl("WarningMsg", { fg = p.b0, bg = p.lo })
hl("ModeMsg", { fg = p.ly })
hl("MsgSeparator", { fg = p.b6, bg = p.b2 })
hl("MoreMsg", { fg = p.b })
hl("Question", "MoreMsg")

-- floats and windows
hl("Title", { fg = p.a.lp })
hl("WinSeparator", { fg = p.b2, bg = p.b2 })
hl("NormalFloat", { fg = p.b6, bg = p.b1 })
hl("FloatTitle", "WinSeparator")
hl("FloatBorder", "WinSeparator")

-- lines
-- fmt = "reverse" by default, so set to none to remove that
hl("StatusLine", { fmt = f.none, fg = p.a.lp, bg = p.b2 })
hl("StatusLineNC", { fmt = f.none, fg = p.b6, bg = p.b2 })
hl("WinBar", "StatusLine")
hl("WinBarNC", "StatusLineNC")
hl("TabLine", "StatusLineNC")
hl("TabLineFill", "TabLine")
hl("TabLineSel", { fg = p.a.lp, bg = p.b0 })
hl("User1", { fg = p.b0, bg = p.a.lp })
hl("User2", { fg = p.a.lp, bg = p.b1 })

-- popup menus
hl("Pmenu", { fg = p.b6, bg = p.b1 })
hl("PmenuSel", { fg = p.a.lp, bg = p.b2 })
hl("PmenuKind", "Pmenu")
hl("PmenuKindSel", "PmenuKind")
hl("PmenuExtra", "Pmenu")
hl("PmenuExtraSel", "PmenuSel")
hl("PmenuSbar", { bg = p.b2 })
hl("PmenuThumb", { bg = p.a.p })

-- spellcheck
hl("SpellBad", { sp = p.lr, fmt = "undercurl" })
hl("SpellCap", { sp = p.ly, fmt = "underdashed" })
hl("SpellLocal", { sp = p.lg, fmt = "underdashed" })
hl("SpellRare", { sp = p.lc, fmt = "underdashed" })

-- selections
hl("Visual", { bg = p.b2 })
hl("VisualNOS", "Visual")

-- code groups
hl("Comment", { fg = p.b4 })

hl("Constant", { fg = p.a.p })
hl("Variable", { fg = p.a.lp })
hl("String", { fg = p.a.q })
hl("Character", { fg = p.a.lq })
hl("Boolean", { fg = p.a.s })
hl("Number", { fg = p.a.t })
hl("Float", { fg = p.a.t })

hl("Identifier", { fg = p.b5 })
hl("Function", { fg = p.a.lt })

hl("Statement", { fg = p.a.ls })
hl("Operator", { fg = p.a.s })
hl("Conditional", "Statement")
hl("Repeat", "Statement")
hl("Repeat", "Statement")
hl("Label", "Statement")
hl("Keyword", "Statement")
hl("Exception", "Statement")

hl("PreProc", { fg = p.a.lt })
hl("PreProc", "PreProc")
hl("Include", "PreProc")
hl("Define", "PreProc")
hl("Macro", "PreProc")
hl("PreCondit", "PreProc")

hl("Type", { fg = p.a.lt })
hl("StorageClass", "Type")
hl("Structure", "Type")
hl("Typedef", "Type")

-- Special
hl("Special", { fg = p.b5 })
hl("SpecialChar", "Character")
hl("Tag", { fg = p.a.lq })
hl("Delimiter", { fg = p.b4 })
hl("SpecialComment", { fg = p.b5 })
hl("Debug", { fg = p.lc })
hl("Underlined", { fmt = f.ul })
hl("Ignore", { fmt = f.i, fg = p.b5 })
--hl("Error", { fmt = f.uc, fg = p.lr, bg = "" })
hl("Todo", { fg = p.lp, bg = "" })

-- telescope
hl("TelescopeNormal", { fg = p.b6, bg = p.b1 })
hl("TelescopeBorder", { fg = p.b1, bg = p.b1 })
hl("TelescopeTitle", "TelescopeBorder")

hl("TelescopePromptNormal", { fg = p.b6, bg = p.b2 })
hl("TelescopePromptBorder", { fg = p.b2, bg = p.b2 })
hl("TelescopePromptTitle", "TelescopePromptBorder")

hl("TelescopeMatching", "CurSearch")
hl("TelescopeSelection", { fg = "", bg = p.b2 })
hl("TelescopeSelectionCaret", { fg = p.b2, bg = p.b2 })

-- diagnostics
hl("DiagnosticError", "Error")
hl("DiagnosticWarn", "Warning")
hl("DiagnosticInfo", "Info")
hl("DiagnosticHint", "Hint")
hl("DiagnosticOk", "Ok")

hl("DiagnosticUnderlineError", "DiagnosticError")
hl("DiagnosticUnderlineWarn", "DiagnosticWarning")
hl("DiagnosticUnderlineInfo", "DiagnosticInfo")
hl("DiagnosticUnderlineHint", "DiagnosticHint")
hl("DiagnosticUnderlineOk", "DiagnosticOk")

-- nvim-tree
hl("NvimTreeSignColumn", "NormalFloat")

-- treesitter
hl("@variable", "Variable")
hl("@lsp.type.variable", "Variable")
hl("@label", { fg = p.a.lq })
hl("@markup.link", { fg = p.a.lq })
