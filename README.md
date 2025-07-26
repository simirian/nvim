# NeoVim

simirian's NeoVim configuration

## Install

Install the latest version of NeoVim. (Older versions are untested but may
work.) Run `git clone https://github.com/simirian/nvim` in your configuration
directory. Run NeoVim like normal (`nvim`), and everything SHOULD be installed.

## Keymaps

| map                | action                                          |
| ------------------ | ----------------------------------------------- |
| `<C-j>`, `<C-k>`   | Next and previous window in tabpage.            |
| `<C-h>`, `<C-l>`   | Next and previous tabpage.                      |
| `jj`               | Exit insert mode.                               |
| `<esc><esc>`       | Exit terminal mode.                             |
| `<leader>p`        | Paste from system clipboard.                    |
| `<leader>y`        | Yank to system clipboard.                       |
| `<tab>`, `<S-tab>` | Invoke completion or indentation in insert.     |
| `U`                | Redo.                                           |
| `_`                | Open vim's current directory.                   |
| `-`                | Open the parent directory of the current file.  |
| `sa` motion key    | Surround operator, see below.                   |
| `<leader>ff`       | Telescope find files.                           |
| `<leader>fg`       | Telescope live grep.                            |
| `<leader>fb`       | Telescope buffers.                              |
| `<leader>fh`       | Telescope help.                                 |

## Commands

| command       | action                                  |
| ------------- | --------------------------------------- |
| `:Toc`        | Table of contents support for markdown. |
| `:Today`      | Open today's daily note.                |
| `:Yesterday`  | Open yesterday's daily note.            |
| `:Scratch`    | Open a scratch buffer.                  |
| `:AnnabelLee` | Open a scratch buffer with Annabel Lee. |

## Plugins

This branch (`centralize`) aims to minimize dependencies at all costs. This
means that as many plugins as possible will be gradually removed and replaces
with top level `lua/*` modules. Current progress is tracked below, and this list
will be removed once this branch is merged into main.

- [x] `nvim-contour` -> `lines`
    - [x] this dies on `:hi clear` because `nvim-web-devicons` gets cleared
- [x] `mason.nvim` -> `lsp`
- [x] `yicks` -> `colors`
    - [x] set internal terminal colors
    - [x] allow command line window (`q:`) highlighting (update fixed this?)
- [o] `nvim-autopairs` (add surround functionality) -> `pairs`
    - [x] simple pairing of `()`, `[]`, `{}`, `""`, `''`, ` `` `
    - [x] complex (manual with functions) pairing
    - [x] surround operator
        - [x] char mode
        - [x] line mode
        - [x] block mode
    - [ ] delete surrounds
    - [ ] change surrounds
    - I imagine this won't be too hard, and I'm looking forward to getting rid
      of it
- [o] `nvim-tree` -> `fex`, `ft`
    - [x] view directories
    - [x] navigate directories
    - [x] basic manipulations (add, remove, move, copy)
    - [x] copy/move across buffers
    - [x] safe file system modification (as much error checking as possible)
    - [ ] file tree view for current directory
- [o] `nvim-manager` -> `lsp`, `projects`
    - [x] `projects` to save project directories
    - [x] `lsp` to load language servers
    - [ ] `workspaces` to detect and activate special configurations
    - I don't know how easy this will be to remove, but it can't be that hard
- [o] `nvim-cmp` -> `cmp`
    - currently inactive, but still needs a proper replacement
    - [ ] automatic live completion
    - [ ] snippet completion
- [ ] `lazy.nvim` -> git sub-modules
    - this shouldn't be too hard with git sub-modules
- [ ] `telescope.nvim`, `plenary.nvim` -> `select` (use `vim.ui.select`)
    - this is a monumental task and will probably be one of the last things to
      get replaced
- [ ] `nvim-treesitter`
    - I don't actually think this is practical to remove
- [ ] `nvim-web-devicons`
    - again, I don't actually think this is practical to remove
