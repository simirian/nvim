--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                  ~ icons ~                                 --
--------------------------------------------------------------------------------

local vfn = vim.fn

local M = {}

--- @class iconspec
--- @field [1] string Patched font icon.
--- @field [2] string Unicode icon.
--- @field [3] string Ascii icon.

--- @type { [string]: iconspec }
local icons = {
  -- code types
  -- data structures and members
  interface    = { "", "⧂", ":" },
  array        = { "󰅪", "⦂", ":" },
  struct       = { "", "⊖", ":" },
  class        = { "", "⧀", ":" },
  field        = { "", "∈", ";" },
  property     = { "", "⋿", ";" },
  enum         = { "󱃣", "⋃", ":" },
  enum_case    = { "󰎢", "⨃", ";" },
  -- numbers
  number       = { "", "#", "#" },
  unit         = { "", "$", "$" },
  -- values and literals
  value        = { "󰺢", "¤", "l" },
  boolean      = { "", "◑", "l" },
  string       = { "󰬴", "α", "l" },
  object       = { "󰔇", "❆", "l" },
  color        = { "", "⬡", "l" },
  -- callables
  func         = { "󰡱", "f", "f" },
  method       = { "󰘧", "λ", "f" },
  constructor  = { "", "μ", "f" },
  -- variables
  constant     = { "󰭷", "π", "v" },
  variable     = { "󰄪", "x", "v" },
  reference    = { "", "↦", "v" },
  -- namespaces
  namespace    = { "󰅩", "⸬", "m" },
  module       = { "", "⏍", "m" },
  package      = { "", "⏍", "m" },
  -- text
  text         = { "󰈙", "❞", "A" },
  keyword      = { "", "»", "A" },
  -- misc
  event        = { "", "↯", "e" },
  null         = { "󱥸", "∅", "_" },
  operator     = { "󱓉", "±", "%" },
  snippet      = { "󰩫", "✀", "&" },

  -- status
  diagnostics  = { "󱖫", "✓", "d" },
  ok           = { "", "✓", "=" },
  error        = { "", "✕", "X" },
  warning      = { "", "!", "!" },
  info         = { "", "i", "i" },
  question     = { "", "?", "?" },
  hint         = { "󰌵", "*", "*" },

  -- debug
  debug        = { "", "⧞", "#" },
  trace        = { "", "⬚", "|" },
  start        = { "", "⯈", ">" },
  pause        = { "", "∥", "-" },
  stop         = { "", "■", "|" },
  pending      = { "", "⧗", "-" },

  -- files
  folder_close = { "", "/", "/" },
  folder_open  = { "", "/", "/" },
  folder_empty = { "", "/", "/" },
  folder_link  = { "", "➤", ">" },
  file         = { "", "•", "." },
  file_link    = { "", "↪", ">" },

  -- git
  add          = { "", "+", "+" },
  modify       = { "", "~", "~" },
  remove       = { "", "-", "-" },
  rename       = { "", "↪", "r" },
  ignore       = { "", "◌", "o" },
  commit       = { "", "⧃", "c" },
  branch       = { "", "⎇", "b" },

  -- ui
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
