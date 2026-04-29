# NeoVim Quick Reference

### I. The Basics & Navigation
###### Leader Key: Usually Space. Set via vim.g.mapleader = ' '

## I. Navigation
| Action | Key |
|---|---|
|Move Left, Down, Up, Right|: `h`,`j`,`k`,`l`|
|Next / Previous word |: `w` / `b` |
|End of current word |: `e` |
|Start / End of line |: `0` / `$` |
|First non-blank character|: `^`|
|Top / Bottom of file|: `gg` / `G`|
|Go to line number|: `{num}G`|
|Up / Down half page|: `Ctrl-u` / `Ctrl-d`|
|Center cursor|: `zz`|

## II. Editing
| Action | Key |
|---|---|
|Insert / Append|: `i` / `a`|
|Insert Start / End of line|: `I` / `A`|
|New line below / above|: `o` / `O`|
|Delete line / word|: `dd` / `dw`|
|Change line / word|: `cc` / `cw`|
|Undo / Redo|: `u` / `Ctrl-r`|
|Repeat last change|: `.`|
|Yank (copy) / Paste|: `yy` / `p`|
|Delete character|: `x`|
|Indent / Outdent|: `>>` / `<<`|

## III. Buffer Management
| Action | Key / Command |
|---|---|
|List all buffers|: `:ls`|
|Next / Previous buffer|: `:bn` / `:bp`|
|Go to buffer by number|: `:b {num}`|
|Close current buffer|: `:bd`|
|Go to First / Last buffer|: `:bf` / `:bl`|
|Find open buffers (Telescope)|: `<leader>fb`|

## IV. Windows & Tabs
| Action | Key / Command |
|---|---|
|Vertical / Horizontal split|: `:vsp` / `:sp`|
|Move to window|: `Ctrl-w` + `h/j/k/l`|
|Close current window|: `Ctrl-w` + `c`|
|Only keep current window|: `Ctrl-w` + `o`|
|New tab / Next tab|: `:tabe` / `gt`|

## V. LSP & Plugins
| Action | Key |
|---|---|
|Hover Documentation|: `K`|
|Definition / References|: `gd` / `gr`|
|Rename symbol|: `<leader>rn`|
|Code Action|: `<leader>ca`|
|Find Files (Telescope)|: `<leader>ff`|
|Live Grep (Telescope)|: `<leader>fg`|
|Toggle Comment|: `gcc`|
|Next / Previous Git Hunk|: `]c` / `[c`|

## VI. Commands
| Action | Command |
|---|---|
|Save / Force Quit|: `:w` / `:q!`|
|Save and Quit|: `:wq`|
|Search and Replace|: `:%s/old/new/g`|
|Clear Search Highlight|: `:noh`|

## VII. How to Rename a File
To rename the file you are currently editing:
1.  **Save the file first**: Type `:w` and press `Enter`.
2.  **Rename**: Type `:saveas new_filename.md` and press `Enter`.
3.  **Delete the old copy**: Type `:!rm old_filename.md` (or `:!del` on Windows).
*Alternatively, if using `nvim-tree`: Hover over the file and press `r`.*

## VIII. LSP & Plugins
| Action | Key |
|---|---|
|Hover Documentation|: `K`|
|Definition / References|: `gd` / `gr`|
|Rename symbol (Code)|: `<leader>rn`|
|Code Action|: `<leader>ca`|
|Find Files (Telescope)|: `<leader>ff`|
|Live Grep (Telescope)|: `<leader>fg`|
|Toggle Comment|: `gcc`|