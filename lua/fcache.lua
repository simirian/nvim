-- simirian's NeoVim
-- file system data cache

local M = {}
local H = {}

--- Cache object for file data.
--- @class FileData
--- The full path to the file.
--- @field path string
--- The id of the child.
--- @field id integer
--- The type of the file, or nil if the file does not exist.
--- @field type? "file"|"directory"|"link"|"fifo"|"socket"|"char"|"block"|"unknown"
--- The children of the file if it is a directory.
--- @field children? FileData[]
--- Target of this file if it is a link.
--- @field target? FileData

--- The id of the next path to be added to the id registry.
--- @type integer
H.nextid = 1

--- Table of file ids to the data related to those files.
--- @type table<integer, FileData>
H.fdata = {}

--- Table of file paths to ids.
--- @type table<integer, string>
H.pathid = {}

--- Gets the id for a normalized path, or creates a new id entry for that path
--- if there isn't one already.
--- @param path string The path to get the id of.
--- @return integer id
function H.get_id(path)
  if not H.pathid[path] then
    H.pathid[path] = H.nextid
    H.nextid = H.nextid + 1
  end
  return H.pathid[path]
end

--- Updates a directory with a new list of children.
--- @param dir FileData The directory to update.
--- @param recurse? boolean If the update should be recursive or not.
--- @return FileData directory
function H.dir_update(dir, recurse)
  dir.children = {}
  for name, type in vim.fs.dir(dir.path) do
    if recurse then
      table.insert(dir.children, M.update(M.path(dir.path, name), recurse))
    else
      local childpath = M.path(dir.path, name)
      local childid = H.get_id(childpath)
      H.fdata[childid] = {
        path = childpath,
        id = childid,
        type = type,
      }
      table.insert(dir.children, H.fdata[childid])
    end
  end
  return dir
end

--- Updates a link's target.
--- @param link FileData THe link object to update.
--- @param recurse? boolean If the update should be recursive or not.
--- @return FileData link
function H.link_update(link, recurse)
  if recurse then
    --- @diagnostic disable-next-line: undefined-field
    link.target = M.update(vim.loop.fs_realpath(link.path), recurse)
  else
    --- @diagnostic disable-next-line: undefined-field
    local targetpath = M.path(vim.loop.fs_realpath(link.path))
    local targetid = H.get_id(targetpath)
    --- @diagnostic disable-next-line: undefined-field
    local stat = vim.loop.fs_stat(targetpath)
    H.fdata[targetid] = {
      path = targetpath,
      id = targetid,
      type = stat.type,
    }
    link.target = H.fdata[targetid]
  end
  return link
end

--- Synchronously creates a directory at the given path, creating parent
--- directories as needed.
--- @param path string The path to the directory.
function H.mkdirp(path)
  local parent = path:match("^(.*/).+")
  if not parent then
    --- @diagnostic disable-next-line: undefined-field
    parent = vim.loop.cwd()
  end
  --- @diagnostic disable-next-line: undefined-field
  if not vim.loop.fs_stat(parent) then
    M.mkdirp(parent)
  end
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_mkdir(path, 493)
end

--- Recursively copies a file or directory from src to dst.
--- @param src string The path to the file to copy.
--- @param dst string The path to where the file should be copied to.
function M.cp(src, dst)
  local function copy(csrc, cdst, ctype)
    if ctype == "directory" then
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_mkdir(cdst, 493)
      for name, type in vim.fs.dir(csrc) do
        copy(fcache.path(csrc, name), fcache.path(cdst, name), type)
      end
    elseif ctype == "link" then
      --- @diagnostic disable-next-line: undefined-field
      local target = vim.loop.fs_readlink(csrc)
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_symlink(target, cdst)
    else
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_copyfile(csrc, cdst)
    end
  end
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_lstat(src, function(err, stat)
    if err then return end
    local parent = dst:match("^(.*/).+")
    if not parent then
      --- @diagnostic disable-next-line: undefined-field
      parent = vim.loop.cwd()
    end
    --- @diagnostic disable-next-line: undefined-field
    if not vim.loop.fs_stat(parent) then
      M.mkdirp(parent)
    end
    copy(src, dst, stat.type)
  end)
