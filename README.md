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
| `_`                | Open vim's current directory.             |
| `-`                | Open buffer's parent directory.           |
| `s`, `ss`          | Surround operator, see below.             |
| `ds`               | Delete surroundings, see below.           |
| `cs`               | Change surroundings, see below.           |
| `<leader>ff`       | Telescope find files.                     |
| `<leader>fg`       | Telescope live grep.                      |
| `<leader>fb`       | Telescope buffers.                        |
| `<leader>fh`       | Telescope help.                           |

## Commands

| command       | action                                  |
| ------------- | --------------------------------------- |
| `:Today`      | Open today's daily note.                |
| `:Yesterday`  | Open yesterday's daily note.            |
| `:Scratch`    | Open a scratch buffer.                  |
| `:AnnabelLee` | Open a scratch buffer with Annabel Lee. |

## Native Plugins

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

### projects.lua

The projects module lets you easily navigate to project directories. It exposes
several useful commands all accessible through the `:Project` interface, which
let you manipulate the saved and included projects as well as open them.

Saved projects persist through restarts of vim are manually saved buy the user
with the `Project add NAME` command. This command saves vim's current directory
as a project with the given name. Saved projects can be forgotten with the
`Project remove NAME` command, which can also remove the current project if
`NAME` is not provided.

Included projects are found as subdirectories of the include directory list. By
default, only `~/Source/` is included. Every directory which is a subdirectory
of an include directory will be added to the list of projects, with it's name as
the project name. If conflicts arise, saved projects take precedence and include
directories are used in random order. Include directories can be updated with
the `Project include DIR` and `Project exclude DIR` commands.

To open a project, it's as simple as running the `Project open NAME` command.
This will only `:cd` to the directory associated with that project name, either
the directory where you saved it from if it's a saved project or the directory
where it was found if the project was included.

### fex.lua

This module allows you to easily edit directories like normal buffers. When you
edit a directory, the contents of that directory will be replaced with a single
line for each visible file. The keymap `gh` can be used to toggle visibility of
dot-files. Pressing `<cr>` on any line in a fex buffer which contains an
existing file will open that file in a buffer, and even dereference symlinks.
File manipulation is as simple as editing the lines in the buffer, except
changes are only made to the file system after you `:w` write the buffer, so
long as it's in a valid state and you confirm the changes.

Each line in the buffer which was placed automatically starts with the pattern
`/#\t` where `#` is a hexadecimal number. This is the global ID of that line,
which is needed so the module can keep track of which files come from where.
When writing, lines without the starting patten are treated like new files, so
new files can be easily created with the default `o` keymap. Files can be copied
by yanking whole lines with `yy` or `V` and then pasting them elsewhere. To
rename a file, just change any of the text after the starting pattern. Removing
a file is as simple as deleting its line.

Fex tries to ensure you don't do anything which could cause confusing or
erroneous results. For this reason, a validation step takes place before it even
asks you to confirm your changes. If you've edited fex buffers so that a single
path gets written to multiple times, then fex will notify you there's a
"Miultiply defined target". This might happen if you have the line "dir/file" in
`./` and "file" in `./dir`. Both lines refer to the same target file, but they
each might have a different source, which would make the result of a write
ambiguous.

Fex also refuses to do anything with a directory when its children are modified.
With some complicated logic, this would probably not be a problem, but fex aims
to be simple. The main concern in this case is that if you copy a directory
*and* change its contents, it's unclear if the copy should have the changes or
not. Rather than implement advanced logic and come up with arbitrary defaults to
exceptional cases, fex just demands that the user manually solve these problems
with an error that says "Modified child of modified directory".

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
    - [x] automatic live completion
    - [x] snippet completion
- [ ] `lazy.nvim` -> git sub-modules
    - this shouldn't be too hard with git sub-modules
- [ ] `telescope.nvim`, `plenary.nvim` -> `select` (use `vim.ui.select`)
    - this is a monumental task and will probably be one of the last things to
      get replaced
- [ ] `nvim-treesitter`
    - I don't actually think this is practical to remove
- [ ] `nvim-web-devicons`
    - again, I don't actually think this is practical to remove
