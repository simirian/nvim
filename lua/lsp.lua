-- simirian's NeoVim
-- LSP config loader, configured in nvim-manager

local icons = require("icons")

vim.lsp.set_log_level(vim.log.levels.WARN)
vim.diagnostic.config {
  underline = true,
  virtual_text = {
    prefix = function(diagnostic)
      return ({
        icons.diagnostic.error,
        icons.diagnostic.warning,
        icons.diagnostic.info,
        icons.diagnostic.hint,
      })[diagnostic.severity] .. " "
    end,
  },
  signs = false,
  float = {
    source = true,
    border = "none",
  },
  update_in_insert = true,
  severity_sort = true,
}

local H = {}

--- Thin wrapper for nvim_feedkeys(), converts keycodes.
--- @param text string The text to feed.
function H.feed(text)
  vim.api.nvim_feedkeys(vim.keycode(text), "n", false)
end

--- Selects the next item in the completion menu, or opens omnifunc if it isn't
--- visible.
function H.cmp_next()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  if line == "" then
    H.feed("<tab>")
  elseif line:sub(1, cursor[2]):match("^%s*$") then
    vim.cmd(">")
  elseif vim.fn.pumvisible() == 1 then
    H.feed("<C-n>")
  else
    H.feed("<C-x><C-o>")
  end
end

--- Selects the previous item in the completion menu, or opens omnifunc if it is
--- not visible.
function H.cmp_prev()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  if line:sub(1, cursor[2]):match("^%s*$") then
    vim.cmd("<")
  elseif vim.fn.pumvisible() == 1 or vim.fn.state("m") == "m" then
    H.feed("<C-p>")
  else
    H.feed("<C-x><C-o>")
  end
end

local keys = require("keymaps")
keys.add("lsp", {
  -- completion
  { "<tab>", H.cmp_next, desc = "Next completion item.", mode = "i" },
  { "<S-tab>", H.cmp_prev, desc = "Previous completion item.", mode = "i" },
  -- lsp things
  { "<leader>cd", vim.lsp.buf.definition, desc = "Go to word definition." },
  { "<leader>cr", vim.lsp.buf.references, desc = "Find word references." },
  { "<leader>cs", vim.lsp.buf.signature_help, desc = "Show function signature." },
  { "<C-s>", vim.lsp.buf.signature_help, desc = "Show function signature.", mode = "i" },
  { "<leader>cn", vim.lsp.buf.rename, desc = "Reame word." },
  { "<leader>ca", vim.lsp.buf.code_action, desc = "Code actions." },
  { "<leader>cf", vim.lsp.buf.format, desc = "Code format." },
})
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(e)
    keys.bind("lsp", e.buf)
  end
})
