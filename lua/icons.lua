-- useful icons
-- by simirian

local M = {}

M.lsp_kind = {
  Text = "",
  Method = "󰘧",
  Function = "󰡱",
  Constructor = "",
  Field = "",
  Variable = "󰄪",
  Class = "",
  Interface = "",
  Module = "",
  Property = "",
  Unit = "",
  Value = "󰺢",
  Enum = "󱃣",
  Keyword = "",
  Snippet = "󰩫",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "󰎢",
  Constant = "󰭷",
  Struct = "",
  Event = "",
  Operator = "󱓉",
  TypeParameter = "󰓹",
}

M.files = {
  directory = "",
  file = "",
  link = "",
}

M.diagnostic = {
  status = "󱖫",
  ok = "",
  error = "",
  warning = "",
  info = "",
  question = "",
  hint = "󰌵",
}

M.debug = {
  icon = "",
  start = "",
  pause = "",
  stop = "",
  rerun = "",
  back = "",
  into = "",
  out = "",
  over = "",
}

M.git = {
  modified = "",
  added = "",
  deleted = "",
  renamed = "",
  ignored = "",
  untracked = "",
  staged = "",
  unstaged = "",
  branch = "",
}

M.shapes = {
  up = "",
  down = "",
  left = "",
  right = "",
  dot = "",
  circle = "",
  check = "󰄬",
  cross = "󰅖",
  gear = "",
  telescope = "",
  bubbles = "󰗣",
  aperture = "󰄄",
  default = "󰃩",
}

return M
