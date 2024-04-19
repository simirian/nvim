-- simirian's NeoVim
-- some useful custom commands

local newcmd = vim.api.nvim_create_user_command

newcmd("Update", function(command)
  require("lazy").sync{ show = false }
  vim.cmd("MasonUpdate")
  vim.cmd("TSUpdateSync")
end, { desc = "Updates Lazy, Mason, and Treesitter add-ons" })

newcmd("BufInfo", function(command)
  local bufnr = vim.api.nvim_get_current_buf()
  local binfo = {
    name = vim.api.nvim_buf_get_name(bufnr),
    number = bufnr,
    filetype = vim.api.nvim_buf_get_option(bufnr, "filetype"),
  }
  vim.notify(vim.inspect(binfo), vim.log.levels.INFO)
end, { desc = "Get basic buffer information for the current buffer" })

function Pt(tbl)
  print(vim.inspect(tbl))
end

