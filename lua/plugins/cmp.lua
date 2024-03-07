-- simirian's NeoVim
-- code completion settings

return {
  {
    "windwp/nvim-autopairs",
    opts = {
      disable_in_macro = true,
      disable_in_visualblock = true,
      disable_in_replace_mode = true,
      enable_afterquote = false,
      check_ts = true,
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "windwp/nvim-autopairs",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- generic completion sources
      cmp.setup{
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert{
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = function(fallback)
            if cmp.visible() then
              cmp.confirm{select = true}
            else
              fallback()
            end
          end,
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
        },
        sources = cmp.config.sources{
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function (entry, vim_item)
            -- icon
            vim_item.kind = require("settings").icons[vim_item.kind]
            -- source
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snp]",
              buffer = "[Buf]",
              cmdline = "[CMD]",
              path = "[Pth]"
            })[entry.source.name]
            return vim_item
          end,
        },
        view = {
          entries = { name = "custom" },
        },
      }

      -- search
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources{
          { name = "buffer" },
        },
      })

      -- command line
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources{
          { name = "path" },
          { name = "cmdline" },
        },
      })

      -- autopairs compatibility
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}

