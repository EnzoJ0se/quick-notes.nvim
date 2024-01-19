# quick-notes.nvim
A pluggin to create, list and view custom notes.

> [!IMPORTANT]  
>This plugin was made for educational purposes, and personal use. It's my first plugin made to learn lua and nvim plugin development
---
### Instalation
```lua
{
    "EnzoJ0se/quick-notes.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
}
```
---
### Basic Setup
```lua
local quickNotes = require('quick-notes');

-- Setup call is required.
--
-- OPTS EXAMPLE 
-- @field notes_dir string (base dir to store notes)
-- @field note_file_extension string (the notes file extension, by defualt it's .md)
-- @field open_command string (the command used to open files, by default it's "e")
quickNotes:setup();

vim.keymap.set("n", "<leader>qq", function() quickNotes:toggle() end, { desc = 'Toggle Quick Menu' });
vim.keymap.set("n", "<leader>ql", function() quickNotes:openLastNote() end, { desc = 'Open last open note' });
vim.keymap.set("n", "<leader>qn", function() quickNotes:new() end, { desc = 'Create new note on notes_dir' });
vim.keymap.set("n", "<leader>qb", function() quickNotes:browse() end, { desc = 'Browse to notes dir using Netrw' });
```
---
### Quick Menu Keymaps
- `<C-n>`: Create new note;
- `<C-b>`: Browse to notes dir;
- `<C-o>`: Open the note under the cursor in preview window;
- `<C-v>`: Split the note under the cursor in a new window;
- `<C-d>`: Delete the note under the cursor;
- `<ESC>` or `q`: to close the  Menu";
---
