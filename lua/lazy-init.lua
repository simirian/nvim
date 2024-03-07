-- simirian's NeoVim
-- lazy.nvim config, plugins are in ./plugins/

local stdpath = vim.fn.stdpath

local lazypath = stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system{ "git", "clone", "--filter=blob:none",
  "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  lockfile = stdpath("config") .. "/lazy-lock.json",
  git = {
    log = { "-8" },
    timeout = 120,
    url_format = "https://github.com/%s.git",
    filter = true,
  },
  install = {
    missing = true,
    colorscheme = { require("settings").colorscheme },
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
      cmd = " ",
      config = "",
      event = "",
      ft = " ",
      init = " ",
      import = " ",
      keys = " ",
      lazy = "󰒲 ",
      loaded = "●",
      not_loaded = "○",
      plugin = " ",
      runtime = " ",
      require = "󰢱 ",
      source = " ",
      start = "",
      task = " ",
      list = {
        "-",
        "=",
        ">",
        "*",
      },
    },
    browser = nil, --- @type string?
    throttle = 20,
    custom_keys = {
      ["<localleader>l"] = {
        function(plugin)
          require("lazy.util").float_term({ "lazygit", "log" },
          { cwd = plugin.dir })
        end,
        desc = "Open lazygit log",
      },

      ["<localleader>t"] = {
        function(plugin)
          require("lazy.util").float_term(nil, { cwd = plugin.dir })
        end,
        desc = "Open terminal in plugin dir",
      }
    }
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
      paths = { },
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
    root = stdpath("state") .. "/lazy/readme",
    files = { "README.md", "lua/**/README.md" },
    skip_if_doc_exists = true,
  },
  state = stdpath("state") .. "/lazy/state.json",
  build = { warn_on_override = true },
  profiling = {
    loader = false,
    require = false,
  },
})

