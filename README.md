# NeoVim

simirian's NeoVim configuration

## Install

Install the latest version of NeoVim. (Older versions are untested but may
work.) Run `git clone https://github.com/simirian/nvim` in your configuration
directory. Run NeoVim like normal (`nvim`), and everything SHOULD be installed.

## Keymaps

| map                | action                                          |
| ------------------ | ----------------------------------------------- |
| `jj`               | Exit insert mode.                               |
| `U`                | Redo.                                           |
| `<C-f>`            | Format in insert mode.                          |
| `<C-j>`, `<C-k>`   | Next and previous window in tabpage.            |
| `<C-h>`, `<C-l>`   | Next and previous tabpage.                      |
| `<C-arrow>`        | Resize the current window.                      |
| `<A-j>`, `<A-k>`   | Moves the current line or selection up or down. |
| `<leader>p`        | Paste from system clipboard.                    |
| `<leader>y`        | Yank to system clipboard.                       |
| `<Tab>`, `<S-Tab>` | Invoke completion or indentation.               |
| `<leader>e`        | Open popup file explorer.                       |

Telescope:

| map          | action                 |
| ------------ | ---------------------- |
| `<leader>ff` | \[f\]ind \[f\]iles     |
| `<leader>fg` | \[f\]ind with \[g\]rep |
| `<leader>fb` | \[f\]ind \[b\]uffer    |
| `<leader>fh` | \[f\]ind \[h\]elp      |

Language servers:

| map          | action                                      |
| ------------ | ------------------------------------------- |
| `<tab>`      | Next completion item.                       |
| `<S-tab>`    | Previous completion item.                   |
| `<leader>gd` | \[g\]oto \[d\]efinition.                    |
| `<leader>gD` | \[g\]oto \[D\]eclaration.                   |
| `<leader>gi` | \[g\]oto \[i\]mplementation.                |
| `<leader>gr` | \[g\]et \[r\]eferences.                     |
| `<leader>ld` | \[l\]ist \[d\]iagnostics.                   |
| `<leader>li` | \[l\]ist symbol \[i\]nformation             |
| `<leader>ls` | \[l\]ist function \[s\]ignature.            |
| `<C-s>`      | List function \[s\]ignature in insert mode. |
| `<leader>cr` | \[c\]ode \[r\]ename                         |
| `<leader>ca` | \[c\]ode \[a\]ctions                        |
| `<leader>cf` | \[c\]ode \[f\]ormat                         |

## Commands

| command     | action                                     |
| ----------- | ------------------------------------------ |
| `:Update`   | Updates treesitter and lazy.               |
| `:BufInfo`  | Prints basic buffer info.                  |
| `:Toc`      | Opens a markdown file's table of contents. |
| `:Today`    | Open today's daily note.                   |

## Plugins

This branch (`centralize`) aims to minimize dependencies at all costs. This
means that as many plugins as possible will be gradually removed and replaces
with top level `lua/*` modules. Current progress is tracked below, and this list
will be removed once this branch is merged into main.

- [x] `nvim-contour` -> `lines`
- [x] `mason.nvim` -> `lsp`
- [x] `yicks` -> `colors`
- [o] `nvim-autopairs` (add surround functionality) -> `pairs`
    - [x] simple pairing of `()`, `[]`, `{}`, `""`, `''`, ` `` `
    - [ ] surround capability with operators for add, change, and remove on
      those pairs
        - maps like `vim-surround` or `mini-surround`
    - I imagine this won't be too hard, and I'm looking forward to getting rid
      of it
- [ ] `nvim-tree` -> `fex`
    - [ ] view directories
    - [ ] basic manipulations (add, remove, move, copy)
    - [ ] copy/move across buffers
- [ ] `nvim-manager` -> `lsp`, `projects`
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
