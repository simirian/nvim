-- simirian's Neovim
-- yicks color scheme inspired by
-- - github.com/sainnhe/gruvbox-material
-- - github.com/savq/melange-nvim,
-- - github.com/nanotech/jellybeans.vim
-- - github.com/xero/miasma.nvim

local red = "#bf4840" -- keywords, types, preprocessor
local orange = "#c17a44" -- literals
local yellow = "#b4a03c" -- variables, constants
local lime = "#819e3d" -- namespaces
local green = "#5b8f38" -- strings, links
local cyan = "#357e92"
local blue = "#4366a3"
local purple = "#7944a7"

local back = "#242220" -- normal background
local backlight = "#33312e" -- pum background, buffer markers
local select = "#3e3b38" -- visual and quickfix selection
local border = "#484440" -- float background
local textbg = "#5d534b" -- borders, line number, end of buffer
local textdark = "#807870" -- dark text
local text = "#a09890" -- normal text
local textlight = "#d0c8c0" -- standout text

vim.cmd("hi clear")
vim.o.background = "dark"

--- Sets a highlight group. Thin wrapper for `vim.api.nvim_set_hl()` that can
--- take a single string argument to create a link.
--- @param group string The highlight group to set.
--- @param highlight string|vim.api.keyset.highlight The highlight options.
local function hi(group, highlight)
  local opts = vim.deepcopy(highlight --[[@as table]])
  if type(opts) == "string" then
    opts = { link = opts }
  end
  vim.api.nvim_set_hl(0, group, opts)
end

-- :h highlight-groups highlights

-- normal and virtual text
hi("Normal", { fg = text, bg = back })
hi("NormalNC", "Normal")

hi("NonText", { fg = textbg })
hi("Folded", { fg = textdark })
hi("SpecialKey", { fg = textdark })
hi("Whitespace", "NonText")

hi("MatchParen", { fg = textlight })
hi("Conceal", { fg = textlight })

hi("EndOfBuffer", { fg = textbg })

-- selection
hi("Visual", { bg = select })
hi("VisualNOS", "Visual")
hi("QuickFixLine", "Visual")

-- search
hi("Search", { fg = back, bg = yellow })
hi("CurSearch", "Search")
hi("IncSearch", "Search")
hi("Substitute", "Search")

-- spelling
hi("SpellBad", { sp = red, undercurl = true })
hi("SpellCap", { sp = yellow, undercurl = true })
hi("SpellLocal", { sp = lime, underdashed = true })
hi("SpellRare", { sp = lime, underdashed = true })

-- cursor
hi("Cursor", { fg = back, bg = textlight })
hi("lCursor", "Cursor")
hi("CursorIM", "Cursor")
hi("TermCursor", "Cursor")

-- buffer markers
hi("CursorLine", { bg = backlight })
hi("CursorColumn", "CursorLine")
hi("ColorColumn", "CursorLine")

-- status column
hi("LineNr", { fg = textbg })
hi("LineNrAbove", "LineNr")
hi("LineNrBelow", "LineNr")
hi("FoldColumn", "LineNr")
hi("SignColumn", { fg = textdark })

hi("CursorLineNr", { fg = yellow })
hi("CursorLineFold", "CursorLineNr")
hi("CursorLineSign", "CursorLineNr")

-- borders
hi("WinSeparator", { fg = border, bg = border })
hi("MsgSeparator", "WinSeparator")

hi("StatusLine", { fg = yellow, bg = border })
hi("StatusLineNC", { fg = text, bg = border })
hi("StatusLineTermNC", "StatusLineNC")

hi("TabLine", { fg = text, bg = backlight })
hi("TabLineFill", { fg = text, bg = border })
hi("TabLineSel", { fg = back, bg = yellow })

hi("WinBar", "StatusLine")
hi("WinBarNC", "StatusLineNC")

hi("User1", { fg = back, bg = yellow })
hi("User2", { fg = yellow, bg = backlight })

-- floats
hi("NormalFloat", { fg = text, bg = backlight })
hi("FloatBorder", { fg = textdark, bg = backlight })
hi("FloatTitle", "NormalFloat")
hi("FloatFooter", "FloatTitle")

-- popup menu
hi("Pmenu", { fg = text, bg = backlight })
hi("PmenuKind", "Pmenu")
hi("PmenuExtra", "Pmenu")
hi("PmenuMatch", { fg = textdark })

hi("PmenuSel", { fg = yellow, bg = border })
hi("PmenuKindSel", "PmenuSel")
hi("PmenuExtraSel", "PmenuSel")
hi("PmenuMatchSel", { fg = orange })

