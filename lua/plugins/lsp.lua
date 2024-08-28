-- simirian's NeoVim
-- LSP config loader, configured in nvim-manager

local icons = require("icons")
local lsp = vim.lsp
local lspb = lsp.buf
local vdg = vim.diagnostic

lsp.set_log_level(vim.log.levels.WARN)

-- diagnostic setings
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
    prefix = "",
    border = "none",
  },
}

-- lsp keybinds
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = vim.keymap.set
    local opts = { buffer = event.buf, noremap = true, silent = true }
    map("n", "<leader>gd", lspb.definition, opts)
    map("n", "<leader>gD", lspb.declaration, opts)
    map("n", "<leader>gi", lspb.implementation, opts)
    map("n", "<leader>gr", lspb.references, opts)
    map("n", "<leader>ld", vdg.open_float, opts)
    map("n", "<leader>lh", lspb.hover, opts)
    map("n", "<leader>ls", lspb.signature_help, opts)
    map("n", "<leader>cr", lspb.rename, opts)
    map("n", "<leader>ca", lspb.code_action, opts)
    map("n", "<leader>cf", lspb.format, opts)
  end,
})

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
