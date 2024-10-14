-- simirian's NeoVim
-- yicks color scheme setup

math.randomseed(vim.loop.uptime() * 1000)

return {
  "yicks",
  dev = true,
  priority = 1000,
  -- random yicks theme
  opts = ({
    "yicks_yellow",
    "yicks_green",
    "yicks_blue",
  })[math.random(3)],
}