hi("PmenuSbar", { bg = border })
hi("PmenuThumb", { bg = yellow })
hi("WildMenu", "Pmenu")

-- messages
hi("MoreMsg", { fg = blue })
hi("Question", "MoreMsg")
hi("Title", "MoreMsg")

hi("MsgArea", "Normal")
hi("ModeMsg", { fg = yellow })
hi("ErrorMsg", "Error")
hi("WarningMsg", "Warning")

-- misc
hi("Directory", { fg = yellow })
hi("SnippetTabstop", { bg = backlight })
hi("ComplMatchIns", { fg = text, bg = green }) -- no idea what this is

-- syntax highlights (:h group-name, :h treesitter-highlight-groups)
-- Worth noting that :h lsp-highlight exists, but those groups are automatically
-- linked to the treesitter groups, so manually defining them isn't needed.

-- variables
hi("Identifier", { fg = yellow })
hi("@variable", "Identifier")
hi("@variable.builtin", "@variable")
hi("@variable.parameter", "@variable")
hi("@variable.parameter.builtin", "@variable.builtin")
hi("@variable.member", "@property")

-- constants
hi("Constant", { fg = yellow })
hi("@constant", "Constant")
hi("@constant.builtin", "@constant")
hi("@constant.macro", "@constant")

-- includes
hi("Include", { fg = lime })
hi("@module", "Include")
hi("@module.builtin", "@module")
-- goto labels
hi("Label", "Statement")
hi("@label", "Label")

-- strings
hi("String", { fg = green })
hi("@string", "String")
hi("@string.documentation", "@string")
hi("@string.regexp", { fg = cyan })
hi("@string.escape", "@string.regexp")
hi("@string.special", "@string.regexp")
hi("@string.special.symbol", "@string.regexp")
hi("@string.special.path", "@string.regexp")
hi("@string.special.url", "@string.regexp")

-- characters
hi("Character", { fg = cyan })
hi("@character", "Character")
hi("@character.special", "@character")

-- boolean literal
hi("Boolean", { fg = orange })
hi("@boolean", "Boolean")
-- numbers
hi("Number", { fg = orange })
hi("@number", "Number")
hi("Float", "Number")
hi("@number.float", "Float")

-- types
hi("Type", { fg = red })
hi("StorageClass", "Type")
hi("Structure", "Type")
hi("Typedef", "Type")
hi("@type", "Type")
hi("@type.builtin", "@type")
hi("@type.definition", "@type")

hi("@attribute", { fg = blue })
hi("@attribute.builtin", "@attribute")
hi("@property", { fg = text })

-- functions
hi("Function", { fg = orange })
hi("@function", "Function")
hi("@function.builtin", "@function")
hi("@function.call", "@function")
hi("@function.macro", "@function")
hi("@function.method", "@function")
hi("@function.method.call", "@function")

-- most symbols
hi("Operator", {fg = text})
hi("@constructor", "@operator")
hi("@operator", "Operator")

-- keywords
hi("Statement", { fg = red })
hi("Keyword", "Statement")
hi("@keyword", "Keyword")
hi("@keyword.coroutine", "@keyword")
hi("@keyword.function", "@keyword")
hi("@keyword.operator", "@keyword")
hi("@keyword.import", "@keyword")
hi("@keyword.type", "@keyword")
hi("@keyword.modifier", "@keyword")
hi("Repeat", "Statement")
hi("@keyword.repeat", "Repeat")
hi("@keyword.return", "@keyword")
hi("Debug", { fg = cyan })
hi("@keyword.debug", "Debug")
hi("Exception", "Statement")
hi("@keyword.exception", "Exception")

-- conditionals
hi("Conditional", "Statement")
hi("@keyword.conditional", "Conditional")
hi("@keyword.conditional.ternary", { fg = text }) -- makes {} white

-- preprocessor
hi("PreProc", { fg = red })
hi("Macro", "PreProc")
hi("PreCondit", "PreProc")
hi("@keyword.directive", "PreProc")
hi("Define", "PreProc")
hi("@keyword.directivedefine", "Define")

-- punctuation
hi("Special", { fg = text })
hi("SpecialChar", "Special")
hi("Delimiter", "Special")
hi("@punctuation.delimiter", "Delimiter")
hi("@punctuation.bracket", "@punctuation.delimiter")
hi("@punctuation.special", "@punctuation.delimiter")

-- comments
hi("Comment", { fg = textdark })
hi("@comment", "Comment")
hi("SpecialComment", "Comment")
hi("@comment.documentation", "SpecialComment")

