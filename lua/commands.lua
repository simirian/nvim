--------------------------------------------------------------------------------
--                             simirian's NeoVim                              --
--                                ~ commands ~                                --
--------------------------------------------------------------------------------

vim.api.nvim_create_user_command("Toc", function()
  if vim.bo[vim.fn.bufnr()].filetype ~= "markdown" then return end
  local curpos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("silent lvimgrep /^#\\+ .*/ %")
  vim.api.nvim_win_set_cursor(0, curpos)
  local items = vim.fn.getloclist(0)
  for i, item in ipairs(items) do
    local level, text = item.text:match("^(#+)%s(.*)$")
    items[i] = {
      bufnr = item.bufnr,
      lnum = item.lnum,
      text = ("\u{a0}"):rep(level:len() * 2 - 2) .. text,
    }
  end
  vim.fn.setloclist(0, {}, "r", { items = items, title = "TOC" })
  vim.cmd.lopen()
  vim.wo.conceallevel = 3
  vim.wo.concealcursor = "nvic"
end, { desc = "Open file table of contents." })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(event)
    vim.keymap.set("n", "gO", ":Toc<cr>", { buffer = event.buf })
  end,
  desc = "Open this buffer's table of contents."
})

local function opendaily(time)
  local calendir = vim.fs.normalize(vim.env.HOME .. "/Documents/vault/daily")
  vim.fn.mkdir(calendir .. os.date("/%Y/%m", time), "p")
  vim.cmd.edit(calendir .. os.date("/%Y/%m/%d.md", time))
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines == 1 and lines[1] == "" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { os.date("# Daily %Y-%m-%d", time) --[[@as string]] })
  end
end

vim.api.nvim_create_user_command("Today", function()
  opendaily(os.time())
end, { desc = "Open today's daily note." })

vim.api.nvim_create_user_command("Yesterday", function()
  local date = os.date("*t")
  date.day = date.day - 1
  opendaily(os.time(date --[[@as osdateparam]]))
end, { desc = "Open yesterday's daily note." })

vim.api.nvim_create_user_command("Scratch", function(args)
  local bufname = "scratch"
  bufname = bufname .. ((args.count and args.count ~= 0) and args.count or "")
  local bufnr = vim.fn.bufnr(bufname)
  if bufnr == -1 then
    bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(bufnr, bufname)
  end
  if args.fargs[1] then
    vim.bo[bufnr].ft = args.fargs[1]
  end
  vim.cmd("buffer" .. (args.bang and "! " or " ") .. bufname)
end, { desc = "Open a scratch buffer.", count = 0, bang = true, bar = true, nargs = "?" })

vim.api.nvim_create_user_command("AnnabellLee", function(args)
  local bufnr = vim.fn.bufnr("annabel-lee")
  if bufnr == -1 then
    bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(bufnr, "annabel-lee")
    local oldul = vim.bo[bufnr].ul
    vim.bo[bufnr].ul = -1
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "It was many and many a year ago,",
      "   In a kingdom by the sea,",
      "That a maiden there lived whom you may know",
      "   By the name of Annabel Lee;",
      "And this maiden she lived with no other thought",
      "   Than to love and be loved by me.",
      "",
      "*I* was a child and *she* was a child,",
      "   In this kingdom by the sea,",
      "But we loved with a love that was more than love---",
      "   I and my Annabel Lee---",
      "With a love that the wingèd seraphs of Heaven",
      "   Coveted her and me.",
      "",
      "And this was the reason that, long ago,",
      "   In this kingdom by the sea,",
      "A wind blew out of a cloud, chilling",
      "   My beautiful Annabel Lee;",
      "So that her highborn kinsmen came",
      "   And bore her away from me,",
      "To shut her up in a sepulchre",
      "   In this kingdom by the sea.",
      "",
      "The angels, not half so happy in Heaven,",
      "   Went envying her and me---",
      "Yes!---that was the reason (as all men know,",
      "   In this kingdom by the sea)",
      "That the wind came out of the cloud by night,",
      "   Chilling and killing my Annabel Lee.",
      "",
      "But our love it was stronger by far than the love",
      "   Of those who were older than we---",
      "   Of many far wiser than we---",
      "And neither the angels in Heaven above",
      "   Nor the demons down under the sea",
      "Can ever dissever my soul from the soul",
      "   Of the beautiful Annabel Lee;",
      "",
      "For the moon never beams, without bringing me dreams",
      "   Of the beautiful Annabel Lee;",
      "And the stars never rise, but I feel the bright eyes",
      "   Of the beautiful Annabel Lee;",
      "And so, all the night-tide, I lie down by the side",
      "   Of my darling---my darling---my life and my bride,",
      "   In her sepulchre there by the sea---",
      "   In her tomb by the sounding sea.",
    })
    vim.bo[bufnr].ul = oldul
  end
  vim.bo[bufnr].ft = "markdown"
  vim.cmd("buffer" .. (args.bang and "! " or " ") .. bufnr)
end, { desc = "Open a scratch bufer with the text of Annabel Lee.", bang = true, bar = true })
