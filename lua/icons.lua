--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                  ~ icons ~                                 --
--------------------------------------------------------------------------------

local vfn = vim.fn

local M = {}

-- dedfinitions {{{1

--- iconspec {{{2
--- @class iconspec
--- @field [1] string Patched font icon.
--- @field [2] string Unicode icon.
--- @field [3] string Ascii icon.

--- icons {{{2
--- @type { [string]: iconspec }
local icons = {
  -- code types {{{3
  -- data structures and members {{{4
  interface    = { "", "⧂", ":" },
  array        = { "󰅪", "⦂", ":" },
  struct       = { "", "⊖", ":" },
  class        = { "", "⧀", ":" },
  field        = { "", "∈", ";" },
  property     = { "", "⋿", ";" },
  enum         = { "󱃣", "⋃", ":" },
  enum_case    = { "󰎢", "⨃", ";" },
  -- values and literals {{{4
  number       = { "", "#", "#" },
  unit         = { "", "$", "$" },
  value        = { "󰺢", "¤", "l" },
  boolean      = { "", "◑", "l" },
  string       = { "󰬴", "α", "l" },
  object       = { "󰔇", "❆", "l" },
  color        = { "", "⬡", "l" },
  -- callables {{{4
  func         = { "󰡱", "f", "f" },
  method       = { "󰘧", "λ", "f" },
  constructor  = { "", "μ", "f" },
  -- variables {{{4
  constant     = { "󰭷", "π", "v" },
  variable     = { "󰄪", "x", "v" },
  reference    = { "", "↦", "v" },
  -- namespaces {{{4
  namespace    = { "󰅩", "⸬", "m" },
  module       = { "", "⏍", "m" },
  package      = { "", "⏍", "m" },
  -- misc {{{4
  text         = { "󰈙", "❞", "A" },
  keyword      = { "", "»", "A" },
  event        = { "", "↯", "e" },
  null         = { "󱥸", "∅", "_" },
  operator     = { "󱓉", "±", "%" },
  snippet      = { "󰩫", "✀", "&" },

  -- status {{{3
  diagnostics  = { "󱖫", "✓", "d" },
  ok           = { "", "✓", "=" },
  error        = { "", "✕", "X" },
  warning      = { "", "!", "!" },
  info         = { "", "i", "i" },
  question     = { "", "?", "?" },
  hint         = { "󰌵", "*", "*" },

  -- debug {{{3
  debug        = { "", "⧞", "#" },
  trace        = { "", "⬚", "|" },
  start        = { "", "⯈", ">" },
  pause        = { "", "∥", "-" },
  stop         = { "", "■", "|" },
  pending      = { "", "⧗", "-" },

  -- files {{{3
  folder_close = { "", "/", "/" },
  folder_open  = { "", "/", "/" },
  folder_empty = { "", "/", "/" },
  folder_link  = { "", "➤", ">" },
  file         = { "", "•", "." },
  file_link    = { "", "↪", ">" },

  -- git {{{3
  add          = { "", "+", "+" },
  modify       = { "", "~", "~" },
  remove       = { "", "-", "-" },
  rename       = { "", "↪", "r" },
  ignore       = { "", "◌", "o" },
  commit       = { "", "⧃", "c" },
  branch       = { "", "⎇", "b" },

  -- ui {{{3
  up           = { "", "˄", "^" },
  down         = { "", "˅", "v" },
  left         = { "", "˂", "<" },
  right        = { "", "˃", ">" },
  dot          = { "", "●", "*" },
  circle       = { "", "○", "o" },
  check        = { "󰄬", "✓", "+" },
  cross        = { "󰅖", "✓", "x" },
  lock         = { "", "⩍", "D" },
  key          = { "", "⚿", "~" },
  vim          = { "", "V", "V" },
  nvim         = { "", "N", "N" },
  lazy         = { "󰒲", "◑ ", "z" },
  telescope    = { "", "⌕", ">" },
  command      = { "", "⌘", ">" },
  config       = { "", "⛭", "*" },
  tag          = { "󰓹", "»", ":" },
  code         = { "", "◇", "#" },
  bubbles      = { "󰗣", "⁖", "Q" },
  aperture     = { "󰄄", "🞉", ";" },
  default      = { "󰃩", "⪧", "!" },
}

-- module functions {{{1

--- M.cmp_item() {{{2
--- Gets a vim completion kind icon from its internal name.
--- @param name string The icon name.
--- @return string icon
function M.cmp_item(name)
  return ({
    Array         = M.array,
    Boolean       = M.boolean,
    Class         = M.class,
    Color         = M.color,
    Constant      = M.constant,
    Constructor   = M.Constructor,
    Enum          = M.enum,
    EnumMember    = M.enum_case,
    Event         = M.event,
    Field         = M.field,
    File          = M.file,
    Folder        = M.folder_close,
    Function      = M.func,
    Interface     = M.interface,
    Key           = M.key,
    Keyword       = M.keyword,
    Method        = M.method,
    Module        = M.module,
    Namespace     = M.namespace,
    Null          = M.null,
    Number        = M.number,
    Object        = M.object,
    Operator      = M.operator,
    Package       = M.package,
    Property      = M.property,
    Reference     = M.reference,
    Snippet       = M.snippet,
    String        = M.string,
    Struct        = M.struct,
    Text          = M.text,
    TypeParameter = M.tag,
    Unit          = M.unit,
    Value         = M.value,
    Variable      = M.variable,
  })[name]
end

--- M.setup() {{{2
--- Setup the settings module
--- @param mode "nerdfont"|"unicode"|"ascii"|"auto"
function M.setup(mode)
  mode = mode or "auto"
  if mode == "auto" then
    mode = "nerdfont"
    -- check if we are in a vc (rather than a terminal emulator)
    if vim.loop.os_uname().sysname == "Linux"
        and not (vfn.getenv("DISPLAY") or vfn.getenv("WAYLAND_DISPLAY"))
    then
      mode = "ascii"
    end
  end

  for k, v in pairs(icons) do
    M[k] = v[({
      nerdfont = 1,
      unicode = 2,
      ascii = 3,
    })[mode]]
  end
end

return M
-- vim:fdm=marker
