--------------------------------------------------------------------------------
--                             simirian's NeoVim                              --
--                                ~ commands ~                                --
--------------------------------------------------------------------------------

local api = vim.api
local newcmd = api.nvim_create_user_command

newcmd("Update", function()
  require("lazy").sync { show = false }
  vim.cmd("TSUpdate")
  vim.cmd("MasonUpdate")
end, { desc = "Updates Lazy, Mason, and Treesitter." })

newcmd("BufInfo", function()
  vim.print(vim.fn.getbufinfo("%")[1])
end, { desc = "Get basic buffer information for the current buffer." })

local tocns = api.nvim_create_namespace("TOC")

newcmd("Toc", function()
  if vim.bo[vim.fn.bufnr()].filetype ~= "markdown" then return end
  local oldbuf = vim.fn.bufname()
  vim.cmd("silent lvimgrep /^#\\+ .*/ %")
  vim.cmd("lopen")
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.cursorcolumn = false
  vim.wo.spell = false
  vim.wo.signcolumn = "no"
  vim.wo.colorcolumn = ""
  vim.wo.statuscolumn = ""
  vim.wo.conceallevel = 2
  vim.wo.concealcursor = "nvic"
  vim.wo.statusline = "%2* TOC (" .. vim.fs.basename(oldbuf) .. ") %* %= %2* %c "
  local bufnr = vim.fn.bufnr()
  for _, mark in ipairs(api.nvim_buf_get_extmarks(bufnr, tocns, 0, -1, {})) do
    api.nvim_buf_del_extmark(bufnr, tocns, mark[1])
  end
  for lnum, line in ipairs(api.nvim_buf_get_lines(0, 0, -1, false)) do
    local s, e = line:find("#+")
    api.nvim_buf_set_extmark(bufnr, tocns, lnum - 1, 0, {
      end_col = e + 1,
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
