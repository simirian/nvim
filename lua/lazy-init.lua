--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                              ~ lazy plugins ~                              --
--------------------------------------------------------------------------------

local vfn = vim.fn
local icons = require("icons")

-- bootstrap {{{1
local lazypath = vfn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vfn.system { "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }
end
vim.opt.rtp:prepend(lazypath)

-- setup {{{1
require("lazy").setup("plugins", {
  dev = { path = "~/Source/" },
  install = { colorscheme = { "yicks", "habamax" } },
  ui = {
    size = { width = 0.8, height = 0.8 },
    border = "none",
    pills = true,
    icons = {
      cmd        = icons.command,
      config     = icons.config,
      event      = icons.event,
      favorite   = icons.star,
      ft         = icons.file,
      init       = icons.config,
      import     = icons.package,
      keys       = icons.key_keyboard,
      lazy       = icons.lazy,
      loaded     = icons.dot,
      not_loaded = icons.circle,
      plugin     = icons.package,
      runtime    = icons.nvim,
      require    = icons.package,
      source     = icons.code,
      start      = icons.start,
      task       = icons.check,
      list       = { "-", "-", "-", "-", },
    },
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
