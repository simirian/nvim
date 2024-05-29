-- simirian's NeoVim
-- lazy.nvim config, plugins are in ./plugins/

local vfn = vim.fn
local settings = require("settings")

local lazypath = vfn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vfn.system { "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  lockfile = vfn.stdpath("config") .. "/lazy-lock.json",
  git = {
    log = { "-8" },
    timeout = 120,
    url_format = "https://github.com/%s.git",
    filter = true,
  },
  dev = {
    path = "~/source/",
    patterns = {},
    fallback = false,
  },
  install = {
    missing = true,
    colorscheme = { "yicks" },
  },
  ui = {
    size = {
      width = 0.8,
      height = 0.8,
    },
    wrap = true,
    border = "none",
    title = nil, -- appears in border
    title_pos = "left",
    pills = true,
    icons = {
      cmd        = settings.icons.command,
      event      = settings.icons.event,
      ft         = settings.icons.file,
      init       = settings.icons.config,
      import     = settings.icons.sub_module,
      keys       = settings.icons.key,
      lazy       = settings.icons.lazy,
      loaded     = settings.icons.dot,
      not_loaded = settings.icons.circle,
      plugin     = settings.icons.package,
      runtime    = settings.icons.nvim,
      require    = settings.icons.package,
      source     = settings.icons.code,
      start      = settings.icons.start,
      task       = settings.icons.check,
      list       = { "-", "-", "-", "-", },
    },
    browser = nil, --- @type string?
    throttle = 20,
    custom_keys = {},
  },
  diff = { cmd = "git" },
  checker = {
    enabled = false,
    concurrency = nil,
    notify = true,
    frequency = 3600,
    check_pinned = false,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
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
  readme = {
    enabled = true,
    root = vfn.stdpath("state") .. "/lazy/readme",
    files = { "README.md", "lua/**/README.md" },
    skip_if_doc_exists = true,
  },
  state = vfn.stdpath("state") .. "/lazy/state.json",
  build = { warn_on_override = true },
  profiling = {
    loader = false,
    require = false,
  },
})
