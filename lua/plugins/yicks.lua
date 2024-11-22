-- simirian's NeoVim
-- yicks color scheme setup

math.randomseed(vim.loop.uptime() * 1000)

-- use environment variable or a random theme
local osc = vim.loop.os_getenv("YICKS_THEME")
local colors = osc and osc or ({
  "yicks_yellow",
  "yicks_green",
  "yicks_blue",
})[math.random(3)]

return {
  "yicks",
  dev = true,
  priority = 1000,
  opts = colors,
}
