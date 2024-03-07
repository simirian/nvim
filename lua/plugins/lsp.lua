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
          package_installed = settings.icons.Ok,
          package_pending = settings.icons.Pending,
          package_uninstalled = settings.icons.Error,
        },
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      automatic_installation = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    ft = { "lua", "rust", "c", "cpp" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local cmplsp = require("cmp_nvim_lsp")
      local lspconfig = require("lspconfig")
      for server, opts in pairs(settings.languages) do
        lspconfig[server].setup{
          capabilities = cmplsp.default_capabilities(),
          settings = opts.settings,
        }
      end

      do -- set up nvim lsp settings
        local signs = {
          DiagnosticSignError = settings.icons.Error,
          DiagnosticSignWarn = settings.icons.Warning,
          DiagnosticSignHint = settings.icons.Hint,
          DiagnosticSignInfo = settings.icons.Information,
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
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { }),
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
          map("n", "<leader>lr", vim.lsp.buf.rename, opts)
          map("n", "<leader>la", vim.lsp.buf.code_action, opts)
          map("n", "[d", vim.diagnostic.goto_prev, opts)
          map("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })
    end,
  },
}

