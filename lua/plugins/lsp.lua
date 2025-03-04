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
  update_in_insert = true,
  severity_sort = true,
  virtual_text = false,
  signs = {
    text = {
      [vdg.severity.ERROR] = icons.diagnostic.error,
      [vdg.severity.WARN]  = icons.diagnostic.warning,
      [vdg.severity.INFO]  = icons.diagnostic.info,
      [vdg.severity.HINT]  = icons.diagnostic.hint,
    },
  },
  float = {
    source = true,
    border = "none",
  },
}

-- keymaps {{{2

local H = {}

--- H.feed() {{{3
--- Thin wrapper for nvim_feedkeys(), converts keycodes.
--- @param text string The text to feed.
function H.feed(text)
  vim.api.nvim_feedkeys(vim.keycode(text), "n", false)
end

--- H.cmp_next() {{{3
--- Selects the next item in the completion menu, or opens omnifunc if it isn't
--- visible.
function H.cmp_next()
  local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())
  if cursor[2] == 0 then
    H.feed("\t")
    return
  elseif vim.fn.getline(cursor[1]):sub(1, cursor[2]):match("%S") == nil then
    vim.cmd(">")
    return
  end
  if vim.fn.pumvisible() == 1 then
    H.feed("<C-n>")
  else
    H.feed("<C-x><C-o>")
  end
end

--- H.cmp_prev() {{{3
--- Selects the previous item in the completion menu, or opens omnifunc if it is
--- not visible.
function H.cmp_prev()
  local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())
  if vim.fn.getline(cursor[1]):sub(1, cursor[2]):match("%S") == nil then
    vim.cmd("<")
    return
  end
  if vim.fn.pumvisible() == 1 or vim.fn.state("m") == "m" then
    H.feed("<C-p>")
  else
    H.feed("<C-x><C-o>")
  end
end

-- keymap definitions {{{3
local keys = require("keymaps")
keys.add("lsp", {
  -- completion
  { "<tab>",      H.cmp_next,          desc = "Next completion item.",       mode = "i" },
  { "<S-tab>",    H.cmp_prev,          desc = "Previous completion item.",   mode = "i" },
  -- lsp things
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
})
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(e)
    keys.bind("lsp", e.buf)
  end
})

-- plugin {{{1
return {
  "williamboman/mason.nvim",
  opts = {
    ui = {
      check_outdated_packages_on_open = true,
      border = "none",
      width = 0.8,
      height = 0.8,
    },
  },
}
-- vim:fdm=marker
