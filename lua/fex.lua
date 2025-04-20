-- simirian's NeoVim
-- file explorer

local icons = require("icons")
local keys = require("keymaps")
local fcache = require("fcache")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwplugin = 1

local M = {}
local H = {}

H.augroup = vim.api.nvim_create_augroup("fex", { clear = true })
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

--- Filters the children of a fex buffer.
--- @param bufnr integer The buffer to filter the children of.
--- @param children FileData[] The children to be filtered.
--- @return FileData[] children
function H.filter_children(bufnr, children)
  return vim.tbl_filter(function(child) return M.filter(bufnr, child) end, children)
end

--- Sorts the children of a fex buffer.
--- @param bufnr integer The buffer to sort the children of.
--- @param children FileData[] The children to sort.
--- @return FileData[] children
function H.sort_children(bufnr, children)
  local copy = vim.deepcopy(children)
  table.sort(copy, function(first, second) return M.sort(bufnr, first, second) end)
  return copy
end

--- BufReadCmd autocommand callback.
--- @param bufnr integer The buffer to read into.
function H.read(bufnr)
  fcache.update(vim.api.nvim_buf_get_name(bufnr))
  H.dir_set_lines(bufnr)
  H.dir_set_marks(bufnr)
end

--- BufWinEnter autocommand callback.
--- @param bufnr integer The buffer enting a window.
function H.winenter(bufnr)
  for _, winid in ipairs(vim.fn.getbufinfo(bufnr)[1].windows) do
    if vim.wo[winid].conceallevel ~= 2 then
      vim.w[winid].cole = vim.wo[winid].conceallevel
      vim.wo[winid].conceallevel = 2
    end
    if vim.wo[winid].concealcursor ~= "nvic" then
      vim.w[winid].cocu = vim.wo[winid].concealcursor
      vim.wo[winid].concealcursor = "nvic"
    end
  end
end

--- Sets up a fex directory buffer.
--- @param bufnr integer The buffer to set up.
function H.dir_setup(bufnr)
  vim.api.nvim_create_autocmd("BufReadCmd", {
    desc = "Update fex directory buffers on read.",
    group = H.augroup,
    buffer = bufnr,
    callback = function() H.read(bufnr) end
  })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    desc = "Sync fex directory buffers on write.",
    group = H.augroup,
    buffer = bufnr,
    callback = M.sync,
  })
  keys.bind("fex", bufnr)
  H.buffers[bufnr] = true
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "fex"
end

--- Sets the lines in a fex buffer according to the cached children.
--- @param bufnr integer The fex buffer to update the content of.
function H.dir_set_lines(bufnr)
  local dir = fcache.get(vim.api.nvim_buf_get_name(bufnr)) --[[@as FileData]]
  local visible = H.sort_children(bufnr, H.filter_children(bufnr, dir.children))
  vim.b[bufnr].fex_visible = visible
  local lines = {}
  local idwidth = math.max(("%x"):format(fcache.nextid() - 1):len(), 4)
  for i, child in ipairs(visible) do
    local id = ("%0" .. idwidth .. "x"):format(child.id)
    lines[i] = ("/%s %s"):format(id, child.path:match("[^/]*$"))
    if child.type == "directory" then
      lines[i] = lines[i] .. "/"
    end
  end
  local oldul = vim.bo[bufnr].undolevels
  vim.bo[bufnr].undolevels = -1
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].undolevels = oldul
  vim.bo[bufnr].modified = false
end

H.namespace = vim.api.nvim_create_namespace("fex")

--- Sets the extmarks to show file type icons in the fex buffer.
--- @param bufnr integer The buffer to set marks in.
function H.dir_set_marks(bufnr)
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:sub(1, 1) == "/" then
      local sepidx = line:find(" ")
      local id = sepidx and tonumber(line:sub(2, sepidx - 1), 16)
      if id then
        local fdata = fcache.get(id)
        local hl, icon, icohl
        if fdata.type == "directory" then
          hl = "Directory"
          icon = icons.files.directory
          icohl = "Directory"
        elseif fdata.type == "link" then
          icon = icons.files.link
          icohl = "Normal"
        else
          --- @diagnostic disable-next-line: need-check-nil this should probably actually be handled
          icon, icohl = H.icon(fdata.path:match("[^/]*$"))
          if not icon then
            icon = icons.files.file
            icohl = "Normal"
          end
        end
        vim.api.nvim_buf_set_extmark(bufnr, H.namespace, lnum - 1, 0, {
          end_col = sepidx,
          virt_text = { { icon .. " ", icohl } },
          virt_text_pos = "inline",
          invalidate = true,
          line_hl_group = hl,
          conceal = "",
        })
      end
    end
  end
end

--- Map from source ids to a set of paths. An id of 0 indicates a new file, and
--- an id of -1 indicates deleted files
--- @type table<integer, table<string, true>>
H.changes = {}

--- Map from targets to their status.
--- @type table<string, "found"|"error">
H.targets = {}

