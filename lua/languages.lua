-- simirian's NeoVom
-- languages utility module to process languages stored in lua/languages/

local settings = require("settings")

local M = { }

local template = {
  --- detector for workspaces of this langauge
  --- @type fun(): boolean
  detector = nil,
  --- workspace root directory finder
  --- @type string|string[] workspace root directory identifier
  workspace_root = ".git/",
  --- filetypes for this language
  --- @type string|string[]
  filetypes = { },
  --- treesitter parsers to install for this language
  --- @type string|string[]
  ts_parser = { },

  lsp = {
    --- lsp name for nvim-lspconfig
    --- @type string
    name = nil,
  },
}

--- Finds if a directory contains a file.
--- @param dir string the directory to check
--- @param item string the item to check for
--- @return boolean
function M.dir_contains(dir, item)
  local files = vim.split(vim.fn.glob(dir .. "/*"), "\n")
  for i, v in ipairs(files) do files[i] = vim.fs.basename(v) end
  return vim.tbl_contains(files, ".luarc.json")
end

--- Returns a list of configured langauges.
--- @return table[]
function M.languages()
  local langs = { }

  local files = vim.api.nvim_get_runtime_file("lua/languages/*.lua", true)
  for _, file in ipairs(files) do
    local basename = vim.fs.basename(file)
    local lang = string.match(basename, "%w*")
    local path = "languages." .. lang

    langs[lang] = require(path)
  end

  return langs
end

--- Treesitter default languages to always include.
--- @return string[]
function M.treesitter_default_languages()
  if settings.ts_default_lang then return settings.ts_default_lang end
  return { "c", "lua", "vim", "vimdoc", "query", "bash" }
end

--- Treesitter languages for ensure_installed setup key.
--- @return string[]
function M.treesitter_languages()
  local tbl = M.treesitter_default_languages()
  local langs = M.languages()

  for _, opts in pairs(langs) do
    if type(opts.ts_parser) == "table" then
      for _, parser in ipairs(opts.ts_parser) do
        if not vim.tbl_contains(tbl, parser) then
          table.insert(tbl, parser)
        end
      end
    else
      if not vim.tbl_contains(tbl, opts.ts_parser) then
        table.insert(tbl, opts.ts_parser)
      end
    end
  end

  return tbl
end

--- Default language config that gets merged with the given config.
--- @return table
function M.default_language_config()
  return template
end

--- Gets a specified languages config.
--- @param lang string the language config to retrieve
function M.get_language_config(lang)
  local ok, config = pcall(require("../languages/" .. lang))
  config = ok and config or { }
  return vim.tbl_deep_extend("force", template, config)
end

--- Populates workspace settings based on the current open directory.
--- - vim.g.workspace_dir: root of the workspace, cds here
--- - vim.g.workspace_lang: the primary language of the workspace
function M.get_workspace()
  local langs = M.languages()

  for _, opts in pairs(langs) do
    if opts.detector() then
      -- TODO: look backwards for workspace root dir
      vim.g.workspace_dir = vim.fn.getcwd()
      vim.g.workspace_lang = opts.filetypes[0]
      vim.api.nvim_exec_autocmds("User", { pattern = "WorkspaceEnter" })
      break
    end
  end
end

return M

