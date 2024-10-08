-- simirian's NeoVim
-- nvimtree popup config

local icons = require("icons")

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {
    hijack_cursor = true,
    hijack_netrw = true,
    hijack_unnamed_buffer_when_opening = false,
    root_dirs = {},
    prefer_startup_root = true,
    sync_root_with_cwd = true,
    reload_on_bufenter = false,
    respect_buf_cwd = false,
    select_prompts = false,
    sort = {
      sorter = "case_sensitive",
      folders_first = true,
    },
    view = {
      centralize_selection = true,
      cursorline = true,
      debounce_delay = 15,
      side = "left",
      preserve_window_proportions = true,
      number = false,
      relativenumber = false,
      signcolumn = "yes",
      width = math.max(20, math.floor(vim.go.columns / 4)),
      float = {
        enable = true,
        quit_on_focus_loss = false,
        open_win_config = {
          border = "none",
          relative = "editor",
          width = math.max(40, math.floor(vim.go.columns / 4)),
          height = vim.go.lines - 3,
          col = 0,
          row = 1,
        },
      },
    },
    renderer = {
      add_trailing = true,
      group_empty = true,
      full_name = false,
      root_folder_label = false,
      indent_width = 2,
      special_files = {
        "Cargo.toml",
        "makefile",
        "README.md",
        "readme.md",
        "LISCENSE.md",
        ".gitignore",
      },
      symlink_destination = true,
      highlight_git = true,
      highlight_diagnostics = true,
      highlight_opened_files = "none",
      highlight_modified = "none",
      highlight_bookmarks = "none",
      highlight_clipboard = "all",
      indent_markers = {
        enable = true,
        inline_arrows = true,
      },
      icons = {
        web_devicons = {
          file = {
            enable = true,
            color = true,
          },
          folder = {
            enable = false,
            color = true,
          },
        },
        git_placement = "after",
        diagnostics_placement = "signcolumn",
        modified_placement = "after",
        bookmarks_placement = "signcolumn",
        padding = " ",
        symlink_arrow = "->",
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
          modified = true,
          diagnostics = true,
          bookmarks = true,
        },
        glyphs = {
          default  = icons.file,
          symlink  = icons.file_link,
          bookmark = icons.tag,
          modified = icons.circle,
          folder   = {
            arrow_closed = icons.right,
            arrow_open   = icons.down,
            default      = icons.folder_close,
            open         = icons.folder_open,
            empty        = icons.folder_empty,
            empty_open   = icons.folder_empty,
            symlink      = icons.folder_link,
            symlink_open = icons.folder_link,
          },
          git      = {
            unstaged  = icons.modify,
            staged    = icons.modify,
            unmerged  = icons.default,
            renamed   = icons.rename,
            untracked = icons.add,
            deleted   = icons.remove,
            ignored   = icons.ignore,
          },
        },
      },
    },
    hijack_directories = {
      enable = true,
      auto_open = false,
    },
    update_focused_file = {
      enable = false,
      update_root = false,
      ignore_list = {},
    },
    system_open = {
      -- will adapt to os
      cmd = "",
      args = {},
    },
    git = {
      enable = true,
      show_on_dirs = false,
      show_on_open_dirs = false,
      disable_for_dirs = {},
      timeout = 3000,
    },
    diagnostics = {
      enable = true,
      debounce_delay = 50,
      show_on_dirs = true,
      show_on_open_dirs = false,
      severity = {
        min = vim.diagnostic.severity.WARN,
        max = vim.diagnostic.severity.ERROR,
      },
      icons = {
        hint    = icons.hint,
        info    = icons.info,
        warning = icons.warning,
        error   = icons.error,
      },
    },
    modified = {
      enable = false,
      show_on_dirs = false,
      show_on_open_dirs = false,
    },
    filters = {
      git_ignored = true,
      dotfiles = false,
      git_clean = false,
      no_buffer = false,
      no_bookmark = false,
      -- always shown
      exclude = {},
    },
    live_filter = {
      prefix = " ",
      always_show_folders = true,
    },
    filesystem_watchers = {
      enable = true,
      debounce_delay = 50,
      ignore_dirs = {},
    },
    actions = {
      use_system_clipboard = true,
      change_dir = {
        enable = false,
        global = false,
        restrict_above_cwd = true,
      },
      expand_all = {
        max_folder_discovery = 300,
        exclude = { ".git", "target", "build" },
      },
      file_popup = {
        open_win_config = {
          width = 20,
          height = 30,
          col = 1,
          row = 1,
          relative = "cursor",
          border = "none",
          style = "minimal",
        },
      },
      open_file = {
        quit_on_open = true,
        eject = true,
        resize_window = true,
        window_picker = {
          enable = false,
          picker = "default",
          chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          exclude = {
            filetype = {
              "notify",
              "packer",
              "qf",
              "diff",
              "fugitive",
              "fugitiveblame",
            },
            buftype = {
              "nofile",
              "terminal",
              "help",
            },
          },
        },
      },
      remove_file = {
        close_window = true,
      }
    },
    trash = {
      -- adapts to os by default
      cmd = nil,
    },
    tab = {
      sync = {
        open = false,
        close = false,
        ignore = {},
      },
    },
    notify = {
      threshold = vim.log.levels.INFO,
      absolute_path = true,
    },
    help = {
      sort_by = "key",
    },
    ui = {
      confirm = {
        remove = true,
        trash = true,
        default_yes = false,
      },
    },
    log = {
      enable = false,
      truncate = false,
      types = {
        all = false,
        profile = true,
        config = true,
        copy_paste = true,
        dev = false,
        diagnostics = false,
        git = true,
        watcher = false,
      },
    },
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")

      local function opts(desc)
        return {
          desc = desc,
          buffer = bufnr,
          noremap = true,
          silent = true,
        }
      end

      api.config.mappings.default_on_attach(bufnr)
      vim.keymap.set("n", "l", api.node.open.drop, opts("open item"))
      vim.keymap.set("n", "h", "<Nop>", opts(nil))
    end
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.keymap.set("n", "<leader>e", require("nvim-tree.api").tree.toggle)
  end
}
