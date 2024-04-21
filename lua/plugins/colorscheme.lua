-- simirian's neovim
-- colorschemes, loaded by lazy according to settings.lua

local settings = require("settings")

local function make_scheme(name, opts)
  return {
    opts.repo,
    priority = 1000,
    config = function()
      if settings.colorschemes[1] == name then
        if opts.enable then
          opts.enable()
        else
          vim.cmd("colorscheme " .. name)
        end
      end
    end
  }
end

local tbl = {}

for name, opts in pairs(settings.colorschemes) do
  if name ~= 1 then
    table.insert(tbl, make_scheme(name, opts))
  end
end

return tbl
