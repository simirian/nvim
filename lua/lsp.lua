-- simirian's Neovim
-- LSP config loader

--- Thin wrapper for nvim_feedkeys(), converts keycodes.
--- @param text string The text to feed.
local function feed(text)
  vim.api.nvim_feedkeys(vim.keycode(text), "n", false)
end

--- Selects the next item in the completion menu, or opens omnifunc if it isn't
--- visible.
local function cmp_next()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  if line == "" then
    feed("<tab>")
  elseif line:sub(1, cursor[2]):match("^%s*$") then
    vim.cmd(">")
  elseif vim.fn.pumvisible() == 1 then
    feed("<C-n>")
  else
    feed("<C-x><C-o>")
  end
end

--- Selects the previous item in the completion menu, or opens omnifunc if it is
--- not visible.
local function cmp_prev()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  if line:sub(1, cursor[2]):match("^%s*$") then
    vim.cmd("<")
  elseif vim.fn.pumvisible() == 1 or vim.fn.state("m") == "m" then
    feed("<C-p>")
  else
    feed("<C-x><C-o>")
  end
end

--- Language server client configuration.
--- @class Lsp.Config
--- The root patterns for vim.fs.root() or a function to get the server's root.
--- @field get_root string|string[]|fun(path: string): string
--- The filetypes this langauge server should attach to.
--- @field filetypes string|string[]
--- The configuration which is passed to vim.lsp.start().
--- @field config vim.lsp.ClientConfig|fun(): vim.lsp.ClientConfig

--- Map from server names to their configuration.
--- @type table<string, Lsp.Config>
local servers = {}

--- Map from file types to a set of server names.
--- @type table<string, table<string, boolean>>
local filetypes = {}

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

-- register language servers
local files = vim.api.nvim_get_runtime_file("lua/lsp/*.lua", true)
for _, file in ipairs(files) do
  local name = file:match("([^/\\]+)%.lua$")
  local config = require("lsp." .. name)
  servers[name] = config
  if type(config.filetypes) == "string" then
    config.filetypes = { config.filetypes --[[@as string]] }
  end
  for _, ft in ipairs(config.filetypes) do
    filetypes[ft] = filetypes[ft] or {}
    filetypes[ft][name] = true
  end
end

local augroup = vim.api.nvim_create_augroup("lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Create keymaps when language server attaches to a buffer.",
  group = augroup,
  callback = function(e)
    vim.keymap.set("i", "<tab>", cmp_next, { desc = "Next completion item.", buffer = e.buf })
    vim.keymap.set("i", "<S-tab>", cmp_prev, { desc = "Previous completion item.", buffer = e.buf })
    vim.keymap.set("", "<leader>cd", vim.lsp.buf.definition, { desc = "Go to word definition.", buffer = e.buf })
    vim.keymap.set("", "<leader>cr", vim.lsp.buf.references, { desc = "Find word references.", buffer = e.buf })
    vim.keymap.set("", "<leader>cs", vim.lsp.buf.signature_help, { desc = "Show function signature.", buffer = e.buf })
    vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, { desc = "Show function signature.", buffer = e.buf })
    vim.keymap.set("", "<leader>cn", vim.lsp.buf.rename, { desc = "Reame word.", buffer = e.buf })
    vim.keymap.set("", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions.", buffer = e.buf })
    vim.keymap.set("", "<leader>cf", vim.lsp.buf.format, { desc = "Code format.", buffer = e.buf })
  end
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Attach language servers to buffers.",
  group = augroup,
  callback = function(e)
    local ft = vim.bo[e.buf].ft
    for name in pairs(filetypes[ft] or {}) do
      local server = servers[name]
      local path = vim.api.nvim_buf_get_name(e.buf)
      local config = server.config
      if type(config) == "function" then
        config = config()
      end
      config = vim.tbl_deep_extend("force", config, {
        name = name,
        root_dir = server.get_root
            and (type(server.get_root) == "function"
              and server.get_root(path)
              or vim.fs.root(path, server.get_root))
            or vim.fs.root(path, { ".git", ".editorconfig" })
            --- @diagnostic disable-next-line: undefined-field
            or vim.loop.cwd()
      })
      vim.lsp.start(config)
    end
  end
})
