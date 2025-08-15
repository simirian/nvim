-- simirian's Neovim
-- file explorer

-- Credit where it's due, this plugin was heavily inspired by peer plugins like
-- dirbuf and oil. It just aims to be smaller and perhaps a little simpler.

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--- Creates a file or directory if the path ends in '/'. The path must not yet
--- exist. Parent directories will be created as needed.
--- @param path string The path to create.
local function mk(path)
  local parent = vim.fs.normalize(path):match(".*/")
  --- @diagnostic disable-next-line: undefined-field
  if not vim.loop.fs_stat(parent) then
    local _, err = mk(parent .. "/")
    assert(not err, err)
  end
  if path:sub(#path) == "/" then
    --- @diagnostic disable-next-line: undefined-field
    return vim.loop.fs_mkdir(path, 493) -- 755
  else
    --- @diagnostic disable-next-line: undefined-field
    local f, err = vim.loop.fs_open(path, "a", 420) -- 644
    assert(not err, err)
    --- @diagnostic disable-next-line: undefined-field
    _, err = vim.loop.fs_close(f)
    assert(not err, err)
  end
end

--- Copies a source file or directory to a destination. The destination must not
--- yet exist. Parent directories will be created as needed.
--- @param src string Location of the source to be copied.
--- @param dst string Location to place  acopy of the source.
local function cp(src, dst)
  local parent = vim.fs.normalize(dst):match(".*/")
  --- @diagnostic disable-next-line: undefined-field
  if not vim.loop.fs_stat(parent) then
    local _, err = mk(parent .. "/")
    assert(not err, err)
  end
  local function cp(src, dst, type) --- @diagnostic disable-line: redefined-local
    if type == "file" then
      --- @diagnostic disable-next-line: undefined-field
      local _, err = vim.loop.fs_copyfile(src, dst)
      assert(not err, err)
    elseif type == "directory" then
      --- @diagnostic disable-next-line: undefined-field
      local _, err = vim.loop.fs_mkdir(dst, 493)
      assert(not err, err)
      for fname, ftype in vim.fs.dir(src) do
        cp(src .. "/" .. fname, dst .. "/" .. fname, ftype)
      end
    elseif type == "link" then
      --- @diagnostic disable-next-line: undefined-field
      local target, err = vim.loop.fs_readlink(src)
      assert(not err, err)
      --- @diagnostic disable-next-line: undefined-field
      _, err = vim.loop.fs_symlink(target, dst)
      assert(not err, err)
    end
  end
  --- @diagnostic disable-next-line: undefined-field
  local stat, err = vim.loop.fs_lstat(src)
  assert(not err, err)
  cp(src, dst, stat.type)
end

--- Moves a source file to the destination location. The destination must not
--- yet exist. Parent directories will be created as needed.
--- @param src string Location of the source to be moved.
--- @param dst string Location to move the source to.
local function mv(src, dst)
  local parent = vim.fs.normalize(dst):match(".*/")
  --- @diagnostic disable-next-line: undefined-field
  if not vim.loop.fs_stat(parent) then
    local _, err = mk(parent .. "/")
    assert(not err, err)
  end
  --- @diagnostic disable-next-line: undefined-field
  local _, err = vim.loop.fs_rename(src, dst)
  assert(not err, err)
end

--- Removes a file at the given path from the file ssytem.
--- @param path string The path to be removed.
local function rm(path)
  local function rm(path, type) --- @diagnostic disable-line: redefined-local
    if type == "directory" then
      for fname, ftype in vim.fs.dir(path) do
        rm(path .. "/" .. fname, ftype)
      end
      --- @diagnostic disable-next-line: undefined-field
      local _, err = vim.loop.fs_rmdir(path)
      assert(not err, err)
    else
      --- @diagnostic disable-next-line: undefined-field
      local _, err = vim.loop.fs_unlink(path)
      assert(not err, err)
    end
  end
  --- @diagnostic disable-next-line: undefined-field
  local stat, err = vim.loop.fs_stat(path)
  assert(not err, err)
  rm(path, stat.type)
end

--- Map from ids to names.
--- @type table<integer, string>
local names = {}

--- Map from names to ids.
--- @type table<string, integer>
local ids = {}

--- Keeps track of the next free id.
--- @type integer
local nextid = 1

--- Swaps betwen a file's name and id.
--- @param item string|integer The item to swap.
--- @return string|integer
local function swapnameid(item)
  if type(item) == "number" then
    return names[item]
  elseif ids[item] then
    return ids[item]
  else
    names[nextid] = item --[[@as string]]
    ids[item] = nextid
    nextid = nextid + 1
    return nextid - 1
  end
end

local augroup = vim.api.nvim_create_augroup("fex", { clear = true })
local ns = vim.api.nvim_create_namespace("fex")

--- Updates a fex directory buffer.
--- @param bufnr integer The buffer to update.
local function dir_update(bufnr)
  local children = {}
  -- get and filter children
  for name, type in vim.fs.dir(vim.api.nvim_buf_get_name(bufnr)) do
    if vim.b[bufnr].fex_showhidden or not name:match("^%.") then
      table.insert(children, { name = name, type = type })
    end
  end
  -- sort children
  table.sort(children, function(first, second)
    if first.type == "directory" and second.type ~= "directory" then
      return true
    elseif first.type ~= "directory" and second.type == "directory" then
      return false
    end
    return first.name < second.name
  end)
  vim.b[bufnr].fex_visible = children
  -- make lines
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local lines = vim.tbl_map(function(child)
    local path = vim.fs.normalize(bufname .. "/" .. child.name)
    return ("/%x\t%s"):format(swapnameid(path), child.name)
  end, children)
  -- set lines
  local ul = vim.bo[bufnr].ul
  vim.bo[bufnr].ul = -1
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].ul = ul
  vim.bo[bufnr].modified = false
  -- set marks
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for i, line in ipairs(lines) do
    local ico, hl
    if children[i].type == "directory" then
      ico, hl = "", "Directory"
    else
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if ok then
        local name = line:match("\t(.*)")
        ico, hl = devicons.get_icon(name, name:match("[^.]+$"))
      end
    end
    vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
      virt_text = { { (ico or "") .. " ", hl or "FileKind" } }, -- TODO: fix highlight, icons module?
      virt_text_pos = "inline",
      line_hl_group = children[i].type == "directory" and "Directory" or nil,
      end_col = line:find("\t", 1, false) - 1,
      conceal = "",
    })
  end
