-- simirian's NeoVim
-- file system data cache

local M = {}
local H = {}

--- Cached file system data.
--- @type table<integer, Fs.Node>
H.cache = {}

--- Ids for cached paths
--- @type table<string, integer>
H.ids = {}

--- The numer of cached entries, used to make ids for new entries.
--- @type integer
H.ncached = 0

--- Sets a node's data to indicate that it does not exist on the file system.
--- @param node Fs.Node The node to mark as deleted.
--- @return Fs.Node node
function H.set_deleted(node)
  for k in pairs(node) do
    if k ~= "path" and k ~= "id" then
      node[k] = nil
    end
  end
  return node
end

--- Registers a node in the cache, returning that node with its id set.
--- @param node Fs.Node The node to register
--- @return Fs.Node node
function H.register(node)
  local id = H.ncached + 1
  H.ncached = id
  H.ids[node.path] = id
  H.cache[id] = node
  node.id = id
  return node
end

--- Object which represents a file on the file system. Contains stat data.
--- @class Fs.Node
--- The full path to the file.
--- @field path string
--- The id of the child.
--- @field id integer
--- The type of the file, or nil if the file does not exist.
--- @field type? "file"|"directory"|"link"|"fifo"|"socket"|"char"|"block"|"unknown"
M.Node = {}

--- Updates a node to match the current file system state. If the file no longer
--- exists then a deleted node is returned without a type.
--- @return Fs.Node node
function M.Node:update()
  --- @diagnostic disable-next-line: undefined-field
  local stat, err = vim.loop.fs_lstat(self.path)
  if err then
    H.set_deleted(self)
    return self
  end
  for k, v in pairs(stat) do
    self[k] = v
  end
  if stat.type == "directory" then
    setmetatable(self, { __index = M.Directory })
  elseif stat.type == "link" then
    setmetatable(self, { __index = M.Link })
  elseif stat.type == "file" then
    setmetatable(self, { __index = M.File })
  else
    setmetatable(self, { __index = M.Node })
  end
  return self
end

--- Removes a node from the file system. On success, returns the node without a
--- type and all keys removed to indicate that it no longer exists.
--- @return Fs.Node? node
--- @return string? err
function M.Node:rm()
  --- @diagnostic disable-next-line: undefined-field
  local _, err = vim.loop.fs_unlink(self.path)
  if err then return nil, err end
  H.set_deleted(self)
  return self
end

--- Moves a file on the file system. This function returns the node object for
--- the destination location, not the original node object.
--- @param target string The location to move this file to.
--- @return Fs.Node? new
--- @return string? error
function M.Node:mv(target)
  target = M.path(target)
  --- @diagnostic disable-next-line: undefined-field
  local _, err = vim.loop.fs_rename(self.path, target)
  if err then return nil, err end
  H.set_deleted(self)
  return M.get(target):update()
end

--- copies a file to a target location. This fucntion returns the object for the
--- new file in the target location, not the object this method was called on.
--- @param target string The location to copy this file to.
--- @return Fs.Node? new
--- @return string? error
function M.Node:cp(target)
  target = M.path(target)
  --- @diagnostic disable-next-line: undefined-field
  local _, err = vim.loop.fs_copyfile(self.path, target)
  if err then return nil, err end
  return M.get(target):update()
end

--- Object which represents a file in the file system
--- @class Fs.File: Fs.Node
--- @field type "file"
M.File = setmetatable({}, { __index = M.Node })

--- Creates a new generic file or returns the existing file.
--- @param path string The path to the new file.
--- @return Fs.File? flie
--- @return string? error
function M.File.new(path)
  path = M.path(path)
  --- @diagnostic disable-next-line: undefined-field
  local fd, err = vim.loop.fs_open(path, "a", 420)
  if err then return nil, err end
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_close(fd)
  return M.get(path) --[[@as Fs.File]], nil
end

--- Object which mirrors a directory on the file system.
--- @class Fs.Directory: Fs.Node
--- @field type "directory"
--- The children of the directory.
--- @field children Fs.Node[]
M.Directory = setmetatable({}, { __index = M.Node })

--- Creates a new directory.
--- @param path string The path to the new directory.
--- @return Fs.Directory? directory
--- @return string? error
function M.Directory.new(path)
  path = M.path(path)
  --- @diagnostic disable-next-line: undefined-field
  local _, err = vim.loop.fs_mkdir(path, 493)
  if err then return nil, err end
  return M.get(path) --[[@as Fs.Directory]], nil
end

--- Creates a new directory and all of its parents.
--- @param path string The path to the new directory.
--- @return Fs.Directory? directory
--- @return string? error
function M.Directory.newp(path)
  --- @param p string Path.
  --- @return Fs.Directory? directory
  --- @return string? error
  local function make(p)
    --- @diagnostic disable-next-line: undefined-field
    local node = M.get(p:match("^(.+)/") or "/") --[[@as Fs.Node]]
    if not node.type then
      local _, err = make(node.path)
      if err then return nil, err end
    elseif node.type ~= "directory" then
      return nil, "ENOTDIR: file is not a directory: " .. node.path
    end
    return M.Directory.new(p)
  end
  return make(M.path(path))
