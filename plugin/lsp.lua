-- simirian's Neovim
-- LSP configuration plugin

vim.diagnostic.config {
  virtual_text = {
    prefix = function(diagnostic)
      return ({ " ", " ", " ", " " })[diagnostic.severity]
    end,
  },
  signs = false,
  update_in_insert = true,
  severity_sort = true,
}

vim.o.completeopt = "menu,popup,fuzzy,menuone,noinsert"
vim.o.completeitemalign = "kind,abbr,menu"
vim.opt.shortmess:append("c")

--- Selects the next item in the completion menu, or opens omnifunc if it isn't
--- visible. I don't know why, but `vim.snippet.jump()` has to be wrapped in
--- "<cmd>" and "<cr>" instead of just called.
---
--- 1. if there's a pum, insert the selction
--- 2. if there's a snippet, navigate forwards
--- 3. invoke completion
local function tab()
  if vim.fn.pumvisible() ~= 0 then
    return "<C-y>"
  elseif vim.snippet.active() then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  end
  return "<C-x><C-o>"
end

--- Selects the previous item in the completion menu, or opens omnifunc if it is
--- not visible. For some reason `vim.snippet.jump()` has to be wrapped in
--- "<cmd>" and "<cr>".
---
--- 1. if there's a pum, close it
--- 2. if there's a snippet, navigate backwards
--- 3. <tab>
local function s_tab()
  if vim.fn.pumvisible() ~= 0 then
    return "<C-e>"
  elseif vim.snippet.active() then
    return "<cmd>lua vim.snippet.jump(-1)<cr>"
  end
  return "<tab>"
end

-- found with the help of https://github.com/onsails/lspkind.nvim
local kinds = {
  Method = "λ",
  Unit = "",
  Module = "",
  Event = "",
  Folder = "",
  Text = "󰉿",
  File = "󰈙",
  Color = "",
  Operator = "󱓉",
  EnumMember = "󰎢",
  TypeParameter = "",
  Enum = "󱃣",
  Interface = "",
  Constant = "󰭷",
  Constructor = "",
  Function = "󰡱",
  Class = "",
  Keyword = "",
  Value = "󰺢",
  Variable = "󰄪",
  Property = "",
  Field = "󱈤",
  Struct = "",
  Reference = "",
  Snippet = "󰩫",
}

--- Converts an lsp completion item to a vim completion item. See
--- `:h complete-items` for information on vim compeltion items.
--- @param item lsp.CompletionItem
--- @return table item
local function lsptovim(item)
  return {
    kind = kinds[vim.lsp.protocol.CompletionItemKind[item.kind]],
    kind_hlgroup = vim.lsp.protocol.CompletionItemKind[item.kind] .. "Kind",
    abbr = item.label,
    menu = "[LSP]",
  }
end

--- @type vim.lsp.Config
local defaults = {
  root_markers = { ".git" },
  on_attach = function(client, bufnr)
    if client.capabilities.textDocument.completion then
      vim.lsp.completion.enable(true, client.id, bufnr, { convert = lsptovim, autotrigger = true })
    end
    vim.keymap.set({ "i", "s" }, "<tab>", tab, { desc = "Complete or snippet jump.", expr = true, silent = true, buffer = bufnr })
    vim.keymap.set({ "i", "s" }, "<S-tab>", s_tab, { desc = "Snippet return or cancel.", expr = true, silent = true, buffer = bufnr })
  end,
}
vim.lsp.config("*", defaults)

local servers = vim.api.nvim_get_runtime_file("lsp/*.lua", true)
servers = vim.tbl_map(function(file)
  return file:match("([^/\\]+)%.lua$")
end, servers)
vim.lsp.enable(servers)
