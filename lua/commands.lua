--------------------------------------------------------------------------------
--                              simirian's NeoVim                             --
--                                ~ commands ~                                --
--------------------------------------------------------------------------------

local api = vim.api
local newcmd = api.nvim_create_user_command

-- commands {{{1

-- :Update {{{2
newcmd("Update", function()
  require("lazy").sync { show = false }
  vim.cmd("TSUpdate")
  vim.cmd("MasonUpdate")
  vim.cmd("MasonInstallAll")
end, { desc = "Updates Lazy, Mason, and Treesitter." })

-- :BufInfo {{{2
newcmd("BufInfo", function()
  P(vim.fn.getbufinfo("%")[1])
end, { desc = "Get basic buffer information for the current buffer." })

-- :WinProse {{{2
newcmd("WinProse", function()
  vim.wo.spell = true
  vim.wo.conceallevel = 2
  vim.bo.textwidth = 80
end, { desc = "Set a window to prose writing mode." })

-- :WinCode {{{2
newcmd("WinCode", function()
  vim.wo.spell = false
  vim.wo.conceallevel = 0
  vim.bo.textwidth = 0
end, { desc = "Set a window to code writing mode." })

-- :Toc {{{2
local tocns = api.nvim_create_namespace("TOC")

newcmd("Toc", function()
  if vim.bo[vim.fn.bufnr()].filetype ~= "markdown" then return end
  local oldbuf = vim.fn.bufname()
  vim.cmd("sil lv /^#\\+ .*/ %") -- silently lvimgrep for md headings
  vim.cmd("lcl")                 -- close loclist
  vim.cmd("lw")                  -- open loclist window above
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.cursorcolumn = false
  vim.wo.spell = false
  vim.wo.signcolumn = "auto"
  vim.wo.colorcolumn = ""
  vim.wo.statuscolumn = ""
  vim.wo.conceallevel = 2
  vim.wo.concealcursor = "nvic"
  vim.wo.statusline = "%2* TOC (" .. vim.fs.basename(oldbuf)
      .. ") %* %= %2* %c "
  local bufnr = vim.fn.bufnr()
  for _, mark in ipairs(api.nvim_buf_get_extmarks(bufnr, tocns, 0, -1, {})) do
    api.nvim_buf_del_extmark(bufnr, tocns, mark)
  end
  for lnum, line in ipairs(api.nvim_buf_get_lines(0, 0, -1, false)) do
    local s, e = line:find("#+")
    api.nvim_buf_set_extmark(bufnr, tocns, lnum - 1, 0, {
      end_col = e,
      conceal = "",
      virt_text = { { ("  "):rep(e - s), "Normal" } },
      virt_text_pos = "inline",
    })
  end
end, { desc = "Open file table of contents." })

api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(event)
    vim.keymap.set("n", "gO", ":Toc<cr>", { buffer = event.buf })
  end,
  desc = "Open this buffer's table of contents."
})

-- global functions {{{1

-- P() {{{2
--- Debug print anything.
--- @param a any what to print
function P(a)
  vim.print(a)
end
-- vim:fdm=marker
