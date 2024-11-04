-- simirian's NeoVim
-- nvimtree popup config

local icons = require("icons")

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {
    hijack_cursor = true,
    disable_netrw = true,
    sync_root_with_cwd = true,
    sort = {
      sorter = "case_sensitive",
      folders_first = true,
    },
    view = {
      float = {
        enable = true,
        quit_on_focus_loss = false,
        open_win_config = function()
          return {
            border = "none",
            relative = "editor",
            width = 40,
            height = vim.go.lines - 3,
            col = 0,
            row = 1,
          }
        end,
      },
    },
    renderer = {
      add_trailing = true,
      root_folder_label = false,
      special_files = {},
      hidden_display = "simple",
      symlink_destination = true,
      highlight_git = "name",
      highlight_diagnostics = "icon",
      highlight_clipboard = "name",
      icons = {
        symlink_arrow = "->",
        show = { modified = false },
        glyphs = {
          default = icons.file,
          symlink = icons.file_link,
          bookmark = icons.tag,
          modified = icons.dot,
          folder = {
            arrow_closed = icons.right,
            arrow_open = icons.down,
            default = icons.folder_close,
            open = icons.folder_open,
            empty = icons.folder_empty,
            empty_open = icons.folder_empty,
            symlink = icons.folder_link,
            symlink_open = icons.folder_link,
          },
          git = {
            unstaged = icons.git_modified,
            staged = icons.git_staged,
            unmerged = "", -- TODO: what is this??
            renamed = icons.git_renamed,
            untracked = icons.git_untracked,
            deleted = icons.git_deleted,
            ignored = icons.git_ignored,
          },
        },
      },
    },
    hijack_directories = { enable = false },
    update_focused_file = { enable = false },
    git = {
      show_on_dirs = false,
      timeout = 10000,
    },
    diagnostics = {
      enable = true,
      debounce_delay = 50,
      severity = {
        min = vim.diagnostic.severity.WARN,
        max = vim.diagnostic.severity.ERROR,
      },
      icons = {
        hint = icons.hint,
        info = icons.info,
        warning = icons.warning,
        error = icons.error,
      },
    },
    modified = { enable = false },
    live_filter = { prefix = " " },
    filesystem_watchers = { enable = true },
    actions = {
      change_dir = { enable = false },
      file_popup = { open_win_config = { border = "none" } },
      open_file = {
        quit_on_open = true,
        window_picker = { enable = false },
      },
    },
    log = { enable = false },
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

    vim.keymap.set("n", "<leader>e", require("nvim-tree.api").tree.toggle)
  end
}
