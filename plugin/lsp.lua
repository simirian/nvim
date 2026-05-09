-- simirian's Neovim
-- LSP configuration plugin

local icons = { " ", " ", " ", " " }

vim.diagnostic.config {
  virtual_text = { prefix = function(diagnostic)
    return icons[diagnostic.severity]
  end },
  status = { format = function(counts)
    local line = "%#User2#"
    if next(counts) == nil then
      return line .. "  0 %*"
    end
    for severity, icon in ipairs(icons) do
      if counts[severity] then
        local sstr = vim.diagnostic.severity[severity]
        local hl = "Diagnostic" .. sstr:sub(1, 1) .. sstr:sub(2):lower()
        line = line .. " %$" .. hl .. "$" .. icon .. counts[severity]
      end
    end
    return line .. " %*"
  end },
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

local augroup = vim.api.nvim_create_augroup("autocomplete", { clear = true })

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
  on_attach = function(client, bufnr)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { convert = lsptovim })
      local docomplete = false
      vim.api.nvim_create_autocmd("TextChangedI", {
        desc = "Trigger autocompletion.",
        group = augroup,
        buffer = bufnr,
        callback = function()
          if docomplete and vim.fn.pumvisible() == 0 then
            vim.api.nvim_feedkeys(vim.keycode("<C-x><C-o>"), "m", false)
            docomplete = false
          end
        end,
      })
      vim.api.nvim_create_autocmd("InsertCharPre", {
        desc = "Start autocompletion.",
        group = augroup,
        buffer = bufnr,
        callback = function() docomplete = true end,
      })
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
