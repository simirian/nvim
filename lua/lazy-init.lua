-- simirian's NeoVim
-- lazy.nvim plugins

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
--- @diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system { "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  rocks = {enabled = false },
  dev = { path = "~/Source" },
})
