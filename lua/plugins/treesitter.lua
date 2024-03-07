-- simirian's NeoVim
-- treesitter settings

-- TODO: language module system

return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      -- cpp
      "c",
      "cpp",

      -- lua/nvim
      "lua",
      "vim",
      "vimdoc",

      -- rust
      "rust",

      -- bash
      "bash"
    },
    sync_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    autopairs = {
      enable = true
    }
  }
}

