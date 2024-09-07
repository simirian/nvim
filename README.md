# NeoVim

simirian's NeoVim config

## Install

Install the latest version of NeoVim. (older versions are untested but may
work) Run `git clone https://github.com/simirian/nvim` in your configuration
directory. Run NeoVim like normal (`nvim`), and everything SHOULD be installed.

## Configuration

Most configuration is straightforwards, keybinds can go in lua/keys.lua, vim
options can go in lua/opts.lua, etc.. Plugins and their settings go in
lua/plugins/ according to the lazy.nvim spec.

To add support for additional languages those languages should be added to
`lua/languages/`. This should specify the language server, treesitter parser,
and filetypes for the language.

## Keymaps

| map                | action                                          |
| ------------------ | ----------------------------------------------- |
| `kk`               | Exit insert mode.                               |
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

### Telescope

Begin telescope mappings with the keybind `leader` > `f`, then continue with
another key as shown below.

| map          | action                 |
| ------------ | ---------------------- |
| `<leader>ff` | \[f\]ind \[f\]iles     |
| `<leader>fg` | \[f\]ind with \[g\]rep |
| `<leader>fb` | \[f\]ind \[b\]uffer    |
| `<leader>fh` | \[f\]ind \[h\]elp      |

### LSP

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

| command     | action                                       |
| ----------- | -------------------------------------------- |
| `:Update`   | Updates mason, treesitter, and lazy.         |
| `:BufInfo`  | Prints basic buffer info.                    |
| `:WinProse` | Sets a few window options for writing prose. |
| `:WinCode`  | Unsets prose writing options.                |
| `:Toc`      | Opens a markdown file's table of contents.   |
