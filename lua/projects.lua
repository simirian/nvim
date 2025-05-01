-- simirian's NeoVim
-- projects module

local M = {}
local H = {}

--- Map from project path to name.
--- @type table<string, string>
H.projects = {}

--- Automatically included projects.
--- @type table<string, string>
H.include = {}

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
--- @param name string Unique display name of the project.
--- @param path? string The path to the project directory, default cwd.
function M.add(name, path)
  --- @diagnostic disable-next-line: undefined-field
  H.projects[name] = vim.fs.normalize(path or vim.loop.cwd())
  H.save()
end

--- Remove a project by its normalized path. This does not delete the project
--- directory, it only causes this module to forget it exists.
--- @param name string The name of the project to remove, current is default.
function M.remove(name)
  H.projects[name] = nil
  H.save()
end

--- Opens a project by name.
--- @param name string The name of the project to open.
function M.open(name)
  if H.projects[name] then
    vim.api.nvim_set_current_dir(H.projects[name])
  elseif H.include[name] then
    vim.api.nvim_set_current_dir(H.include[name])
  else
    vim.notify("project " .. name .. " doesn't exist", vim.log.levels.ERROR, {})
  end
end

--- Gets the project of a path or the current directory if no path is provided.
--- Returns nil if the path is not in a project.
--- @param path? string The path to test.
--- @return string? project
function M.show(path)
  --- @diagnostic disable-next-line: undefined-field
  path = vim.fs.normalize(path or vim.loop.cwd())
  for name, ppath in pairs(H.projects) do
    ppath = vim.fs.normalize(ppath)
    if path == ppath or path:match("^" .. ppath:gsub("%%", "%%%%") .. "[/\\]") then
      return name
    end
  end
end

--- Returs a list of all exisitng projects in no particular order.
--- @param mode? "all"|"saved"|"include" Which set of projects to show.
--- @return { path: string, name: string }[]
function M.list(mode)
  local projects = {}
  if mode ~= "include" then
    for name, path in pairs(H.projects) do
      table.insert(projects, { name = name, path = path })
    end
  end
  if mode ~= "saved" then
    for name, path in pairs(H.include) do
      table.insert(projects, { name = name, path = path })
    end
  end
  return projects
end

--- The options which can be passed to the projects module.
--- @class Projects.Opts
--- The path to the projects.json file which saves projects between sessions.
--- @field filepath string
--- Adds directories which implicitly include their child directories as
--- projects when there are no name conflicts.
--- @field include string|string[]

--- Sets up the projects module.
--- @param opts? Projects.Opts
function M.setup(opts)
  opts = opts or {}
  H.filepath = opts.filepath or vim.fn.stdpath("data") .. "/projects.json"
  H.load()

  opts.include = opts.include or vim.fs.joinpath(vim.env.HOME, "Source")
  if type(opts.include) == "string" then
    opts.include = { opts.include --[[@as string]] }
  end
  for _, path in ipairs(opts.include --[[@as string[] ]]) do
    for name, type in vim.fs.dir(path) do
      if type == "directory" and not H.projects[name] and not H.include[name] then
        H.include[name] = vim.fs.normalize(path .. "/" .. name)
      end
    end
  end

  vim.api.nvim_create_user_command("Project", function(args)
    if args.fargs[1] == "add" then
      --- @diagnostic disable-next-line: undefined-field
      M.add(vim.loop.cwd(), args.fargs[2])
    elseif args.fargs[1] == "remove" then
      --- @diagnostic disable-next-line: undefined-field
      M.remove(vim.loop.cwd())
    elseif args.fargs[1] == "open" then
      M.open(args.fargs[2])
    elseif args.fargs[1] == "show" then
      --- @diagnostic disable-next-line: undefined-field
      print(M.show(vim.loop.cwd()) or "none")
    elseif args.fargs[1] == "list" then
      for name, dir in pairs(vim.tbl_deep_extend("keep", H.projects, H.include)) do
        print(name, (" "):rep(math.max(15 - #name, 1)), dir)
      end
    else
      vim.notify("invalid project subcommand " .. args.fargs[1], vim.log.levels.ERROR, {})
    end
  end, {
    desc = "Projects command.",
    nargs = "+",
    complete = function(arglead, cmdline)
      local spaces = 0
      for _ in cmdline:gmatch("%s+") do
        spaces = spaces + 1
      end
      if spaces == 1 then
        return vim.tbl_filter(function(e)
          return e:sub(1, #arglead) == arglead
        end, { "add", "remove", "open", "show", "list" })
      elseif spaces == 2 then
        if cmdline:match("^%S+%s+(%S+)") == "open" then
          return vim.iter(M.list())
              :map(function(e) return e.name end)
              :filter(function(e) return e:sub(1, #arglead) == arglead end)
              :totable()
        end
      end
    end
  })
end

return M
