-- simirian's NeoVim
-- file explorer

local icons = require("icons")
local keys = require("keymaps")
local fs = require("fcache")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local M = {}
local H = {}

H.augroup = vim.api.nvim_create_augroup("fex", { clear = true })
H.namespace = vim.api.nvim_create_namespace("fex")
H.buffers = {}

--- Gets an icon for a file based on its file name.
--- @param fname string The file name to get an icon for.
--- @return string icon
--- @return string highlight
function H.icon(fname)
  local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
  if devicons_ok then
    return devicons.get_icon(fname, fname:match("[^%.]*$"))
  end
  return icons.files.file, "Normal"
end

--- The function used to filter children that get displayed in fex buffers.
--- Should return true if the child should be displayed.
--- @param bufnr integer The buffer to fileter the children of.
--- @param child Fs.Node The child that might need to be included.
--- @return boolean include
function H.filter(bufnr, child)
  return not vim.b[bufnr].fex_hide or child.path:match("[^/]*$"):sub(1, 1) ~= "."
end

--- Filters the children of a fex buffer.
--- @param bufnr integer The buffer to filter the children of.
--- @param children Fs.Node[] The children to be filtered.
--- @return Fs.Node[] children
function H.filter_children(bufnr, children)
  local filter = vim.b[bufnr].fex_filter or H.filter
  return vim.tbl_filter(function(child) return filter(bufnr, child) end, children)
end

--- The function used to sort children that get displayed in fex buffers.
--- Return true if first should come before second.
--- @param bufnr integer The buffer whose children are being sorted.
--- @param first Fs.Node The candidate for first in the list.
--- @param second Fs.Node The candidate for second in the list.
--- @return boolean correct
function H.sort(bufnr, first, second) --- @diagnostic disable-line: unused-local
  --- @diagnostic disable-next-line: undefined-field
  first = first.target or first
  --- @diagnostic disable-next-line: undefined-field
  second = second.target or second
  if first.type == "directory" and second.type ~= "directory" then
    return true
  elseif first.type ~= "directory" and second.type == "directory" then
    return false
  end
  return first.path:match("[^/]*$") < second.path:match("[^/]*$")
end

--- Sorts the children of a fex buffer.
--- @param bufnr integer The buffer to sort the children of.
--- @param children Fs.Node[] The children to sort.
--- @return Fs.Node[] children
function H.sort_children(bufnr, children)
  local sort = vim.b[bufnr].fex_sort or H.sort
  local copy = vim.deepcopy(children)
  table.sort(copy, function(first, second) return sort(bufnr, first, second) end)
  return copy
end

--- Creates a line from a file system node.
--- @param node Fs.Node The node to convert to a single line.
--- @return string line
function H.make_line(node)
  local line = ("/%x\t%s"):format(node.id, node.path:match("[^/]*$"))
  if node.type == "directory" then
    line = line .. "/"
  end
  return line
end

--- Makes a mark from a file system node.
--- @param node Fs.Node The node to make a mark for.
--- @return vim.api.keyset.set_extmark mark
function H.make_mark(node)
  local ico, hl
  if node.type == "directory" then
    ico, hl = icons.files.directory, "Directory"
  elseif node.type == "link" then
    local target = node --[[@as Fs.Link]].target
    if target then
      return H.make_mark(target)
    end
    ico, hl = icons.files.link, "Normal"
  else
    ico, hl = H.icon(node.path:match("[^/]*$"))
  end
  --- @type vim.api.keyset.set_extmark
  return {
    virt_text = { { (ico or icons.files.file) .. " ", hl or "Normal" } },
    line_hl_group = node.type == "directory" and "Directory" or nil,
    virt_text_pos = "inline",
    conceal = "",
  }
end

--- Marks a line as an error.
--- @param bufnr integer The bufer in which to place the mark.
--- @param line integer The line the error is present on.
--- @param level? "Error"|"Warn"|"Info"|"Hint" The level of the error.
function H.mark_diagnostic(bufnr, line, level)
  vim.api.nvim_buf_set_extmark(bufnr, H.namespace, line, 0, {
    line_hl_group = "DiagnosticUnderline" .. (level or "Error"),
    invalidate = true,
  })
