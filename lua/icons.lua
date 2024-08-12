--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                  ~ icons ~                                 --
--------------------------------------------------------------------------------

local vfn = vim.fn

local M = {}

-- nerdfont icons
-- second value is an ASCII alternative
local icons = {
  -- code types

  -- data structures and members
  interface    = { "", ":" },
  array        = { "󰅪", ":" },
  struct       = { "", ":" },
  class        = { "", ":" },
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
  info         = { "", "i" },
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
  return ({
    Array         = M.list.array,
    Boolean       = M.list.boolean,
    Class         = M.list.class,
    Color         = M.list.color,
    Constant      = M.list.constant,
    Constructor   = M.list.Constructor,
    Enum          = M.list.enum,
    EnumMember    = M.list.enum_case,
    Event         = M.list.event,
    Field         = M.list.field,
    File          = M.list.file,
    Folder        = M.list.folder_close,
    Function      = M.list.func,
    Interface     = M.list.interface,
    Key           = M.list.key,
    Keyword       = M.list.keyword,
    Method        = M.list.method,
    Module        = M.list.module,
    Namespace     = M.list.namespace,
    Null          = M.list.null,
    Number        = M.list.number,
    Object        = M.list.object,
    Operator      = M.list.operator,
    Package       = M.list.package,
    Property      = M.list.property,
    Reference     = M.list.reference,
    Snippet       = M.list.snippet,
    String        = M.list.string,
    Struct        = M.list.struct,
    Text          = M.list.text,
    TypeParameter = M.list.tag,
    Unit          = M.list.unit,
    Value         = M.list.value,
    Variable      = M.list.variable,
  })[name]
end

--- Setup the settings module
function M.setup()
  -- check if we are in a vc (rather than a terminal emulator)
  local has_vc = false
  if not vfn.has("linux") then
    has_vc = (vfn.getenv("DISPLAY") or vfn.getenv("WAYLAND_DISPLAY"))
  end

  -- load ascii alts if we are in a vc
  local itbl = {}
  for k, v in pairs(icons) do
    itbl[k] = v[has_vc and 2 or 1]
  end

  setmetatable(M, {
    __index = { list = itbl },
  })
end

return M
