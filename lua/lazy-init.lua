-- simirian's NeoVim
-- lazy.nvim plugins

local vfn = vim.fn

local lazypath = vfn.stdpath("data") .. "/lazy/lazy.nvim"
--- @diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vfn.system { "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  rocks = {enabled = false },
  dev = { path = "~/Source" },
})