hi("@comment.error", { fg = red })
hi("@comment.warning", { fg = orange })
hi("@comment.todo", { fg = back, bg = yellow })
hi("@comment.note", { fg = back, bg = cyan })

-- markup
hi("@markup.heading", { fg = yellow })

hi("@markup.quote", { fg = text })
hi("@markup.math", { fg = blue })

hi("@markup.link", { fg = green })
hi("@markup.link.label", "@markup.link")
hi("@markup.link.url", { fg = green, sp = green, underline = true })

hi("@markup.raw", { fg = textdark })
hi("@markup.raw.block", "@markup.raw")

hi("@markup.list", { fg = text })
hi("@markup.list.checked", "@markup.list")
hi("@markup.list.unchecked", "@markup.list")

-- diffs
hi("DiffAdd", { fg = back, bg = green })
hi("DiffChange", { fg = back, bg = blue })
hi("DiffDelete", { fg = back, bg = red })
hi("DiffText", { fg = back, bg = orange })
hi("Added", "DiffAdd")
hi("Changed", "DiffChange")
hi("Removed", "DiffDelete")
hi("@diff.plus", "DiffAdd")
hi("@diff.minus", "DiffDelete")
hi("@diff.delta", "DiffChange")

-- tags
hi("Tag", { fg = green })
hi("@tag", { fg = green })
hi("@tag.builtin", { fg = cyan })
hi("@tag.attribute", { fg = text })
hi("@tag.delimiter", { fg = text })

-- no idea what these do
hi("Underlined", { underline = true })
hi("Ignore", { italic = true, fg = textdark })
hi("Error", { fg = red })
hi("Todo", { fg = back, bg = yellow })

-- diagnostics (:h diagnostic-highlights)
hi("Error", { fg = red })
hi("Warning", { fg = orange })
hi("Info", { fg = blue })
hi("Hint", { fg = cyan })
hi("Ok", { fg = green })
hi("DiagnosticError", "Error")
hi("DiagnosticWarn", "Warning")
hi("DiagnosticInfo", "Info")
hi("DiagnosticHint", "Hint")
hi("DiagnosticOk", "Ok")
hi("DiagnosticUnderlineError", { sp = red, undercurl = true })
hi("DiagnosticUnderlineWarn", { sp = orange, undercurl = true })
hi("DiagnosticUnderlineInfo", { sp = blue, undercurl = true })
hi("DiagnosticUnderlineHint", { sp = cyan, undercurl = true })
hi("DiagnosticUnderlineOk", { sp = green, undercurl = true })
hi("DiagnosticDeprecated", { fg = textdark })

-- lsp kinds for kind icons
hi("MethodKind", { fg = orange })
hi("UnitKind", { fg = blue })
hi("ModuleKind", { fg = lime })
hi("EventKind", { fg = cyan })
hi("FolderKind", { fg = yellow })
hi("TextKind", { fg = green })
hi("FileKind", { fg = text })
hi("ColorKind", { fg = blue })
hi("OperatorKind", { fg = text })
hi("EnumMemberKind", { fg = green })
hi("TypeParameterKind", { fg = red })
hi("EnumKind", { fg = red })
hi("InterfaceKind", { fg = red })
hi("ConstantKind", { fg = yellow })
hi("ConstructorKind", { fg = orange })
hi("FunctionKind", { fg = orange })
hi("ClassKind", { fg = red })
hi("KeywordKind", { fg = red })
hi("ValueKind", { fg = orange })
hi("VariableKind", { fg = yellow })
hi("PropertyKind", { fg = text })
hi("FieldKind", { fg = text })
hi("StructKind", { fg = red })
hi("ReferenceKind", { fg = blue })
hi("SnippetKind", { fg = blue })

-- calendir groups
hi("CalDay", { fg = text, bg = backlight })
hi("CalToday", { fg = back, bg = yellow })
hi("CalNoToday", { fg = back, bg = text })
hi("CalOther", { fg = textdark, bg = backlight })
hi("CalNoOther", { fg = textdark})

-- pick groups
hi("PickInput", { fg = text, bg = select })
hi("PickList", { fg = text, bg = backlight })

-- icon highlights
hi("IconRed", { fg = red })
hi("IconOrange", { fg = orange })
hi("IconYellow", { fg = yellow })
hi("IconLime", { fg = lime })
hi("IconGreen", { fg = green })
hi("IconCyan", { fg = cyan })
hi("IconBlue", { fg = blue })
hi("IconPurple", { fg = purple })
hi("IconWhite", { fg = textlight })
hi("IconGray", { fg = textdark })
