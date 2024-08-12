-- simirian's NeoVim
-- LSP config loader, configuration goes in settings.lua

local settings = require("settings")
local vfn = vim.fn
local vlsb = vim.lsp.buf

return {
  {
    "williamboman/mason.nvim",
    lazy = true,
    opts = {
      ui = {
        check_outdated_packages_on_open = true,
        border = "none",
        width = 0.8,
        height = 0.8,
        icons = {
          package_installed   = settings.icons.check,
          package_pending     = settings.icons.pending,
          package_uninstalled = settings.icons.cross,
        },
      },
    },
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
    dependencies = { "williamboman/mason.nvim", "nvim-manager" },
    config = function()
      local servers = {}
      local ws_specs = require("nvim-manager.workspaces").list()
      for _, spec in pairs(ws_specs) do
        for server, _ in pairs(spec.lsp) do
          if not vim.tbl_contains(servers, server) then
            table.insert(servers, server)
          end
        end
      end
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true,
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local signs = {
        DiagnosticSignError = settings.icons.error,
        DiagnosticSignWarn  = settings.icons.warning,
        DiagnosticSignHint  = settings.icons.hint,
        DiagnosticSignInfo  = settings.icons.info,
      }

      for name, sign in pairs(signs) do
        vfn.sign_define(name, { texthl = name, text = sign, numhl = "" })
      end

      vim.lsp.set_log_level(vim.lsp.log_levels.WARN)

      local config = {
        underline = true,
        virtual_text = false,
        signs = { active = signs },
        float = {
          scope = "line",
          severity_sort = true,
          focusable = false,
          style = "minimal",
          border = "none",
          source = "always",
          header = "",
          prefix = "",
        },
        update_in_insert = false,
        severity_sort = true,
      }
      vim.diagnostic.config(config)

      -- lsp keybonds
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local map = vim.keymap.set
          local opts = { buffer = ev.buf, noremap = true, silent = true }
          map("n", "<leader>gd", vlsb.definition, opts)
          map("n", "<leader>gD", vlsb.declaration, opts)
          map("n", "<leader>gi", vlsb.implementation, opts)
          map("n", "<leader>gr", vlsb.references, opts)
          map("n", "<leader>ld", vim.diagnostic.open_float, opts)
          map("n", "<leader>lh", vlsb.hover, opts)
          map("n", "<leader>ls", vlsb.signature_help, opts)
          map("n", "<leader>cr", vlsb.rename, opts)
          map("n", "<leader>ca", vlsb.code_action, opts)
          map("n", "<leader>cf", vlsb.format, opts)
        end,
      })
    end,
  },
}
