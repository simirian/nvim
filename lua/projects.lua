-- simirian's NeoVim
-- projects module

local M = {}

--- Map from project name to path.
--- @type table<string, string>
local projects = {}

--- Set of directories to include projects from.
--- @type table<string, true>
local includedirs = {}

--- Automatically included projects.
--- @type table<string, string>
local include = {}

--- The path to the projects store file.
--- @type string
local filepath = vim.fs.normalize(vim.fn.stdpath("data") .. "/projects.json")

--- Saves the current project list to projects.json.
local function save()
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_open(filepath, "w", 420, function(err, file)
    assert(not err, err)
    --- @diagnostic disable-next-line: undefined-field
    vim.loop.fs_write(file, vim.json.encode(projects), function()
      assert(not err, err)
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_close(file)
    end)
  end)
end

--- Loads the saved project list from projects.json.
local function load()
  --- @diagnostic disable-next-line: undefined-field
  vim.loop.fs_open(filepath, "r", 420, function(err, file)
    assert(not err, err)
    --- @diagnostic disable-next-line: undefined-field
    vim.loop.fs_fstat(file, function(_, stat)
      assert(not err, err)
      --- @diagnostic disable-next-line: undefined-field
      vim.loop.fs_read(file, stat.size, 0, function(_, data)
        assert(not err, err)
        --- @diagnostic disable-next-line: undefined-field
        vim.loop.fs_close(file)
        projects = vim.json.decode(data)
      end)
    end)
  end)
end

--- Adds a new project at the path aliased to name.
--- @param name string Unique display name of the project.
--- @param path? string The path to the project directory, default cwd.
function M.add(name, path)
  --- @diagnostic disable-next-line: undefined-field
  projects[name] = vim.fs.normalize(path or vim.loop.cwd())
  save()
end

--- Remove a project by its name or path. This does not delete the project
--- directory, it only causes this module to forget it exists.
--- @param project? string The name of or path to of the project to remove.
function M.remove(project)
  --- @diagnostic disable-next-line: undefined-field
  project = project or vim.fs.normalize(vim.loop.cwd())
  if projects[project] then
    projects[project] = nil
  else
    for name, path in ipairs(projects) do
      if path == project then
        projects[name] = nil
      end
    end
  end
  save()
end

--- Update the included projects.
local function updateinclude()
  include = {}
  for path in pairs(includedirs) do
    for name, type in vim.fs.dir(path) do
      if type == "directory" and not projects[name] and not include[name] then
        include[name] = vim.fs.normalize(path .. "/" .. name)
      end
    end
  end
end

--- Add include directories in which to find projects.
--- @param dirs string|string[] The directory or list of directories to include.
function M.include(dirs)
  dirs = type(dirs) == "string" and { dirs } or dirs
  for _, dir in ipairs(dirs --[[@as string[] ]]) do
    includedirs[dir] = true
  end
  updateinclude()
end

--- Remove include directories that projects could have been found in.
--- @param dirs string|string[] The directory or list of directories to exclude.
function M.exclude(dirs)
  dirs = type(dirs) == "string" and { dirs } or dirs
  for _, dir in ipairs(dirs --[[@as string[] ]]) do
    includedirs[dir] = nil
  end
  updateinclude()
end

--- Opens a project by name.
--- @param name string The name of the project to open.
function M.open(name)
  if projects[name] then
    vim.api.nvim_set_current_dir(projects[name])
  elseif include[name] then
    vim.api.nvim_set_current_dir(include[name])
  else
    vim.notify("project " .. name .. " doesn't exist", vim.log.levels.ERROR, {})
  end
end

--- Returs a map of project names to their paths.
--- @param mode? "all"|"saved"|"include" Which set of projects to show.
--- @return { path: string, name: string }[]
function M.list(mode)
  return vim.tbl_deep_extend("force",
    mode ~= "saved" and include or {},
    mode ~= "include" and projects or {})
end

--- Loads projects and enables the :Project command.
function M.enable()
  load()
  M.include { vim.fs.normalize(vim.env.HOME .. "/Source") }

  vim.api.nvim_create_user_command("Project", function(args)
    if args.fargs[1] == "add" then
      if not args.fargs[2] then
        vim.notify(":Project add requries a project name.", vim.log.levels.ERROR, {})
        return
      end
      --- @diagnostic disable-next-line: undefined-field
      M.add(args.fargs[2], vim.loop.cwd())
    elseif args.fargs[1] == "remove" then
      --- @diagnostic disable-next-line: undefined-field
      M.remove(args.fargs[2])
    elseif args.fargs[1] == "include" then
      local dirs = vim.deepcopy(args.fargs)
      table.remove(dirs, 1)
      M.include(dirs)
    elseif args.fargs[1] == "exclude" then
      local dirs = vim.deepcopy(args.fargs)
      table.remove(dirs, 1)
      M.exclude(dirs)
    elseif args.fargs[1] == "open" then
      if not args.fargs[2] then
        vim.notify(":Project open requires a project name.", vim.log.levels.ERROR, {})
      end
      M.open(args.fargs[2])
    else
      vim.notify("invalid project subcommand " .. args.fargs[1], vim.log.levels.ERROR, {})
    end
  end, {
    desc = "Projects command.",
    nargs = "+",
    complete = function(arglead, cmdline)
      local _, spaces = cmdline:gsub("%s+", "")
      if spaces == 1 then
        return vim.tbl_filter(function(e)
          return e:sub(1, #arglead) == arglead
        end, { "add", "remove", "include", "exclude", "open" })
      elseif spaces == 2 then
        local subcommand = cmdline:match("^%S+%s+(%S+)")
        if subcommand == "open" or subcommand == "remove" then
          local names = {}
          for name in pairs(vim.tbl_deep_extend("force", include, projects)) do
            if name:sub(1, #arglead) == arglead then
              table.insert(names, name)
            end
          end
          return names
        end
      end
    end
  })
end

M.enable()

--- Unloads the included projects and disables the :Project command.
function M.disable()
  includedirs = {}
  include = {}
  vim.api.nvim_del_user_command("Project")
end

return M
