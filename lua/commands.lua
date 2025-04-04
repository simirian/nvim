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

newcmd("Today", function()
  local vaultpath = vim.fs.normalize(vim.fn.expand("~/Documents/vault/"))
  -- ensure the folder for the note exists
  local path = vaultpath .. os.date("/daily/%Y/%m")
  vim.fn.mkdir(path, "p")
  -- edit the note
  path = path .. os.date("/%d.md")
  vim.cmd.edit(path)
  -- if there's anything in the note then don't load the template
  local lines = vim.api.nvim_buf_get_lines(vim.fn.bufnr(), 0, -1, false)
  if #lines > 1 or lines[1] ~= "" then return end
  -- load the template and use the current date
  local template = io.open(vaultpath .. "/templates/template-daily.md", "r")
  if template then
    local lines = {}
    local date = os.date("%Y-%m-%d")
    for line in template:lines() do
      lines[#lines + 1] = line:gsub("{{date:YYYY%-MM%-DD}}", date)
    end
    vim.api.nvim_buf_set_lines(vim.fn.bufnr(), 0, -1, false, lines)
    template:close()
  end
end, { desc = "Open today's daily note." })

vim.api.nvim_create_user_command("Scratch", function(args)
  local bufname = " scratch"
  if args.count and args.count ~= 0 then
    bufname = bufname .. args.count
  end
  --- @diagnostic disable-next-line: param-type-mismatch
  local ok, err = pcall(vim.cmd, "edit" .. (args.bang and "!" or "") .. bufname)
  if not ok then
    vim.notify(err:match("E%d%d:.*$"), vim.log.levels.ERROR, {})
  else
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "hide"
    vim.bo.swapfile = false
  end
end, { desc = "Open a scratch buffer.", count = 0, bang = true, bar = true })

-- links should look for [[...]] in this file
-- backlinks should look for [[file[#h]]] | [[dir/file[#h]]] etc. in the vault
-- tags list is " fg#[^\s#]\S*"

api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(event)
    vim.keymap.set("n", "gO", ":Toc<cr>", { buffer = event.buf })
  end,
  desc = "Open this buffer's table of contents."
})
