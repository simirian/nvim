-- simirian's NeoVim
-- LSP config loader, configuration goes in settings.lua

-- TODO: language specific lazy modules, alongside an lsp-base module

local settings = require("settings")

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
      require("mason-lspconfig").setup({
        ensure_installed = require("nvim-manager.workspaces").lsps(),
        automatic_installation = true,
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    -- this just sets up lsp settings, it does not actually set up servers,
    --   that's done by nvim-manager.
    config = function()
      local signs = {
        DiagnosticSignError = settings.icons.error,
        DiagnosticSignWarn  = settings.icons.warning,
        DiagnosticSignHint  = settings.icons.hint,
        DiagnosticSignInfo  = settings.icons.info,
      }

      for name, sign in pairs(signs) do
        vim.fn.sign_define(name, { texthl = name, text = sign, numhl = "" })
      end

      local config = {
        virtual_text = false,
        signs = { active = signs },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "none",
          source = "always",
          header = "",
          prefix = "",
        },
      }
      vim.diagnostic.config(config)

      -- lsp keybonds
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local map = vim.keymap.set
          local opts = { buffer = ev.buf, noremap = true, silent = true }
          map("n", "<leader>gd", vim.lsp.buf.definition, opts)
          map("n", "<leader>gD", vim.lsp.buf.declaration, opts)
          map("n", "<leader>gi", vim.lsp.buf.implementation, opts)
          map("n", "<leader>gr", vim.lsp.buf.references, opts)
          map("n", "<leader>ld", vim.diagnostic.open_float, opts)
          map("n", "<leader>lh", vim.lsp.buf.hover, opts)
          map("n", "<leader>ls", vim.lsp.buf.signature_help, opts)
          map("n", "<leader>cr", vim.lsp.buf.rename, opts)
          map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          map("n", "<leader>cf", vim.lsp.buf.format, opts)
          map("n", "[d", vim.diagnostic.goto_prev, opts)
          map("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })
    end,
  },
}
