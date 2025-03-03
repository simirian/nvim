--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                              ~ lazy plugins ~                              --
--------------------------------------------------------------------------------

local vfn = vim.fn

-- bootstrap {{{1
local lazypath = vfn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vfn.system { "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }
end
vim.opt.rtp:prepend(lazypath)

local osc = vim.loop.os_getenv("YICKS_THEME")
local colors = osc and osc or "yicks"

-- setup {{{1
require("lazy").setup("plugins", {
  dev = { path = "~/Source/" },
  install = { colorscheme = { colors, "habamax" } },
  ui = {
    size = { width = 0.8, height = 0.8 },
    border = "none",
    pills = true,
    icons = { list = { "-", "-", "-", "-", } },
  },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        -- "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        -- "tarPlugin",
        -- "tohtml",
        -- "tutor",
        -- "zipPlugin",
      },
    },
  },
  -- lazy can generate helptags from the headings in markdown readme files,
  -- so :help works even for plugins that don't have vim docs.
  -- when the readme opens with :help it will be correctly displayed as markdown
  readme = { enabled = false },
})
-- vim:fdm=marker