end

--- Moves a file or directory from src to dst.
--- @param src string The source path.
--- @param dst string The destination path.
function M.mv(src, dst)
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_stat(src, function(err)
    if err then return end
    local parent = dst:match("^(.*/).+")
    if not parent then
      --- @diagnostic disable-next-line: undefined-field
      parent = vim.loop.cwd()
    end
    --- @diagnostic disable-next-line: undefined-field
    if not vim.loop.fs_stat(parent) then
      M.mkdirp(parent)
    end
    --- @diagnostic disable-next-line: undefined-field
    vim.loop.fs_rename(src, dst)
  end)
end

--- Creates a new file system entry based on the given path. A trailing / will
--- cause a directory to be created instead of a file. Will create parent
--- directories as needed.
--- @param path string The path to create the item at.
function M.mk(path)
  local parent = path:match("^(.*/).+")
  if not parent then
    --- @diagnostic disable-next-line: undefined-field
    parent = vim.loop.cwd()
  end
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_stat(parent, function(err)
    if err then
      M.mkdirp(parent)
    end
    if path:sub(#path) == "/" then
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_mkdir(path, 493)
    else
      --- @diagnostic disable-next-line: undefined-field
      local fd = vim.loop.fs_open(path, "a", 420)
      if fd then
        --- @diagnostic disable-next-line: undefined-field
        vim.loop.fs_close(fd)
      end
    end
  end)
end

--- Recursively removes the item at the specified path.
--- @param path string The path to the file system entry to remove.
function M.rm(path)
  local function remove(rpath, rtype)
    if rtype == "directory" then
      for name, type in vim.fs.dir(rpath) do
        remove(fcache.path(rpath, name), type)
      end
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_rmdir(rpath)
    else
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_unlink(rpath)
    end
  end
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_stat(path, function(err, stat)
    if err then return end
    remove(path, stat.type)
  end)
end


--- Joins and normalizes a path.
--- @param start string The first section of the path.
--- @param ... string Additional path segments to be added after the first.
--- @return string path
function M.path(start, ...)
  start = vim.fn.fnamemodify(start, ":p")
  return vim.fs.normalize(vim.fs.joinpath(start, ...))
end

--- Gets the next id that will be used when getting or updating a file path that
--- isn't cached.
--- @return integer id
function M.nextid()
  return H.nextid
end

--- Gets the FileData associated with the named path, if it exists.
--- @param file integer|string The id or path to get data for.
--- @return FileData? file
function M.get(file)
  if type(file) == "string" then
    return H.fdata[H.pathid[M.path(file)]]
  elseif type(file) == "number" then
    return H.fdata[file]
  end
end

--- Creates or updates the recorded entry for the path.
--- @param file string|integer The id or path to update.
--- @param recurse? boolean If the update should be recursive or not.
--- @return FileData? file
function M.update(file, recurse)
  local path, id, stat
  if type(file) == "string" then
    path = M.path(file)
    id = H.get_id(path)
    --- @diagnostic disable-next-line: undefined-field
    stat = vim.loop.fs_lstat(path)
  elseif type(file) == "number" then
    id = file
    if not H.fdata[id] then return end
    path = H.fdata[id].path
    --- @diagnostic disable-next-line: undefined-field
    stat = vim.loop.fs_lstat(path)
  end
  stat = stat or {}
  H.fdata[id] = {
    path = path,
    id = id,
    type = stat.type,
  }
  if stat.type == "directory" then
    H.dir_update(H.fdata[id], recurse)
  elseif stat.type == "link" then
    H.link_update(H.fdata[id], recurse)
  end
  return H.fdata[id]
end

return M
