--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                ~ commands ~                                --
--------------------------------------------------------------------------------

local newcmd = vim.api.nvim_create_user_command

-- commands {{{1

-- :Update {{{2
newcmd("Update", function()
  require("lazy").sync { show = false }
  vim.cmd("MasonUpdate")
  vim.cmd("TSUpdate")
end, { desc = "Updates Lazy, Mason, and Treesitter add-ons" })

-- :BufInfo {{{2
newcmd("BufInfo", function()
  P(vim.fn.getbufinfo("%")[1])
end, { desc = "Get basic buffer information for the current buffer" })

-- :WinProse {{{2
newcmd("WinProse", function()
  vim.wo.spell = true
  vim.wo.conceallevel = 2
  vim.bo.textwidth = 80
end, { desc = "Set a window to prose writing mode." })

-- :WinCode {{{2
newcmd("WinCode", function ()
  vim.wo.spell = false
  vim.wo.conceallevel = 0
  vim.bo.textwidth = 0
end, {desc = "Set a window to code writing mode."})

-- global functions {{{1

--- P() {{{2
--- Debug print anything.
--- @param a any what to print
function P(a)
  vim.print(a)
end

--- DirContains {{{2
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
-- vim:fdm=marker
