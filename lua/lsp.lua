-- simirian's NeoVim
-- LSP config loader

local icons = require("icons")
local keys = require("keymaps")

local M = {}
local H = {}

H.servers = {}

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

H.keys = {
  { "<tab>",      H.cmp_next,                 desc = "Next completion item.",     mode = "i" },
  { "<S-tab>",    H.cmp_prev,                 desc = "Previous completion item.", mode = "i" },
  { "<leader>cd", vim.lsp.buf.definition,     desc = "Go to word definition." },
  { "<leader>cr", vim.lsp.buf.references,     desc = "Find word references." },
  { "<leader>cs", vim.lsp.buf.signature_help, desc = "Show function signature." },
  { "<C-s>",      vim.lsp.buf.signature_help, desc = "Show function signature.",  mode = "i" },
  { "<leader>cn", vim.lsp.buf.rename,         desc = "Reame word." },
  { "<leader>ca", vim.lsp.buf.code_action,    desc = "Code actions." },
  { "<leader>cf", vim.lsp.buf.format,         desc = "Code format." },
}

H.diagnostic = {
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
H.servers = {}

--- Map from file types to a set of server names.
--- @type table<string, table<string, boolean>>
H.filetypes = {}

--- Registers a language server configuration.
--- @param name string The name of the language server.
--- @param config Lsp.Config The language server configuration.
function M.register(name, config)
  if H.servers[name] then
    for ft, servers in pairs(H.filetypes) do
      servers[name] = nil
      if next(H.filetypes[ft]) == nil then
        H.filetypes[ft] = nil
      end
    end
  end
  H.servers[name] = config
  if type(config.filetypes) == "string" then
    config.filetypes = { config.filetypes --[[@as string]] }
  end
  for _, ft in ipairs(config.filetypes --[[@as string[] ]]) do
    if not H.filetypes[ft] then
      H.filetypes[ft] = {}
    end
    H.filetypes[ft][name] = true
  end
end

--- Activates a server by its name in the current buffer.
--- @param name string The namge of the language server to activate.
function M.activate(name)
  local server = H.servers[name]
  if not server then
    vim.notify("server " .. name .. " does not exist", vim.log.levels.ERROR, {})
    return
  end
  local path = vim.api.nvim_buf_get_name(0)
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

function M.setup(opts)
  opts = opts or {}
  keys.add("lsp", opts.keys or H.keys)
  vim.diagnostic.config(opts.diagnostic or H.diagnostic)

  local files = vim.api.nvim_get_runtime_file("lua/lsp/*.lua", true)
  for _, file in ipairs(files) do
    local name = file:match("([^/\\]+)%.lua$")
    M.register(name, require("lsp." .. name))
  end

  H.augroup = vim.api.nvim_create_augroup("lsp", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(e)
      keys.bind("lsp", e.buf)
    end
  })
  vim.api.nvim_create_autocmd("FileType", {
    desc = "Attach LSP to buffer.",
    callback = function()
      if not H.filetypes[vim.bo.ft] then return end
      for server in pairs(H.filetypes[vim.bo.ft]) do
        M.activate(server)
      end
    end
  })
end

return M
