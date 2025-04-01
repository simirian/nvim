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
