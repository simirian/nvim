-- simirian's NeoVim
-- some useful custom commands

local newcmd = vim.api.nvim_create_user_command

newcmd("Update", function()
  require("lazy").sync { show = false }
  vim.cmd("MasonUpdate")
  vim.cmd("TSUpdateSync")
end, { desc = "Updates Lazy, Mason, and Treesitter add-ons" })

newcmd("BufInfo", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local binfo = {
    name = vim.api.nvim_buf_get_name(bufnr),
    number = bufnr,
    filetype = vim.api.nvim_buf_get_option(bufnr, "filetype"),
  }
  vim.notify(vim.inspect(binfo), vim.log.levels.INFO)
end, { desc = "Get basic buffer information for the current buffer" })

--- Debug print anything.
--- @param a any what to print
function P(a)
  print(vim.inspect(a))
end

--- Checks if a direcotry contains an item, or all of a list of items.
--- @param dir string the directory to search
--- @param item string the item to search for, append / for directories
--- @return boolean contained
function DirContains(dir, item)
  for basename, type in vim.fs.dir(dir) do
    if type == "directory" then basename = basename .. "/" end
    if basename == item then return true end
  end
  return false
end
