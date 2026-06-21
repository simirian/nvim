This is my Neovim configuration. It aims to be fairly minimal in external
dependencies, both for security and consistency reasons. Also it's just fun to
feel yourself making progress on something.

This configuration uses a more classic vim style, with library modules in `lua/`
and plugin modules in `plugin/`. This is better than putting everything in
`lua/` because if a plugin breaksit will only stop loading that plugin instead
of breaking everything.

# Install

Install the latest version of Neovim. (Older versions are untested but may
work.) Clone this repo into your Neovim configuration directory. Install the
language servers you will be using from your package manager/their downloads
page, and ensure they're on `$PATH`. Run `nvim` and `:TSInstall` all of the
relevant grammars you want, then `:restart` to reload everything after the
plugins and grammars are installed.

If you want to use a language server which isn't configured already, copy one of
the simpler LSP configuration files in `lsp/` (eg. `clangd.lua`) and name it
after your language server, then replace all the appropriate variables.

# Keymaps

These are the keymaps which are defined in `init.lua`. There are some keymaps
which are defined in each of the plugins, the plugin's help files should be used
to lean about what those keymaps are and how to use those plugins.

| map               | action                                    |
| ----------------- | ----------------------------------------- |
| `<C-j>` `<C-k>`   | Next and previous window in tabpage.      |
| `<C-h>` `<C-l>`   | Next and previous tabpage.                |
| `jj`              | Exit insert mode.                         |
| `<esc><esc>`      | Exit terminal mode.                       |
| `<leader>p`       | Paste from system clipboard.              |
| `<leader>y`       | Yank to system clipboard.                 |
| `<tab>` `<S-tab>` | Select completion item, move in snippets. |
| `U`               | Redo.                                     |
| `_`               | Open current working directory buffer.    |
| `-`               | Open parent of the current buffer.        |
| `<leader>ss`      | Sets spelling for the current window.     |
| `<leader>sh`      | Sets `'hlsearch'` globally.               |
| `<leader>sw`      | Toggles wrapping in the current window.   |

# Native Plugins

These files are relatively brief. It is recommended that if you want to use
their features, you read the full help file, as they will provide insight into
how to use them and what might go wrong when using them.

- *calendir* `:h calendir.txt` provides calendar and journal functionality
- *fex* `:h fex.txt` lets you edit the file system like a buffer
- *lines* customizes the status line and tab line
- *lsp* sets up native vim language server functionality and autocompletion
- *pairs* `:h pairs.txt` provides automatic pairing and surround operator
- *pick* `:h pick.txt` pick from lists of things
- *projects* `:h projects.txt` makes it easy to open projects quickly
- *scratch* `:h scratch.txt` access to scratch buffers of any file type

# Tree-Sitter

To implement tree-sitter support, this configuration uses
https://github.com/nvim-treesitter/nvim-treesitter/tree/main (note the use of
the main branch). It would be possible to drop this plugin and instead manually
define the functionality in a plugin alongside manually making the queries like
with `lsp/`, but query files are a lot more complex than language server
configuration files. For this reason, I've decided that this dependency is
simply practical.