end

--- Removes a directory from the file system. Returns the updated node on
--- success.
--- @return Fs.Node? node
--- @return string? error
function M.Directory:rm()
  for _, child in ipairs(self:get_children()) do
    local _, err = child:rm()
    if err then return nil, err end
  end
  --- @diagnostic disable-next-line: undefined-field
  local _, err = vim.loop.fs_rmdir(self.path)
  if err then return nil, err end
  H.set_deleted(self)
  return self
end

--- Moves a directory to a new location. Returns a new onject for the directory
--- at the new location on success.
--- @pram target string The path to move the directory to.
--- @return Fs.Directory? directory
--- @return string? error
function M.Directory:mv(target)
  target = M.path(target)
  --- @diagnostic disable-next-line: undefined-field
  local _, err = vim.loop.fs_rename(self.path, target)
  if err then return nil, err end
  H.set_deleted(self)
  local node = M.get(target):update()
  return node --[[@as Fs.Directory]]
end

--- Copies a directory to a target location. Returns a new object for the
--- created directory on success.
--- @param target string The path to copy the cirectory to.
--- @return Fs.Directory? directory
--- @return string? error
function M.Directory:cp(target)
  target = M.path(target)
  if target:sub(1, #self.path + 1) == self.path .. "/" then
    local spath = vim.fs.normalize(vim.fn.fnamemodify(self.path, ":~:."))
    local tpath = vim.fs.normalize(vim.fn.fnamemodify(target, ":~:."))
    return nil, "EINVAL: invalid argument: " .. spath .. " -> " .. tpath
  end
  --- @diagnostic disable-next-line: undefined-field
  local _, err = vim.loop.fs_mkdir(target, 493)
  if err then return nil, err end
  for _, child in ipairs(self:get_children()) do
    --- @diagnostic disable-next-line: redefined-local
    local _, err = child:cp(M.path(target, child.path:match("[^/]*$")))
    if err then return nil, err end
  end
  local node = M.get(target):update()
  return node --[[@as Fs.Directory]]
end

--- Updates and returns the list of children of this directory.
--- @return Fs.Node[] children
function M.Directory:get_children()
  self.children = {}
  for name in vim.fs.dir(self.path) do
    table.insert(self.children, M.get(M.path(self.path, name)):update())
  end
  return self.children
end

--- Represents a symlink on the file system.
--- @class Fs.Link: Fs.Node
--- @field type "link"
--- The target of the link.
--- @field target? Fs.Node
M.Link = setmetatable({}, { __index = M.Node })

--- Creates a new symlink.
--- @param path string The path the link will be placed at.
--- @param target string The file the link points to.
--- @return Fs.Link? link
--- @return string? error
function M.Link.new(path, target)
  path = M.path(path)
  target = M.path(target)
  --- @diagnostic disable-next-line: undefined-field
  local _, err = vim.loop.fs_symlink(target, path)
  if err then return nil, err end
  return M.get(path) --[[@as Fs.Link]], nil
end

--- Copies a link to a new location. Returns a new object which points to the
--- freshly created link.
--- @param target string The path to place the new link at.
--- @return Fs.Link? link
--- @return string? error
function M.Link:cp(target)
  target = M.path(target)
  --- @diagnostic disable-next-line: undefined-field, redefined-local
  local _, err = vim.loop.fs_symlink(self:get_target().path, target)
  if err then return nil, err end
  local node = M.get(target):update()
  return node --[[@as Fs.Link]]
end

--- Gets the target of a link, if it has a valid target.
--- @return Fs.Node? target
--- @return string? error
function M.Link:get_target()
  --- @diagnostic disable-next-line: undefined-field
  local path, err = vim.loop.fs_readlink(self.path)
  if err then return nil, err end
  --- @diagnostic disable-next-line: redefined-local
  local target, err = M.get(M.path(path))
  if err then return nil, err end
  self.target = target
  return target
end

--- Joins and normalizes a path.
--- @param start string The first section of the path.
--- @vararg string Additional path segments to be added after the first.
--- @return string path
function M.path(start, ...)
  start = vim.fn.fnamemodify(start, ":p")
  return vim.fs.normalize(vim.fs.joinpath(start, ...))
end

--- Gets the data for a node on the file system. Fails when the file does not
--- exist or when asking for an id which does not exist
--- @param ident string|integer The file identifier.
--- @return Fs.Node? node
--- @return string? error
function M.get(ident)
  if type(ident) == "number" then
    if H.cache[ident] then
      return H.cache[ident]
    else
      return nil, "ENOCACHE: id not cached: " .. ident
    end
  end
  ident = M.path(ident --[[@as string]])
  if H.ids[ident] then return H.cache[H.ids[ident]] end
  --- @diagnostic disable-next-line: missing-fields
  return setmetatable(H.register { path = ident }, { __index = M.Node }):update()
end

return M
