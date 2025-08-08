-- simirian's Neovim
-- LSP configuration

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
--- 3. if in starting whitespace, increase indent
--- 4. "<tab>"
local function tab()
  local line = vim.api.nvim_get_current_line()
  if vim.fn.pumvisible() ~= 0 then
    return "<C-y>"
  elseif vim.snippet.active() then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  elseif line:match("^%s*$") then
    return "<tab>"
  elseif line:sub(1, vim.api.nvim_win_get_cursor(0)[2]):match("^%s*$") then
    return "<cmd>><cr>"
  end
  return "<tab>"
end

--- Selects the previous item in the completion menu, or opens omnifunc if it is
--- not visible. For some reason `vim.snippet.jump()` has to be wrapped in
--- "<cmd>" and "<cr>".
---
--- 1. if there's a pum, close it
--- 2. if there's a snippet, navigate backwards
--- 3. if in staring whitespace, increase indent
--- 4. invoke completion
local function s_tab()
  local line = vim.api.nvim_get_current_line()
  if vim.fn.pumvisible() ~= 0 then
    return "<C-e>"
  elseif vim.snippet.active() then
    return "<cmd>lua vim.snippet.jump(-1)<cr>"
  elseif line:sub(1, vim.api.nvim_win_get_cursor(0)[2]):match("^%s*$") then
    return "<cmd><<cr>"
  end
  return "<C-x><C-o>"
end

vim.keymap.set({ "i", "s" }, "<tab>", tab, { desc = "Complete or snippet jump.", expr = true, silent = true })
vim.keymap.set({ "i", "s" }, "<S-tab>", s_tab, { desc = "Snippet return or cancel.", expr = true, silent = true })

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

--- @type boolean
local cancomplete = false

--- Checks if the inserted char can trigger completion, and if so allows
--- completion after the character is inserted.
local function testcomplete()
  if vim.fn.pumvisible() == 0 and vim.fn.state("m") ~= "m" and vim.v.char:find("[%a.]") then
    cancomplete = true
  end
end

--- If the completion test passed, then invoke completion.
local function autocomplete()
  if cancomplete then
    vim.lsp.completion.get()
    cancomplete = false
  end
end

local augroup = vim.api.nvim_create_augroup("lsp", {clear = true})

--- @type vim.lsp.Config
local defaults = {
  root_markers = { ".git" },
  on_attach = function(client, bufnr)
    -- enable completion
    if client.capabilities.textDocument.completion then
      vim.lsp.completion.enable(true, client.id, bufnr, { convert = lsptovim })
      vim.api.nvim_create_autocmd("InsertCharPre", {
        desc = "Test for language server autocompletion.",
        group = augroup,
        buffer = bufnr,
        callback = testcomplete,
      })
      vim.api.nvim_create_autocmd("TextChangedI", {
        desc = "Language server autocomplete when typing.",
        group = augroup,
        buffer = bufnr,
        callback = autocomplete,
      })
    end
  end,
}
vim.lsp.config("*", defaults)

local servers = vim.api.nvim_get_runtime_file("lsp/*.lua", true)
servers = vim.tbl_map(function(file)
  return file:match("([^/\\]+)%.lua$")
end, servers)
vim.lsp.enable(servers)
