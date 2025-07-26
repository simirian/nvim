# NeoVim

simirian's NeoVim configuration

## Install

Install the latest version of NeoVim. (Older versions are untested but may
work.) Run `git clone https://github.com/simirian/nvim` in your configuration
directory. Run NeoVim like normal (`nvim`), and everything SHOULD be installed.

## Keymaps

| map                | action                                      |
| ------------------ | ------------------------------------------- |
| `<C-j>`, `<C-k>`   | Next and previous window in tabpage.        |
| `<C-h>`, `<C-l>`   | Next and previous tabpage.                  |
| `jj`               | Exit insert mode.                           |
| `<esc><esc>`       | Exit terminal mode.                         |
| `<leader>p`        | Paste from system clipboard.                |
| `<leader>y`        | Yank to system clipboard.                   |
| `<tab>`, `<S-tab>` | Invoke completion or indentation in insert. |
| `U`                | Redo.                                       |
| `_`                | Open vim's current directory.               |
| `-`                | Open buffer's parent directory.             |
| `s`, `ss`          | Surround operator, see below.               |
| `ds`               | Delete surroundings, see below.             |
| `cs`               | Change surroundings, see below.             |
| `<leader>ff`       | Telescope find files.                       |
| `<leader>fg`       | Telescope live grep.                        |
| `<leader>fb`       | Telescope buffers.                          |
| `<leader>fh`       | Telescope help.                             |

## Commands

| command       | action                                  |
| ------------- | --------------------------------------- |
| `:Toc`        | Table of contents support for markdown. |
| `:Today`      | Open today's daily note.                |
| `:Yesterday`  | Open yesterday's daily note.            |
| `:Scratch`    | Open a scratch buffer.                  |
| `:AnnabelLee` | Open a scratch buffer with Annabel Lee. |

## Modules

### pairs.lua

The first feature of the pairs module is automatic pair completion. When you
finish typing an opening marker of any type, the closing marker will be
automatically inserted after your cursor. Pressing enter between matching
opening and closing markers will cause the second marker to be moved down two
lines and the cursor to be placed on a blank line between the two markers with
correct indentation. Pressing backspace in the middle of a pair of only
single-character markers will automatically delete the opening and closing
marker.

The second feature of the pairs module is the surround functionality.
Surrounding relies on three operations, adding, changing, and deleting. To add
surroundings, you use the `s` operator or `ss` to apply the operator to the
current line. Once triggered, "s" will be printed to the command line and the
operator will expect you to select a marker set by typing a character (see table
below). If the character is not associated with any markers, then the operator
will finish without doing anything.

| character         | markers          |
| ----------------- | ---------------- |
| `(`, `)`          | Parentheses.     |
| `[`, `]`          | Brackets.        |
| `{`, `}`          | Braces.          |
| `<`, `>`          | Angles.          |
| `"`, `'`, `` ` `` | Various quotes.  |
| `t`, `T`          | HTML / XML tags. |
| `p`, `P`          | Prompt for text. |

If the marker set is named after a closing character (eg. `]`) or capital letter
then spaces will be added between the text and the markers which get added.
Opening characters and lowercase letter marker sets do not add spaces around the
operator selection. Entering the character `t` or `T` will prompt you in the
command line with that character. Type any text and it will be inserted in HTML
/ XML tags as the tag name. Entering `p` or `P` will prompt you for any text,
which will be literally inserted as the opening and closing marker.

To delete surroundings of the cursor, place the cursor within (not on) the
surroundings that you want to delete. Use the `ds` keymap. The keymap will print
"ds" to the command line and expect you to type a marker set name like with `s`.
If the opening marker does not appear before the cursor or the closing marker
does not appear after the cursor then the keymap will do nothing. The markers
will be deleted if they are found. Using a marker set with internal spaces (eg.
`]`) will trim all spacing between the markers and the internal text.

Changing the cursor's surroundings is almost identical to deleting the cursor's
surroundings. Use the keymap `cs`, it will print "cst" and expect you to choose
a target marker set like usual. If those markers are found in the current line,
it will print "scr", which means the keymap needs another marker set to use for
replacement.

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
    - [x] delete surrounds
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
