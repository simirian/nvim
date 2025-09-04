# simirian's Neovim

## Install

Install the latest version of Neovim. (Older versions are untested but may
work.) Run `git clone https://github.com/simirian/nvim .` in your configuration
directory. Install the language servers you will be using from you package
manager / their downloads page, and ensure they're on `$PATH`. Run `nvim` and
everything SHOULD work after lazy does its magic.

If you want to use a language server which isn't configured, copy one of the
simpler LSP configuration files in `lsp/` (eg. `clangd.lua`) and name it after
your language server, then replace all the appropriate variables.

## Keymaps

| map                | action                                    |
| ------------------ | ----------------------------------------- |
| `<C-j>`, `<C-k>`   | Next and previous window in tabpage.      |
| `<C-h>`, `<C-l>`   | Next and previous tabpage.                |
| `jj`               | Exit insert mode.                         |
| `<esc><esc>`       | Exit terminal mode.                       |
| `<leader>p`        | Paste from system clipboard.              |
| `<leader>y`        | Yank to system clipboard.                 |
| `<tab>`, `<S-tab>` | Select completion item, move in snippets. |
| `U`                | Redo.                                     |
| `<leader>ff`       | Telescope find files.                     |
| `<leader>fg`       | Telescope live grep.                      |
| `<leader>fb`       | Telescope buffers.                        |
| `<leader>fh`       | Telescope help.                           |

## Commands

| command       | action                                  |
| ------------- | --------------------------------------- |
| `:Scratch`    | Open a scratch buffer.                  |
| `:AnnabelLee` | Open a scratch buffer with Annabel Lee. |

## Native Plugins

These files are relatively brief. It is recommended that if you want to use
their features, you read the full help file, as they will provide insight into
how to use them and what might go wrong when using them.

- *calendir* `:h calendir.txt` provides calendar and journal functionality
- *fex* `:h fex.txt` lets you edit the file system like a buffer
- *lines* customizes the status line and tab line
- *lsp* sets up native vim language server functionality and tab completion
- *pairs* `:h pairs.txt` provides autopairs and surrounds
- *projects* `:h projects.txt` makes it easy to open projects quickly
- *scratch* `:h scratch.txt` access to scratch buffers of any file type

## External Plugins

This configuration(`centralize`) aims to minimize dependencies at all costs.
This means that as many plugins as possible will be gradually removed and
replaces with vim-style `plugin/` files. Current progress is tracked below, and
this list will be removed once this list is completed to a satisfactory degree.

- [x] `nvim-contour` -> `lines`
    - [x] this dies on `:hi clear` because `nvim-web-devicons` gets cleared
- [x] `mason.nvim` -> `lsp`
- [x] `yicks`
    - [-] set internal terminal colors
    - [-] allow command line window (`q:`) highlighting (update fixed this?)
- [x] `nvim-autopairs` -> `pairs`
    - [x] simple pairing of `()`, `[]`, `{}`, `""`, `''`, ` `` `
    - [x] complex (manual with functions) pairing
    - [x] surround operator
        - [x] char mode
        - [x] line mode
        - [x] block mode
    - [x] delete surrounds
    - [x] change surrounds
    - I imagine this won't be too hard, and I'm looking forward to getting rid
      of it
- [o] `nvim-tree` -> `fex`, `ft`
    - [x] view directories
    - [x] navigate directories
    - [x] basic manipulations (add, remove, move, copy)
    - [x] copy/move across buffers
    - [x] safe file system modification (as much error checking as possible)
    - [ ] file tree view for current directory
- [x] `nvim-manager` -> `lsp`, `projects`
    - [x] `projects` to save project directories
    - [x] `lsp` to load language servers
    - [-] `workspaces` to detect and activate special configurations
    - I don't know how easy this will be to remove, but it can't be that hard
- [x] `nvim-cmp` -> `lsp`
    - [-] automatic live completion
    - [x] snippet completion
- [ ] `lazy.nvim` -> git sub-modules
    - this shouldn't be too hard with git sub-modules
- [o] `telescope.nvim`, `plenary.nvim` -> `pick` (use `vim.ui.select`)
    - this is a monumental task and will probably be one of the last things to
      get replaced
- [ ] `nvim-treesitter`
    - I don't actually think this is practical to remove
- [ ] `nvim-web-devicons`
    - again, I don't actually think this is practical to remove
