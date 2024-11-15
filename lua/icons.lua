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
--- @enum (key) Icon
local icons = {
  -- lsp icons (formatted to match lsp kind names)
  Text = { "", "❞", "A" },
  Method = { "󰘧", "λ", "f" },
  Function = { "󰡱", "f", "f" },
  Constructor = { "", "μ", "f" },
  Field = { "", "∈", ";" },
  Variable = { "󰄪", "x", "v" },
  Class = { "", "⧀", ":" },
  Interface = { "", "⧂", ":" },
  Module = { "", "⏍", "m" },
  Property = { "", "⋿", ";" },
  Unit = { "", "$", "$" },
  Value = { "󰺢", "¤", "l" },
  Enum = { "󱃣", "⋃", ":" },
  Keyword = { "", "»", "A" },
  Snippet = { "󰩫", "✀", "&" },
  Color = { "", "⬡", "l" },
  File = { "", "🗏", "F" },
  Reference = { "", "↦", "v" },
  Folder = { "", "🗀", "/" },
  EnumMember = { "󰎢", "⨃", ";" },
  Constant = { "󰭷", "π", "v" },
  Struct = { "", "⊖", ":" },
  Event = { "", "↯", "e" },
  Operator = { "󱓉", "±", "%" },
  TypeParameter = { "󰓹", "»", ":" },

  -- diagnostic and status icons
  status = { "󱖫", "✓", "d" },
  ok = { "", "✓", "=" },
  error = { "", "✕", "X" },
  warning = { "", "!", "!" },
  info = { "", "i", "i" },
  question = { "", "?", "?" },
  hint = { "󰌵", "*", "*" },

  dbg_icon = { "", "⧞", "DBG" },
  dbg_start = { "", "⯈", "SRT" },
  dbg_pause = { "", "∥", "PAU" },
  dbg_stop = { "", "■", "STP" },
  dbg_rerun = { "", "r", "RER" },
  dbg_back = { "", "<", "BAK" },
  dbg_into = { "", "v", "IN" },
  dbg_out = { "", "^", "OUT" },
  dbg_over = { "", ">", "OVR" },

  folder_close = { "", "🗀", "/" },
  folder_open = { "", "🗀", "/" },
  folder_empty = { "", "🗀", "/" },
  folder_link = { "", "➤", ">" },
  file = { "", "🗏", "." },
  file_link = { "", "↪", ">" },

  git_modified = { "", "~", "~" },
  git_added = { "", "+", "+" },
  git_deleted = { "", "-", "-" },
  git_renamed = { "", "↪", "R" },
  git_ignored = { "", "◌", "!" },
  git_untracked = { "", "◌", "?" },
  git_staged = { "", "S", "S" },
  git_unstaged = { "", "*", "*" },
  git_branch = { "", "⎇", "ON:" },

  key_keyboard = { "󰌌", "⌨", "KBD" },
  key_backspace = { "󰁮", "⌫", "BAK" },
  key_tab = { "", "⇥", "TAB" },
  key_enter = { "󰌑", "↩", "RET" },
  key_escape = { "󱊷", "⎋", "ESC" },
  key_space = { "␣", "␣", "SPC" },
  key_delete = { "󰹾", "⌦", "DEL" },
  key_up = { "󰁝", "↑", "UP " },
  key_down = { "󰁅", "↓", "DWN" },
  key_left = { "󰁍", "←", "LFT" },
  key_right = { "󰁔", "→", "RGT" },
  key_shift = { "󰘶", "⇧", "SFT" },
  key_control = { "󰠳", "⎈", "CRL" },
  key_alt = { "󰘵", "⌥", "ALT" },
  key_leader = { "", "⚑", "LDR" },

  -- generic icons
  up = { "", "˄", "^" },
  down = { "", "˅", "v" },
  left = { "", "˂", "<" },
  right = { "", "˃", ">" },
  dot = { "", "●", "*" },
  circle = { "", "○", "o" },
  check = { "󰄬", "✓", "+" },
  cross = { "󰅖", "✓", "x" },
  pending = { "", "⧗", "-" },
  lock = { "", "⩍", "D" },
  key = { "", "⚿", "~" },
  vim = { "", "V", "V" },
  nvim = { "", "N", "N" },
  lazy = { "󰒲", "◑ ", "z" },
  telescope = { "", "⌕", ">" },
  command = { "", "⌘", ">" },
  config = { "", "⛭", "*" },
  tag = { "󰓹", "»", ":" },
  code = { "", "◇", "#" },
  bubbles = { "󰗣", "⁖", "Q" },
  aperture = { "󰄄", "🞉", ";" },
  default = { "󰃩", "⪧", "!" },
}

--- @type "nerdfont"|"unicode"|"ascii"
local use = "ascii"

--- Setup the settings module
--- @param mode? "nerdfont"|"unicode"|"ascii"|"auto"
function M.setup(mode)
  mode = mode or "auto"
  if mode == "auto" then
    use = "nerdfont"
    if vim.loop.os_uname().sysname == "Linux"
        and not (vfn.getenv("DISPLAY") or vfn.getenv("WAYLAND_DISPLAY")) then
      use = "ascii"
    end
  else
    use = mode --[[ @as "nerdfont"|"unicode"|"ascii" ]]
  end
end

--- @type table<Icon, string>
M = setmetatable(M, {
  __index = function(_, key)
    if not icons[key] then return nil end
    return icons[key][({
      nerdfont = 1,
      unicode = 2,
      ascii = 3,
    })[use]]
  end
})

return M