end

--- BufWinEnter autocommand callback.
--- @param bufnr integer The buffer enting a window.
function H.winenter(bufnr)
  for _, winid in ipairs(vim.fn.getbufinfo(bufnr)[1].windows) do
    if vim.wo[winid].cole ~= 2 then
      vim.w[winid].cole = vim.wo[winid].cole
      vim.wo[winid].cole = 2
    end
    if vim.wo[winid].cocu ~= "nvic" then
      vim.w[winid].cocu = vim.wo[winid].cocu
      vim.wo[winid].cocu = "nvic"
    end
  end
end

--- BufReadCmd autocommand callback.
--- @param bufnr integer The buffer to read into.
function H.dir_update(bufnr)
  local children = fs.get(vim.api.nvim_buf_get_name(bufnr))--[[@as Fs.Directory]]:get_children()
  for _, child in ipairs(children) do
    if child.type == "link" then
      child --[[@as Fs.Link]]:get_target()
    end
  end
  H.dir_set_lines(bufnr)
  H.dir_set_marks(bufnr)
end

--- Sets up a fex directory buffer.
--- @param bufnr integer The buffer to set up.
function H.dir_setup(bufnr)
  vim.api.nvim_create_autocmd("BufReadCmd", {
    desc = "Update fex directory buffers on read.",
    group = H.augroup,
    buffer = bufnr,
    callback = function() H.dir_update(bufnr) end
  })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    desc = "Sync fex directory buffers on write.",
    group = H.augroup,
    buffer = bufnr,
    callback = M.sync,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    desc = "Remove buffer from internal fex buffer list.",
    group = H.augroup,
    buffer = bufnr,
    callback = function()
      H.buffers[bufnr] = nil
    end,
  })
  vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
    desc = "Constrain cursor position.",
    group = H.augroup,
    buffer = bufnr,
    callback = vim.schedule_wrap(function()
      local curpos = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_get_current_line()
      local isep = line:find("\t")
      if line:sub(1, 1) == "/" and isep and curpos[2] < isep then
        vim.api.nvim_win_set_cursor(0, { curpos[1], isep })
      end
    end),
  })

  keys.bind("fex", bufnr)

  H.buffers[bufnr] = true
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "fex"
  vim.bo[bufnr].tabstop = 8
end

--- Sets the lines in a fex buffer according to the cached children.
--- @param bufnr integer The fex buffer to update the content of.
function H.dir_set_lines(bufnr)
  local node = fs.get(vim.api.nvim_buf_get_name(bufnr)) --[[@as Fs.Directory]]
  local visible = H.sort_children(bufnr, H.filter_children(bufnr, node.children))
  vim.b[bufnr].fex_visible = vim.tbl_map(function(e) return e.id end, visible)
  local lines = vim.tbl_map(H.make_line, visible)
  local oldul = vim.bo[bufnr].undolevels
  vim.bo[bufnr].undolevels = -1
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].undolevels = oldul
  vim.bo[bufnr].modified = false
end

--- Sets the extmarks to show file type icons in the fex buffer.
--- @param bufnr integer The buffer to set marks in.
function H.dir_set_marks(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, H.namespace, 0, -1)
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:sub(1, 1) == "/" then
      local isep = line:find("\t")
      local id = isep and tonumber(line:sub(2, isep - 1), 16)
      local mark = {
        line_hl_group = "DiagnosticUnderlineError",
        invalidate = true,
      }
      if id then
        local node = fs.get(id) --[[@as Fs.Node]]
        mark = H.make_mark(node)
        mark.invalidate = true
        mark.end_col = isep
      end
      vim.api.nvim_buf_set_extmark(bufnr, H.namespace, lnum - 1, 0, mark)
    end
  end
end

