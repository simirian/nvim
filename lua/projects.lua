-- simirian's NeoVim
-- projects module

local M = {}
local H = {}

--- Map from project path to name.
--- @type table<string, string>
H.projects = {}

--- Normalizes a path.
--- @param start string The first component of the path.
--- @vararg string Other components of the path.
--- @return string path
function H.path(start, ...)
  start = vim.fn.fnamemodify(start, ":p")
  return vim.fs.normalize(vim.fs.joinpath(start, ...))
end

--- Saves the current project list to projects.json.
function H.save()
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_open(H.filepath, "w", 420, function(err, file)
    assert(not err, err)
    --- @diagnostic disable-next-line: undefined-field
    vim.loop.fs_write(file, vim.json.encode(H.projects), function()
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_close(file)
    end)
  end)
end

--- Loads the saved project list from projects.json.
function H.load()
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_open(H.filepath, "r", 420, function(err, file)
    assert(not err, err)
    --- @diagnostic disable-next-line: undefined-field
    vim.loop.fs_fstat(file, function(_, stat)
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_read(file, stat.size, 0, function(_, data)
        --- @diagnostic disable-next-line: undefined-field
        vim.loop.fs_close(file)
        H.projects = vim.json.decode(data)
      end)
    end)
  end)
end

--- Adds a new project at the path aliased to name.
--- @param path? string The path to the project directory, default cwd.
--- @param name string Unique display name of the project.
function M.add(path, name)
  --- @diagnostic disable-next-line: undefined-field
  path = H.path(path or vim.loop.cwd())
  H.projects[path] = name
  H.save()
end

--- Remove a project by its normalized path. This does not delete the project
--- directory, it only causes this module to forget it exists.
--- @param path? string The path to the project to forget, default cwd.
function M.remove(path)
  --- @diagnostic disable-next-line: undefined-field
  path = H.path(path or vim.loop.cwd())
  H.projects[path] = nil
  H.load()
end

--- Opens a project by name.
--- @param name string The name of the project to open.
function M.open(name)
  for path, pname in pairs(H.projects) do
    if pname == name then
      vim.api.nvim_set_current_dir(path)
      return
    end
  end
end

--- Gets the project of a path or the current directory if no path is provided.
--- Returns nil if the path is not in a project.
--- @param path? string The path to test.
--- @return string? project
function M.show(path)
  --- @diagnostic disable-next-line: undefined-field
  path = H.path(path or vim.loop.cwd() .. "/f")
  return H.projects[H.path(vim.fs.root(path, function(_, rpath)
    return H.projects[H.path(rpath)] ~= nil
  end))]
end

--- Returs a list of all exisitng projects in no particular order.
--- @return { path: string, name: string }[]
function M.list()
  local projects = {}
  for path, name in pairs(H.projects) do
    table.insert(projects, { name = name, path = path })
  end
  return projects
end

--- The options which can be passed to the projects module.
--- @class Projects.Opts
--- The path to the projects.json file which saves projects between sessions.
--- @field filepath string

--- Sets up the projects module.
--- @param opts? Projects.Opts
function M.setup(opts)
  opts = opts or {}
  if not opts.filepath then
    H.filepath = H.path(vim.fn.stdpath("data") --[[@as string]], "projects.json")
  else
    if opts.filepath:match("[/\\]projects.json$") then
      H.filepath = H.path(opts.filepath)
    else
      H.filepath = H.path(opts.filepath, "projects.json")
    end
  end
  H.load()

  vim.api.nvim_create_user_command("Project", function(args)
    if args.fargs[1] == "add" then
      --- @diagnostic disable-next-line: undefined-field
      M.add(vim.loop.cwd(), args.fargs[2])
    elseif args.fargs[1] == "remove" then
      --- @diagnostic disable-next-line: undefined-field
      M.remove(vim.loop.cwd())
    elseif args.fargs[1] == "open" then
      M.open(args.fargs[1])
    elseif args.fargs[1] == "show" then
      --- @diagnostic disable-next-line: undefined-field
      print(M.show(vim.loop.cwd()) or "none")
    elseif args.fargs[1] == "list" then
      vim.print(M.list())
    else
      vim.notify("invalid project subcommand " .. args.fargs[1], vim.log.levels.ERROR, {})
    end
  end, { desc = "Projects command.", nargs = "+", complete = function(arglead, cmdline, curpos)
    local spaces = 0
    for str in cmdline:gmatch("%s+") do
      spaces = spaces + 1
    end
    if spaces == 1 then
      return vim.tbl_filter(function(e)
        return e:sub(1, #arglead) == arglead
      end, { "add", "remove", "open", "show", "list" })
    elseif spaces == 2 then
      if cmdline:match("^%S+%s+(%S+)") == "open" then
        return vim.tbl_filter(function(e)
          return e:sub(1, #arglead) == arglead
        end, vim.tbl_map(function(e) return e.name end, M.list()))
      end
    end
  end})
end

return M