--- Gets the changes in a buffer and returns true if there were no errors.
--- @param bufnr integer The fex buffer to get changes from.
--- @return boolean success
function H.dir_get_changes(bufnr)
  if not vim.bo[bufnr].modified then return true end
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local ok = true
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for lnum, line in ipairs(lines) do
    line = line:match("^%s*(.-)%s*$")
    local id, target = 0, line
    if line:sub(1, 1) == "/" then
      id, target = line:match("^/([%da-f]+)%s+(.+)$")
      id = tonumber(id, 16)
    end
    if line == "" and #lines > 1 then
      vim.notify("empty line: " .. bufnr .. ":" .. lnum, vim.log.levels.WARN, {})
    elseif not id or not target then
      vim.notify("malformed line: " .. line, vim.log.levels.ERROR, {})
      ok = false
    else
      target = fcache.path(bufname, target) .. target:match("/?$")
      if H.targets[target] then
        if H.targets[target] == "found" then
          vim.notify("multiply defined target: " .. target, vim.log.levels.ERROR, {})
          H.targets[target] = "error"
        end
        ok = false
      else
        if not H.changes[id] then
          H.changes[id] = {}
        end
        H.changes[id][target] = true
        H.targets[target] = "found"
      end
    end
  end
  if not ok then return ok end
  for _, child in ipairs(vim.b[bufnr].fex_visible) do
    if not H.changes[child.id] or not H.changes[child.id][child.path] then
      if not H.changes[-1] then
        H.changes[-1] = {}
      end
      H.changes[-1][child.path] = true
    elseif H.changes[child.id][child.path] then
      H.changes[child.id][child.path] = nil
      if next(H.changes[child.id]) == nil then
        H.changes[child.id] = nil
      end
    end
  end
  return ok
end

--- Gets all changes in all fex buffers. Returns false when there are errors.
--- @return boolean success
function H.get_changes()
  H.changes = {}
  H.targets = {}
  local ok = true
  for bufnr in pairs(H.buffers) do
    ok = ok and H.dir_get_changes(bufnr)
  end
  return ok
end

--- Asks the user to confirm the changes that are noted in a fex buffer before
--- committing those changes.
--- @return boolean confirmed
function H.confirm_changes()
  local msg = "Commit changes to file system?\n"
  for id, paths in pairs(H.changes) do
    if id == -1 then
      msg = msg .. "//rm"
    elseif id == 0 then
      msg = msg .. "//touch"
    else
      msg = msg .. vim.fn.fnamemodify(fcache.get(id).path, ":~:.") .. ""
    end
    local str = ""
    for path in pairs(paths) do
      str = str .. "\n" .. vim.fn.fnamemodify(path, ":~:.")
    end
    msg = msg .. str:gsub("\n", "\n  ") .. "\n"
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
      local id = fcache.get(fname).id
      if copy[id] then
        tmp[id] = vim.fn.tempname()
        fcache.mv(fname, tmp[id])
      else
        fcache.rm(fname)
      end
    end
    copy[-1] = nil
  end
  if copy[0] then
    for fname in pairs(copy[0]) do
      fcache.mk(fname)
    end
    copy[0] = nil
  end
  for id, paths in pairs(copy) do
    local fname = tmp[id] or fcache.get(id).path
    for path in pairs(paths) do
      fcache.cp(fname, path)
    end
  end
  for _, file in pairs(tmp) do
    fcache.rm(file)
  end
end

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
    local oldbuf = vim.api.nvim_get_current_buf()
    for _, bufnr in ipairs(buffers) do
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      --- @diagnostic disable-next-line: undefined-field
      local stat = vim.loop.fs_stat(bufname)
      if not stat or stat.type ~= "directory" then return end
      H.dir_setup(bufnr)
      H.read(bufnr)
      H.winenter(bufnr)
    end
    vim.cmd.buffer(oldbuf)
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
        vim.wo.conceallevel = vim.w.cole
        vim.w.cole = nil
      end
      if vim.w.cocu then
        vim.wo.concealcursor = vim.w.cocu
        vim.w.concu = nil
      end
    end
  end,
})

--- The function used to filter children that get displayed in fex buffers.
--- Should return true if the child should be displayed.
--- @param bufnr integer The buffer to fileter the children of.
--- @param child FileData The child that might need to be included.
--- @return boolean include
function M.filter(bufnr, child)
  return not vim.b[bufnr].fex_hide or child.path:match("[^/]*$"):sub(1, 1) ~= "."
end

--- The function used to sort children that get displayed in fex buffers.
--- Return true if first should come before second.
--- @param bufnr integer The buffer whose children are being sorted.
--- @param first FileData The candidate for first in the list.
--- @param second FileData The candidate for second in the list.
--- @return boolean correct
function M.sort(bufnr, first, second) --- @diagnostic disable-line: unused-local
  local fetype = first.type
  if fetype == "link" then
    if not first.target then
      first = fcache.update(first.id) --[[@as FileData]]
    end
    fetype = first.target.type
  end
  local setype = second.type
  if setype == "link" then
    if not second.target then
      second = fcache.update(second.id) --[[@as FileData]]
    end
    setype = second.target.type
  end
  if fetype == "directory" and setype ~= "directory" then
    return true
  elseif fetype ~= "directory" and setype == "directory" then
    return false
  end
  local fname, sname = first.path:match("[^/]*$"), second.path:match("[^/]*$")
  return fname < sname
end

--- Update the contents of all fex buffers.
--- @param force? boolean Force update of modified fex buffers as well.
function M.update(force)
  for bufnr in pairs(H.buffers) do
    if force or not vim.bo[bufnr].modified then
      H.read(bufnr)
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

keys.add("fex", {
  {
    "<CR>",
    function()
      local line = vim.api.nvim_get_current_line()
      if line:sub(1, 1) == "/" then
        local name = line:match("^/[%da-f]+ (.+)$")
        if not name then
          print("fex: malformed file entry", line)
        else
          local path = fcache.path(vim.api.nvim_buf_get_name(0), name)
          vim.cmd.edit(path)
        end
      else
        print("fex: file does not exist yet", line)
      end
    end,
    desc = "Open the item under the cursor."
  },
  {
    "<C-h>",
    function()
      vim.b.fex_hide = not vim.b.fex_hide
      H.read(vim.api.nvim_get_current_buf())
    end,
    desc = "Toggle hidden files in fex buffer."
  }
})

return M
