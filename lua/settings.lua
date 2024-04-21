-- simirian's NeoVim
-- basic settings used in many other places

return {
  colorschemes = {
    "gruvbox-material",
    ["kanagawa"] = {
      repo = "rebelot/kanagawa.nvim",
    },
    ["gruvbox-material"] = {
      repo = "sainnhe/gruvbox-material",
      enable = function()
        vim.g.gruvbox_material_background = "medium"
        vim.g.gruvbox_material_foreground = "mix"
        vim.cmd("colorscheme gruvbox-material")
      end
    }
  },
  --ts_default_lang = { "c", "cpp", "lua", "vim", "vimdoc", "query", "bash" },

  icons = {
    -- item kind icons
    Array = "",
    Boolean = "",
    Class = "󱪵",
    Color = "",
    Constant = "󰭷",
    Constructor = "",
    Enum = "󱃣",
    EnumMember = "󰎢",
    Event = "",
    Field = "",
    File = "󰈤",
    Folder = "󰉋",
    Function = "󰊕",
    Interface = "",
    Key = "",
    Keyword = "",
    Method = "󰘧",
    Module = "",
    Namespace = "",
    Null = "󱥸",
    Number = "",
    Object = "󰔇",
    Operator = "󱓉",
    Package = "",
    Property = "",
    Reference = "",
    Snippet = "󰩫",
    String = "󰬴",
    Struct = "",
    Text = "󰈙",
    TypeParameter = "󰓹",
    Unit = "",
    Value = "󰺢",
    Variable = "󰄪",

    -- diagnostic icons
    Error = "",
    Warning = "",
    Information = "",
    Question = "",
    Hint = "󰌵",
    Debug = "",
    Trace = "",
    Ok = "",
    Pause = "",
    Pending = "󰞌",

    -- lazy UI icons
    cmd = " ",
    config = "",
    event = "",
    ft = " ",
    init = " ",
    import = " ",
    keys = " ",
    lazy = "󰒲 ",
    loaded = "●",
    not_loaded = "○",
    plugin = " ",
    runtime = " ",
    require = "󰢱 ",
    source = " ",
    start = "",
    task = " ",
    list = {
      "-",
      "=",
      ">",
      "*",
    },
  }
}
