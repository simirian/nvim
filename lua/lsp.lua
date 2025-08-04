-- simirian's Neovim
-- LSP config loader

--- Selects the next item in the completion menu, or opens omnifunc if it isn't
--- visible.
local function cmp_next()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  if line == "" then
    return "<tab>"
  elseif line:sub(1, cursor[2]):match("^%s*$") then
    vim.cmd(">")
    return ""
  elseif vim.fn.pumvisible() == 1 then
    return "<C-n>"
  else
    return "<C-x><C-o>"
  end
end

--- Selects the previous item in the completion menu, or opens omnifunc if it is
--- not visible.
local function cmp_prev()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  if line:sub(1, cursor[2]):match("^%s*$") then
    vim.cmd("<")
    return ""
  elseif vim.fn.pumvisible() == 1 or vim.fn.state("m") == "m" then
    return "<C-p>"
  else
    return "<C-x><C-o>"
  end
end

vim.diagnostic.config {
  underline = true,
  virtual_text = {
    prefix = function(diagnostic)
      return ({ " ", " ", " ", " " })[diagnostic.severity]
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

local augroup = vim.api.nvim_create_augroup("lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Create keymaps when language server attaches to a buffer.",
  group = augroup,
  callback = function(e)
    vim.keymap.set("i", "<tab>", cmp_next, { desc = "Next completion item.", buffer = e.buf, expr = true })
    vim.keymap.set("i", "<S-tab>", cmp_prev, { desc = "Previous completion item.", buffer = e.buf, expr = true })
  end
})

vim.lsp.config("*", { root_markers = { ".git" } })

local servers = vim.api.nvim_get_runtime_file("lsp/*.lua", true)
servers = vim.tbl_map(function(file)
  return file:match("([^/\\]+)%.lua$")
end, servers)
vim.lsp.enable(servers)