end

--- Map from source ids to a set of destinations. An id of 0 indicates that a
--- file is completely new.
--- @type table<integer, table<string, true>>
local changes = {}

--- Map from target names to the number of times that target has been specified.
--- @type table<string, integer>
local targets = {}

--- Adds all files in a fex buffer to the changes listing.
--- @param bufnr integer The buffer to get the changes of.
--- @return boolean ok
local function dir_addchanges(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local ok = true
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if not line:match("^%s*$") then
      local id, name = 0, line
      if line:sub(1, 1) == "/" then
        id, name = line:match("^/([%da-f]*)\t(.*)$")
        id = tonumber(id or "", 16)
      end
      if id and name then
        changes[id] = changes[id] or {}
        name = vim.fs.normalize(bufname .. "/" .. name)
        changes[id][name] = true
        targets[name] = targets[name] and targets[name] + 1 or 1
      else
        vim.notify("FEXE1: Malformed line in fex buffer " .. bufname .. ":\n  " .. line .. "'", vim.log.levels.ERROR, {})
        ok = false
      end
    end
  end
  for _, child in ipairs(vim.b[bufnr].fex_visible) do
    local id = swapnameid(vim.fs.normalize(bufname .. "/" .. child.name))
    changes[id] = changes[id] or {}
  end
  return ok
end

--- Checks if the changes the user has made to fex buffers are all valid.
--- @return boolean valid
local function validate()
  local valid = true
  local msg = ""
  -- ensure no sources are within another source
  local srcnames = {}
  for srcid, dstset in pairs(changes) do
    if srcid ~= 0 then
      local src = swapnameid(srcid)
      local t1 = next(dstset) -- if this isn't the name then there was a move/delete
      local t2 = next(dstset, t1) -- if this exists then there there was a copy
      if t2 or t1 ~= src then
        table.insert(srcnames, src)
      end
    end
  end
  for i, src in ipairs(srcnames) do
    for j, subsrc in ipairs(srcnames) do
      if i ~= j and subsrc:find(src .. "/", 1, true) then
        msg = msg .. "FEXE2: Modified child of modified directory:\n"
            .. ("     %s\n  in %s\n"):format(subsrc, src)
        valid = false
      end
    end
  end
  -- ensure all sources actually exist
  for _, src in ipairs(srcnames) do
    --- @diagnostic disable-next-line: undefined-field
    local _, err = vim.loop.fs_stat(src)
    if err then
      msg = ("%sFEXE3: Error accessing file %s:\n  %s\n"):format(msg, src, err)
      valid = false
    end
  end
  -- ensure no target is specified twice
  for target, count in pairs(targets) do
    if count > 1 then
      msg = ("%sFEXE4: Multiply defined target:\n  %s\n"):format(msg, target)
      valid = false
    end
  end
  if not valid then
    vim.notify(msg, vim.log.levels.ERROR, {})
  end
  return valid
end

--- Confirms the changes to be made with the user.
--- @return boolean confirmed
local function confirm()
  local msg = "Commit these changes to the file system?\n"
  for srcid, dstset in pairs(changes) do
    if srcid == 0 then
      for dst in pairs(dstset) do
        msg = ("%smk %s\n"):format(msg, dst)
      end
    else
      local src = swapnameid(srcid)
      local copy = vim.deepcopy(dstset)
      local keep = copy[src] or false
      copy[src] = nil
      local strs = {}
      for dst in pairs(copy) do
        if keep or next(copy, dst) then
          table.insert(strs, ("cp %s %s\n"):format(src, dst))
        else
          table.insert(strs, ("mv %s %s\n"):format(src, dst))
        end
      end
      if not next(strs) and not keep then
        table.insert(strs,("rm %s\n"):format(src))
      end
      msg = msg .. table.concat(strs)
    end
  end
  return vim.fn.confirm(msg, "Yes\nNo", 2) == 1
end

--- Commits changes to the file system.
local function commit()
  local fnames = {}
  for srcid, dstset in pairs(changes) do
    if srcid ~= 0 then
      local src = swapnameid(srcid) --[[@as string]]
      if next(dstset) then
        if targets[src] and not dstset[src] then
          fnames[srcid] = os.tmpname()
          mv(src, fnames[srcid])
        else
          fnames[srcid] = src
        end
      else
        rm(src)
        changes[srcid] = nil
      end
    end
  end
  for srcid, dstset in pairs(changes) do
    if srcid == 0 then
      for dst in pairs(dstset) do
        mk(dst)
      end
    else
      local src = fnames[srcid]
      local keep = dstset[src] or false
      dstset[src] = nil
      for dst in pairs(dstset) do
        if keep or next(dstset, dst) then
          cp(src, dst)
        else
          mv(src, dst)
        end
      end
    end
  end
end

--- Tries to update the file system based on the contents of fex buffers.
local function sync()
  changes = {}
  targets = {}
  local fexbufs = {}
  local ok = true
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.b[bufnr].fex_visible then
      if not dir_addchanges(bufnr) then
        ok = false
      end
      fexbufs[bufnr] = true
    end
  end
  if not ok then return end
  if validate() and confirm() then
    commit()
    for bufnr in pairs(fexbufs) do
      dir_update(bufnr)
    end
  end
end

--- Tests if a buffer is a directory.
--- @param bufnr integer The buffer to test.
--- @return boolean
local function test(bufnr)
  --- @diagnostic disable-next-line: undefined-field
  local stat = vim.loop.fs_stat(vim.api.nvim_buf_get_name(bufnr))
  return stat and stat.type == "directory"
end

--- Sets up a fex buffer.
local function dir_setup(bufnr)
  vim.api.nvim_create_autocmd("BufReadCmd", {
    desc = "Update fex directory buffers on read.",
    group = augroup,
    buffer = bufnr,
    callback = function() dir_update(bufnr) end,
  })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    desc = "Sync fex directories on write.",
    group = augroup,
    buffer = bufnr,
    callback = sync,
  })
  vim.keymap.set("", "<cr>", function()
    local line = vim.api.nvim_get_current_line()
    local name = line:sub(1, 1) == "/" and line:match("\t(.*)") or line
    if not name or name:match("^%s*$") then
      vim.notify("fex: cannot open file", vim.log.levels.ERROR, {})
      return
    end
    local path = vim.fs.normalize(vim.api.nvim_buf_get_name(0) .. "/" .. name)
    --- @diagnostic disable-next-line: undefined-field
    vim.loop.fs_lstat(path, function(_, stat)
      if stat and stat.type == "link" then
        --- @diagnostic disable-next-line: undefined-field
        vim.loop.fs_realpath(path, function(err, realpath)
          assert(not err, err)
          vim.schedule(function() vim.cmd.edit(realpath) end)
        end)
      else
        vim.schedule(function() vim.cmd.edit(path) end)
      end
    end)
  end, { desc = "Open the item under the cursor.", buffer = bufnr })
  vim.keymap.set("", "gh", function()
    vim.b[bufnr].fex_showhidden = not vim.b[bufnr].fex_showhidden
    dir_update(bufnr)
  end, { desc = "Toggle hidden files in fex buffer.", buffer = bufnr })
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].tabstop = 8
  vim.bo[bufnr].filetype = "fex"
  dir_update(bufnr)
