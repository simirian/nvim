-- simirian's NeoVim
-- LSP config loader, configured in nvim-manager

local icons = require("icons")
local lsp = vim.lsp
local lspb = lsp.buf
local vdg = vim.diagnostic

-- definitions {{{1

lsp.set_log_level(vim.log.levels.WARN)

-- diagnostic setings {{{2
vdg.config {
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = false,
  signs = {
    text = {
      [vdg.severity.ERROR] = icons.error,
      [vdg.severity.WARN]  = icons.warning,
      [vdg.severity.INFO]  = icons.info,
      [vdg.severity.HINT]  = icons.hint,
    },
  },
  float = {
    source = true,
    border = "none",
  },
}

-- keymaps {{{2
local keys = require("keymaps")
keys.lsp = {
  { "<leader>gd", lspb.definition,     desc = "[g]oto [d]efinition." },
  { "<leader>gD", lspb.declaration,    desc = "[g]oto [D]eclaration." },
  { "<leader>gi", lspb.implementation, desc = "[g]oto [i]mplementation." },
  { "<leader>gr", lspb.references,     desc = "[g]et [r]eferences." },
  { "<leader>ld", vdg.open_float,      desc = "[l]ist [d]iagnostics." },
  { "<leader>li", lspb.hover,          desc = "[l]ist symbol [i]nformation" },
  { "<leader>ls", lspb.signature_help, desc = "[l]ist function [s]ignature." },
  { "<C-s>",      lspb.signature_help, desc = "List function [s]ignature.",  mode = "i" },
  { "<leader>cr", lspb.rename,         desc = "[c]ode [r]ename" },
  { "<leader>ca", lspb.code_action,    desc = "[c]ode [a]ctions" },
  { "<leader>cf", lspb.format,         desc = "[c]ode [f]ormat" },
}
vim.api.nvim_create_autocmd("LspAttach",
  { callback = function(event) keys.setup("lsp", event.buffer) end })

-- plugin {{{1
return {
  "williamboman/mason.nvim",
  opts = {
    ui = {
      check_outdated_packages_on_open = true,
      border = "none",
      width = 0.8,
      height = 0.8,
      icons = {
        package_installed   = icons.check,
        package_pending     = icons.pending,
        package_uninstalled = icons.cross,
      },
    },
  },
}
-- vim:fdm=marker
