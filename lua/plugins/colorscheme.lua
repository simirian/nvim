-- simirian's neovim
-- colorschemes, loaded by lazy according to settings.lua

-- TODO: make schemes global somewhere?

--- List of colorschemes to install.
--- @type string[]|table[]
local schemes = {
  "cryptomilk/nightcity.nvim",
  "rebelot/kanagawa.nvim",
  "sainnhe/gruvbox-material",
}

--- Load the default color scheme.
local function enable()
    -- random yicks color scheme
    if os.time() % 2 == 0 then vim.g.yicks_blue = true end
    vim.cmd.colorscheme("yicks")
end

-- reformat schemes to lazy specs
for i, scheme in ipairs(schemes) do
  local tbl = { priority = 1000 }
  tbl[1] = scheme
  schemes[i] = tbl
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    enable()
  end
})

return schemes
