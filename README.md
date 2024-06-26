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

### Normal mode

| map | action |
| --- | --- |
| `ctrl` + [`hjkl`] | Switches to the window in that direction. |
| `ctrl` + [arrow] | Use the arrow keys to resize windows. |
| `alt` + [`jk`] | Moves the current line up or down. |
| `leader` > `p` | Paste from system clipboard. |
| `gT` | Create new tabs. |
| `U` | Redo more easily and override the horrible revert line binding. |
| `leader` > `e` | Open popup file explorer. |

#### Telescope

Begin telescope mappings with the keybind `leader` > `f`, then continue with
one of the following:

| map | action |
| --- | --- |
| `f` | Open telescope file finder. |
| `g` | Open telescope grep finder. |
| `h` | Open telescope help file search. |
| `b` | Open telescope buffer finder. |
| `p` | Open nvim-manager projects picker. |

### Insert mode

| map | action |
| --- | --- |
| `jk`\|`kj` | Exit insert mode quickly. |

### Visual mode

| map | action |
| --- | --- |
| `p` | Paste over without ruining yank registries. |
| `leader` > `p` | Paste from system clipboard. |
| `leader` > `y` | Copy to system clipboard. |
| `alt` + `j` | Move selected lines down. |
| `alt` + `k` | Move selected lines up. |

## Commands

| command | action |
| --- | --- |
| `:Update` | Updates mason, treesitter, and lazy. |
| `:BufInfo` | Prints basic buffer info. |

