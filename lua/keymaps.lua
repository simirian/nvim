-- simirian's NeoVim
-- keymaps manager module

local M = {}
local H = {}

-- set leader key
vim.keymap.set("", " ", "<Nop>")
vim.g.mapleader = " "
vim.g.localleader = " "

--- Valid mode letters for keymaps. (see :h map-table)
--- @alias VimMode string vim mode letters
--- | ""  # normal, visual, select, operator
--- | "n" # normal
--- | "!" # insert, command
--- | "i" # insert
--- | "c" # command
--- | "v" # visual, select
--- | "x" # visual
--- | "s" # select
--- | "o" # operator
--- | "t" # terminal
--- | "l" # insert, command, lang-arg

--- Represents a keymap fot the user to define.
--- @class Keymap: vim.keymap.set.Opts
--- The left hand side, what triggers the mapping.
--- @field [1] string
--- The right hand side, what the mapping does.
--- @field [2] string|fun()
--- Mode in which this mapping applies.
--- @field mode? VimMode|VimMode[]

--- @alias MapNS { maps: Keymap[], buffers: table<integer, boolean> }

--- @type table<string, MapNS>
H.ns = {}

--- Default maps.
H.ns["default"] = {
  maps = {
    -- window and tab navigation
    { "<C-h>",      "gT",                desc = "Go to previous tab page." },
    { "<C-j>",      "<C-w>w",            desc = "Focus previous window." },
    { "<C-k>",      "<C-w>W",            desc = "Focus next window." },
    { "<C-l>",      "gt",                desc = "Go to next tab page." },
    { "<C-h>",      "<C-\\><C-o>gT",     desc = "Go to previous tab page.",      mode = "t", },
    { "<C-j>",      "<C-\\><C-o><C-w>w", desc = "Go to previous window.",        mode = "t", },
    { "<C-k>",      "<C-\\><C-o><C-w>W", desc = "Go to next window.",            mode = "t", },
    { "<C-l>",      "<C-\\><C-o>gt",     desc = "go to next tab page.",          mode = "t", },
    -- resizing windows
    { "<C-up>",     "1<C-w>+",           desc = "Increase window height." },
    { "<C-down>",   "1<C-w>-",           desc = "Decrease window height." },
    { "<C-left>",   "2<C-w><",           desc = "Decrease window width." },
    { "<C-right>",  "2<C-w>>",           desc = "Increase window width." },
    -- move lines
    { "<A-j>",      ":move +1<cr>",      desc = "Move line down." },
    { "<A-k>",      ":move -2<cr>",      desc = "Move line up" },
    { "<A-j>",      ":move '>+1<cr>gv",  desc = "Move lines down.",              mode = "x" },
    { "<A-k>",      ":move '<-2<cr>gv",  desc = "Move lines up.",                mode = "x" },
    -- quick escape
    { "jj",         "<esc>",             desc = "Escape insert mode.",           mode = "i" },
    { "<esc><esc>", "<esc>",             desc = "leave terminal mode",           mode = "t" },
    -- registers
    { "<leader>p",  "\"+p",              desc = "Paste from system clipboard.",  mode = { "n", "x" } },
    { "<leader>y",  "\"+y",              desc = "Yank to system clipboard.",     mode = { "n", "x" } },
    { "p",          "\"_dP",             desc = "Cleanly paste over selection.", mode = "x" },
    -- indenting
    { "<tab>",      ">gv",               desc = "Indent selected liens",         mode = "v" },
    { "<S-tab>",    "<gv",               desc = "Unindent selected lines",       mode = "v" },
    -- misc mappings
    { "U",          "<C-r>",             desc = "Redo." },
    { "<C-f>",      "<esc>m`gqap``a",    desc = "Format in insert mode.",        mode = "i" },
    { "cw",         "caw",               desc = "Change to next word." },
    -- funky character found with <C-v><C-BS> in insert mode with 'display' uhex
    { "\x08",       "<C-w>",             desc = "Delete back a word.",           mode = "i" },
    { "-",          ":e %:h<cr>",        desc = "Open current buffer's parent." },
    { "_",          ":e .<cr>",          desc = "Open nvim's current directory." },
  },
  buffers = {},
}

