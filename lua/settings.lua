-- simirian's NeoVim
-- basic settings used in many other places

local M = {}

-- nerdfont icons
-- second value is an ASCII alternative
local icons = {
  -- code types
  -- data structures and members
  interface    = { "", ":" },
  array        = { "󰅪", ":" },
  struct       = { "", ":" },
  class        = { "󱪵", ":" },
  field        = { "", ";" },
  property     = { "", ";" },
  enum         = { "󱃣", ":" },
  enum_case    = { "󰎢", ";" },
  -- numbers
  number       = { "", "#" },
  unit         = { "", "#" },
  -- values and literals
  value        = { "󰺢", "l" },
  boolean      = { "", "l" },
  string       = { "󰬴", "l" },
  object       = { "󰔇", "l" },
  color        = { "", "l" },
  -- callables
  func         = { "󰡱", "f" },
  method       = { "󰘧", "f" },
  constructor  = { "", "f" },
  -- variables
  constant     = { "󰭷", "v" },
  variable     = { "󰄪", "v" },
  reference    = { "", "v" },
  -- namespaces
  namespace    = { "󰅩", "m" },
  module       = { "", "m" },
  package      = { "", "m" },
  -- text
  text         = { "󰈙", "A" },
  keyword      = { "", "A" },
  -- misc
  event        = { "", "e" },
  null         = { "󱥸", "_" },
  operator     = { "󱓉", "%" },
  snippet      = { "󰩫", "&" },

  -- status
  diagnostics  = { "󱖫", "d" },
  ok           = { "", "=" },
  error        = { "", "X" },
  warning      = { "", "!" },
  information  = { "", "i" },
  question     = { "", "?" },
  hint         = { "󰌵", "*" },

  -- debug
  debug        = { "", "#" },
  trace        = { "", "|" },
  start        = { "", ">" },
  pause        = { "", "-" },
  stop         = { "", "|" },
  pending      = { "", "-" },

  -- files
  folder_close = { "", "/" },
  folder_open  = { "", "/" },
  folder_empty = { "", "/" },
  folder_link  = { "", ">" },
  file         = { "", "." },
  file_link    = { "", ">" },

  -- git
  add          = { "", "+" },
  modify       = { "", "~" },
  remove       = { "", "-" },
  rename       = { "", "r" },
  ignore       = { "", "o" },

  commit       = { "", "c" },
  branch       = { "", "b" },

  -- ui
  up           = { "", "^" },
  down         = { "", "v" },
  left         = { "", "<" },
  right        = { "", ">" },
  dot          = { "", "*" },
  circle       = { "", "o" },
  check        = { "󰄬", "+" },
  cross        = { "󰅖", "x" },
  lock         = { "", "D" },
  key          = { "", "~" },
  vim          = { "", "V" },
  nvim         = { "", "N" },
  lazy         = { "󰒲", "z" },
  telescope    = { "", ">" },
  command      = { "", ">" },
  config       = { "", "*" },
  tag          = { "󰓹", ":" },
  code         = { "", "#" },
  bubbles      = { "󰗣", "Q" },
  aperture     = { "󰄄", ";" },
  cake         = { "󰃩", "!" },
  default      = { "", "$" },
}

function M.cmp_item(name)
  local items = {
    Array         = M.icons.array,
    Boolean       = M.icons.boolean,
    Class         = M.icons.class,
    Color         = M.icons.color,
    Constant      = M.icons.constant,
    Constructor   = M.icons.Constructor,
    Enum          = M.icons.enum,
    EnumMember    = M.icons.enum_case,
    Event         = M.icons.event,
    Field         = M.icons.field,
    File          = M.icons.file,
    Folder        = M.icons.folder_close,
    Function      = M.icons.func,
    Interface     = M.icons.interface,
    Key           = M.icons.key,
    Keyword       = M.icons.keyword,
    Method        = M.icons.method,
    Module        = M.icons.module,
    Namespace     = M.icons.namespace,
    Null          = M.icons.null,
    Number        = M.icons.number,
    Object        = M.icons.object,
    Operator      = M.icons.operator,
    Package       = M.icons.package,
    Property      = M.icons.property,
    Reference     = M.icons.reference,
    Snippet       = M.icons.snippet,
    String        = M.icons.string,
    Struct        = M.icons.struct,
    Text          = M.icons.text,
    TypeParameter = M.icons.tag,
    Unit          = M.icons.unit,
    Value         = M.icons.value,
    Variable      = M.icons.variable,
  }
  return items[name]
end

--- Setup the settings module
function M.setup()
  -- check if we are in a vc (rather than a terminal emulator)
  local has_vc = false
  if not vim.fn.has("linux") then
    has_vc = (vim.fn.getenv("DISPLAY") or vim.fn.getenv("WAYLAND_DISPLAY"))
  end

  -- load ascii alts if we are in a vc
  local itbl = {}
  for k, v in pairs(icons) do
    itbl[k] = v[has_vc and 2 or 1]
  end

  setmetatable(M, {
    __index = { icons = itbl },
  })
end

return M