--- Map from source ids to a set of paths. An id of 0 indicates a new file, and
--- an id of -1 indicates deleted files
--- @type table<integer, table<string, true>>
H.changes = {}

--- Map from targets to their status.
--- @type table<string, true|{ bufnr: integer, line: integer }>
H.targets = {}

--- Gets the changes in a fex buffer. Returns false if there are parse errors
--- @param bufnr integer The fex buffer to get changes from.
--- @return boolean success
function H.dir_changes_buf(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local ok = true
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for lnum, line in ipairs(lines) do
    line = vim.trim(line)
    local id, target
    if line == "" then
      H.mark_diagnostic(bufnr, lnum - 1, "Warn")
    elseif line:sub(1, 1) ~= "/" then
      id, target = 0, line
    else
      id, target = line:match("^/([%da-f]+)\t(.*%S.*)$")
      if not id or not target then
        H.mark_diagnostic(bufnr, lnum - 1)
        ok = false
      end
    end
    id = tonumber(id or "", 16)
    if id and target then
      target = fs.path(bufname, target) .. (target:match("[/\\]$") and "/" or "")
      if H.targets[target] then
        H.mark_diagnostic(bufnr, lnum - 1)
        if type(H.targets[target]) == "table" then
          H.mark_diagnostic(H.targets[target].bufnr, H.targets[target].line)
          H.targets[target] = true
        end
        ok = false
      else
        -- TODO: check for and mark invalid ids
        if not H.changes[id] then
          H.changes[id] = {}
        end
        H.changes[id][target] = true
        H.targets[target] = { bufnr = bufnr, line = lnum }
      end
    end
  end
  return ok
end

--- File system pass for obtaining changes.
--- @param bufnr integer The buffer to check for changes.
function H.dir_changes_fs(bufnr)
  for _, id in ipairs(vim.b[bufnr].fex_visible) do
    local node = fs.get(id) --[[@as Fs.Node]]
    local path = node.path .. (node.type == "directory" and "/" or "")
    if not H.changes[id] or not H.changes[id][path] then
      if not H.changes[-1] then
        H.changes[-1] = {}
      end
      H.changes[-1][path] = true
    elseif H.changes[id][path] then
      H.changes[id][path] = nil
      if next(H.changes[id]) == nil then
        H.changes[id] = nil
      end
    end
  end
end

--- Gets all changes in all fex buffers. Returns false when there are errors.
--- @return boolean success
function H.get_changes()
  H.changes = {}
  H.targets = {}
  local ok = true
  for bufnr in pairs(H.buffers) do
    ok = ok and H.dir_changes_buf(bufnr)
  end
  if not ok then return false end
  for bufnr in pairs(H.buffers) do
    H.dir_changes_fs(bufnr)
  end
  return true
end

--- Asks the user to confirm the changes that are noted in a fex buffer before
--- committing those changes.
--- @return boolean confirmed
function H.confirm_changes()
  local msg = "Commit changes to file system?\n"
  for id, paths in pairs(H.changes) do
    local str = ""
    for path in pairs(paths) do
      str = str .. "\n" .. vim.fn.fnamemodify(path, ":~:.")
    end
    if id == -1 then
      str = str:gsub("\n", "\nrm ")
    elseif id == 0 then
      str = str:gsub("\n", "\ntouch ")
    else
      local path = fs.get(id).path:gsub("%%", "%%%%")
      str = str:gsub("\n", "\ncp " .. vim.fn.fnamemodify(path, ":~:.") .. " ")
    end
    msg = msg .. str
  end
  return vim.fn.confirm(msg, "&yes\n&no", 2) == 1
end

--- Commits changes in fex buffers to the file system, notifies the user of any
--- errors, and then updates buffers to reflect the actual file system.
function H.commit_changes()
  local copy = vim.deepcopy(H.changes)
  local tmp = {}
  if copy[-1] then
    for fname in pairs(copy[-1]) do
      local node = fs.get(fname) --[[@as Fs.Node]]
      if copy[node.id] then
        tmp[node.id] = node:mv(vim.fn.tempname())
      else
        node:rm()
      end
    end
    copy[-1] = nil
  end
  if copy[0] then
    for fname in pairs(copy[0]) do
      if fname:match("[/\\]$") then
        fs.Directory.newp(fname)
      else
        fs.Directory.newp(fname:match("^(.*)/") or "/")
        fs.File.new(fname)
      end
    end
    copy[0] = nil
  end
  for id, paths in pairs(copy) do
    local src = tmp[id] or fs.get(id) --[[@as Fs.Node]]
    for path in pairs(paths) do
      paths[path] = nil
      if next(paths) == nil and tmp[src.id] then
        src:mv(path)
        tmp[src.id] = nil
      else
        src:cp(path)
      end
    end
  end
  for _, node in pairs(tmp) do
    node:rm()
  end
end

--- Update the contents of all fex buffers.
--- @param force? boolean Force update of modified fex buffers as well.
function M.update(force)
  for bufnr in pairs(H.buffers) do
    if force or not vim.bo[bufnr].modified then
      H.dir_update(bufnr)
    end
  end
end

--- Synchronizes all fex directory buffers with the file system.
function M.sync()
  if H.get_changes() and H.confirm_changes() then
    H.commit_changes()
    M.update(true)
  end
end

--- Options which can be used when setting up fex.
--- @class Fex.Opts
--- The default filter predicate.
--- @field filter fun(bufnr: integer, child: Fs.Node)
--- The default sort predicate.
--- @field sort fun(bufnr: integer, first: Fs.Node, second: Fs.Node)

--- Sets up the fex module.
--- @param opts? Fex.Opts User options.
function M.setup(opts)
  opts = opts or {}

  keys.add("fex", { {
    "<CR>",
    function()
      local line = vim.api.nvim_get_current_line()
      if line:sub(1, 1) == "/" then
        local name = line:match("^/[%da-f]+\t(.+)$")
        if not name then
          vim.notify("fex: cannot open malformed file entry: " .. line, vim.log.levels.ERROR, {})
        else
          local path = fs.path(vim.api.nvim_buf_get_name(0), name)
          vim.cmd.edit(path)
        end
      else
        vim.cmd.edit(line)
      end
    end,
    desc = "Open the item under the cursor."
  }, {
    "gh",
    function()
      vim.b.fex_hide = not vim.b.fex_hide
      local bufnr = vim.api.nvim_get_current_buf()
      H.dir_set_lines(bufnr)
      H.dir_set_marks(bufnr)
    end,
    desc = "Toggle hidden files in fex buffer."
  } })

  vim.api.nvim_create_autocmd("BufNew", {
    desc = "Set up fex buffers when they are opened.",
    group = H.augroup,
    callback = function(e)
      --- @diagnostic disable-next-line: undefined-field
      local stat = vim.loop.fs_stat(e.file)
      if not stat or stat.type ~= "directory" then return end
      H.dir_setup(e.buf)
    end,
  })
  vim.api.nvim_create_autocmd("VimEnter", {
    desc = "Bind fex buffers after vim startup.",
    group = H.augroup,
    once = true,
    callback = function()
      local buffers = vim.api.nvim_list_bufs()
      for _, bufnr in ipairs(buffers) do
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        --- @diagnostic disable-next-line: undefined-field
        local stat = vim.loop.fs_stat(bufname)
        if not stat or stat.type ~= "directory" then return end
        H.dir_setup(bufnr)
        H.dir_update(bufnr)
        H.winenter(bufnr)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    desc = "Reset window options when leaving a fex buffer.",
    group = H.augroup,
    callback = function(e)
      if vim.bo.filetype == "fex" then
        H.winenter(e.buf)
      else
        if vim.w.cole then
          vim.wo.cole = vim.w.cole
          vim.w.cole = nil
        end
        if vim.w.cocu then
          vim.wo.cocu = vim.w.cocu
          vim.w.concu = nil
        end
      end
    end,
  })
end

return M