end

--- Updates the cursor position in a fex buffer to the start of the file name.
--- @param winnr integer The window to update the cursor of.
local function fixcurpos(winnr)
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local curpos = vim.api.nvim_win_get_cursor(winnr)
  local line = vim.api.nvim_buf_get_lines(bufnr, curpos[1] - 1, curpos[1], false)[1]
  local _, col = line:find("\t", 1, true)
  vim.api.nvim_win_set_cursor(winnr, { curpos[1], col or 0 })
end

--- Sets the conceal properties for a window with a fex buffer.
--- @param winnr integer The window to apply settings to.
local function setconceal(winnr)
  if vim.wo[winnr].cole ~= 3 then
    vim.w[winnr].cole = vim.wo[winnr].cole
    vim.wo[winnr].cole = 3
  end
  if vim.wo[winnr].cocu ~= "nvic" then
    vim.w[winnr].cocu = vim.wo[winnr].cocu
    vim.wo[winnr].cocu = "nvic"
  end
end

--- Unsets the conceal properties for a window with a fex buffer.
--- @param winnr integer The window to apply settings to.
local function unsetconceal(winnr)
  if vim.w[winnr].cole then
    vim.wo[winnr].cole = vim.w[winnr].cole
    vim.w[winnr].cole = nil
  end
  if vim.w[winnr].cocu then
    vim.wo[winnr].cocu = vim.w[winnr].cocu
    vim.w[winnr].cocu = nil
  end
end

vim.api.nvim_create_autocmd("BufNew", {
  desc = "Set up fex buffers when they are opened.",
  group = augroup,
  callback = function(e)
    if test(e.buf) then
      dir_setup(e.buf)
    end
  end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Bind fex buffers after vim startup.",
  group = augroup,
  once = true,
  callback = function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if test(bufnr) then
        dir_setup(bufnr)
      end
    end
    for _, winnr in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(winnr)].ft == "fex" then
        setconceal(winnr)
        fixcurpos(winnr)
      end
    end
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Conceal in fex buffers.",
  group = augroup,
  callback = function()
    if vim.bo.ft == "fex" then
      setconceal(0)
      fixcurpos(0)
    else
      unsetconceal(0)
    end
  end,
})
