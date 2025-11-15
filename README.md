# simirian's Neovim

## Install

Install the latest version of Neovim. (Older versions are untested but may
work.) Run `git clone https://github.com/simirian/nvim .` in your configuration
directory. Install the language servers you will be using from your package
manager / their downloads page, and ensure they're on `$PATH`. Run `nvim` and
everything SHOULD work after lazy does its magic.

If you want to use a language server which isn't configured, copy one of the
simpler LSP configuration files in `lsp/` (eg. `clangd.lua`) and name it after
your language server, then replace all the appropriate variables.

## Keymaps

| map                | action                                    |
| ------------------ | ----------------------------------------- |
| `<C-j>` `<C-k>`    | Next and previous window in tabpage.      |
| `<C-h>` `<C-l>`    | Next and previous tabpage.                |
| `jj`               | Exit insert mode.                         |
| `<esc><esc>`       | Exit terminal mode.                       |
| `<leader>p`        | Paste from system clipboard.              |
| `<leader>y`        | Yank to system clipboard.                 |
| `<tab>` `<S-tab>`  | Select completion item, move in snippets. |
| `U`                | Redo.                                     |
| `_`                | Open current working directory buffer.    |
| `-`                | Open parent of the current buffer.        |
| `<lesder>ss`       | Sets spelling for the current window.     |
| `<leader>sh`       | Sets hlsearch globally.                   |

## Native Plugins

These files are relatively brief. It is recommended that if you want to use
their features, you read the full help file, as they will provide insight into
how to use them and what might go wrong when using them.

- *calendir* `:h calendir.txt` provides calendar and journal functionality
- *fex* `:h fex.txt` lets you edit the file system like a buffer
- *lines* customizes the status line and tab line
- *lsp* sets up native vim language server functionality and tab completion
- *pairs* `:h pairs.txt` provides autopairs and surrounds
- *pick* `:h pick.txt` pick from lists of things
- *projects* `:h projects.txt` makes it easy to open projects quickly
- *scratch* `:h scratch.txt` access to scratch buffers of any file type

## External Plugins

This configuration aims to minimize dependencies. This means that as many
plugins as possible will be gradually removed and replaces with vim-style
`plugin/` files.

### Lazy

Until Neovim releases a stable version with `vim.pack`, lazy is going to be used
as the package manager for this repo. Or rather, I will use it if I have
packages to manage. I don't see the others being removed anytime soon, so it's
going to stay until `vim.pack` is stable.

### Tree-Sitter

To implement tree-sitter support, this configuration uses
https://github.com/nvim-treesitter/nvim-treesitter/tree/main (note the use of
the main branch). It would be possible to drop this plugin and instead manually
define the functionality in a plugin alongside manually making the queries like
with `lsp/`, but query files are a lot more complex than language server
configuration files. For this reason, I've decided that this dependency is
simply practical.
