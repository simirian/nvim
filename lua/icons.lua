-- simirian's Neovim
-- icons library

local M = {}

--[[
vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.api.nvim_get_runtime_file("ftplugin/*.{vim,lua}", true))
]]

local icons = { }

icons.name = {
  README = { "", "IconWhite" },
  LICENSE = { "", "IconWhite" },
  PKGBUILD = { "󰏓", "IconWhite" },
}

icons.filetype = {
  bash = { "$", "IconLime" },
  c = { "", "IconCyan" },
  checkhealth = { "", "IconRed" },
  cmake = { "󱌣", "IconBlue" },
  cmakecache = { "", "IconLime" },
  conf = { "", "IconGray" },
  config = { "", "IconGray" },
  cpp = { "", "IconCyan" },
  css = { "", "IconCyan" },
  csv = { "󰓫", "IconGreen" },
  desktop = { "", "IconCyan" },
  diff = { "", "IconPurple" },
  editorconfig = { "󱌣", "IconGray", },
  git = { "󰊢", "IconOrange" },
  gitattributes = { "󰊢", "IconOrange" },
  gitcommit = { "󰊢", "IconOrange" },
  gitconfig = { "󰊢", "IconOrange" },
  gitignore = { "󰊢", "IconOrange" },
  gitrebase = { "󰊢", "IconOrange" },
  gitsendemail = { "󰊢", "IconOrange" },
  html = { "", "IconRed" },
  hyprlang = { "", "IconCyan" },
  javascript = { "", "IconYellow" },
  json = { "", "IconYellow" },
  lua = { "", "IconCyan" },
  make = { "", "IconRed" },
  man = {"", "IconWhite"},
  markdown = { "", "IconWhite" },
  pdf = { "", "IconRed" },
  python = { "", "IconCyan" },
  query = { "", "IconPurple" },
  rust = { "󱘗", "IconOrange" },
  sass = { "", "IconPurple" },
  scss = { "", "IconPurple" },
  svg = { "", "IconPurple" },
  text = { "󰈙", "IconWhite" },
  tmux = { "", "IconLime" },
  toml = { "", "IconOrange" },
  typescript = { "", "IconBlue" },
  vim = { "", "IconGreen" },
  xml = { "", "IconWhite" },
  yaml = { "", "IconYellow"}
}

icons.extension = {
  h = { "", "IconCyan" },
  hpp = { "", "IconCyan" },
  -- image
  bmp = { "", "IconPurple" },
  jpg = { "", "IconPurple" },
  png = { "", "IconPurple" },
  webp = { "", "IconPurple" },
  -- video
  mkv = { "", "IconBlue" },
  mov = { "", "IconBlue" },
  mp4 = { "", "IconBlue" },
  webm = { "", "IconBlue" },
  -- audio
  mp3 = { "󰓃", "IconGreen" },
  ogg = { "󰓃", "IconGreen" },
  wav = { "󰓃", "IconGreen" },
  -- archive
  gz = { "", "IconGray" },
  tar = { "", "IconGray" },
  xz = { "", "IconGray" },
  zip = { "", "IconGray" },
}


--- Gets an icon based on the given name and category.
--- @param name string|number The name of the file to get the icon for.
--- @param category "name"|"extension"|"filetype"|"buffer"? The category to select the icon from.
--- @return string icon
--- @return string highlight
function M.get(name, category)
  local ico = { "?", "IconGray" }
  if type(name) == "number" or category == "buffer" then
    --- @cast name integer
    local filetype = vim.bo[name].ft or vim.filetype.match { buf = name }
    if icons.filetype[filetype] then
      ico = icons.filetype[filetype]
    else
      local bufname = vim.fs.basename(vim.api.nvim_buf_get_name(name))
      if icons.name[bufname] then
        ico = icons.name[bufname]
      else
        local extension = vim.fs.ext(bufname)
        ico = icons.extension[extension] or ico
      end
    end
  elseif category == "name" then
    ico = icons.name[name] or ico
  elseif category == "filetype" then
    ico = icons.filetype[name] or ico
  elseif category == "extension" then
    if icons.extension[name] then
      ico = icons.extension[name] or ico
    else
      local ft = vim.filetype.match { filename = "file." .. name } or 0
      ico = icons.filetype[ft] or ico
    end
  else
    if icons.name[name] then
      ico = icons.name[name] or ico
    else
      local ext = vim.fn.fnamemodify(name, ":e")
      if icons.extension[ext] then
        ico = icons.extension[ext] or ico
      else
        local ft = vim.filetype.match { filename = name } or 0
        ico = icons.filetype[ft] or ico
      end
    end
  end
  return ico[1], ico[2]
end

return M