--- Creates a keymap on a buffer or globally if no buffer is provided.
--- @param map Keymap The keymap to bind.
--- @param buffer? integer The buffer to map on, 0 for current.
function H.map(map, buffer)
  local copy = vim.deepcopy(map)
  copy[1] = nil
  copy[2] = nil
  copy.mode = nil
  copy = vim.tbl_extend("keep", copy, {
    buffer = buffer,
    noremap = true,
    silent = true,
  })
  vim.keymap.set(map.mode or "", map[1], map[2], copy)
end

--- Adds a mapping or list of mappings to a keymap namespace.
--- @param namespace string The namespace to add mappings to.
--- @param maps Keymap|Keymap[] The keymaps to add to the namespace.
function M.add(namespace, maps)
  if not H.ns[namespace] then
    H.ns[namespace] = { maps = {}, buffers = {} }
  end
  if type(maps[1]) == "string" then
    maps = { maps }
  end
  H.ns[namespace].maps = vim.list_extend(H.ns[namespace].maps, maps)
  for bufnr in pairs(H.ns[namespace].buffers) do
    for _, map in ipairs(maps) do
      --- only string here
      --- @diagnostic disable-next-line: param-type-mismatch
      H.map(map, bufnr ~= 0 and bufnr or nil)
    end
  end
end

--- Removes keymaps from a namespace and buffers that namespace is bound to.
--- @param namespace string The namespace to remove mappings from.
--- @param maps Keymap|Keymap[] The keymaps to remove from the namespace.
function M.remove(namespace, maps)
  if not H.ns[namespace] then return end
  if type(maps[1]) == "string" then
    maps = { maps }
  end
  local newmaps = {}
  for _, nsmap in ipairs(maps) do
    local include = true
    for _, map in ipairs(maps) do
      if map.mode == nsmap.mode and map[1] == nsmap[1] then
        include = false
      end
    end
    if include then
      table.insert(newmaps, nsmap)
    end
  end
  H.ns[namespace].maps = newmaps
  for bufnr in pairs(H.ns[namespace].buffers) do
    for _, map in ipairs(maps) do
      --- only string here
      --- @diagnostic disable-next-line: param-type-mismatch
      vim.keymap.del(map.mode or "n", map[1], { buffer = bufnr ~= 0 and bufnr or nil })
    end
  end
end

--- Binds all the maps associated with a namespace to a buffer, or globally if
--- no buffer is provided.
--- @param namespaces string|string[] The namespaces to map.
--- @param buffers? integer|integer[] The buffers in which to map, 0 for current.
function M.bind(namespaces, buffers)
  --- Binds all the keys in the provided namespaces to the given buffer.
  --- @param bufnr? integer The buffer to map on.
  local function mapkeys(bufnr)
    if bufnr == 0 then
      bufnr = vim.api.nvim_get_current_buf()
    end
    --- only string[] here
    --- @diagnostic disable-next-line: param-type-mismatch
    for _, ns in ipairs(namespaces) do
      H.ns[ns].buffers[bufnr or 0] = true
      for _, map in ipairs(H.ns[ns].maps) do
        H.map(map, bufnr)
      end
    end
  end
  if type(namespaces) ~= "table" then
    namespaces = { namespaces }
  end
  if type(buffers) == "table" then
    for _, bufnr in ipairs(buffers) do
      mapkeys(bufnr)
    end
  else
    mapkeys(buffers)
  end
end

--- Unbinds all mapes associated with the given namespaces with the given
--- buffers.
--- @param namespaces string|string[] The namespaces to unmap.
--- @param buffers? integer|integer[] The buffers in to modify, 0 for current.
function M.unbind(namespaces, buffers)
  --- Unmaps all the keys of the namespaces in the given buffer.
  --- @param bufnr? integer The buffer to modify.
  local function unmapkeys(bufnr)
    if bufnr == 0 then
      bufnr = vim.api.nvim_get_current_buf()
    end
    --- always string[] here
    --- @diagnostic disable-next-line: param-type-mismatch
    for _, ns in ipairs(namespaces) do
      H.ns[ns].buffers[bufnr or 0] = nil
      for _, map in ipairs(H.ns[ns].maps) do
        vim.keymap.del(map.mode or "n", map[1], { buffer = bufnr })
      end
    end
  end
  if type(namespaces) ~= "table" then
    namespaces = { namespaces }
  end
  if type(buffers) == "table" then
    for _, bufnr in ipairs(buffers) do
      unmapkeys(bufnr)
    end
  else
    unmapkeys(buffers)
  end
end

return M
