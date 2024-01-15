local notes = require("quick-notes.notes");
local view = require("quick-notes.view");

-- @class QuickNotesSettings
-- @field notes_dir string
-- @field note_file_extension string
-- @field open_command string
local QuickNotes = {};

-- @param self QuickNotes
-- @param ops QuickNotesOptions | nil
-- @return QuickNotes
function QuickNotes:setup(self, ops)
	if ops == nil then
		QuickNotes.notes_dir = "/QuickNotes";
		QuickNotes.note_file_extension = ".md";
		QuickNotes.open_command = "vsplit";
	else
		QuickNotes = ops;
	end

	notes:init(QuickNotes.notes_dir, QuickNotes.note_file_extension);
	view:init();

	return self;
end

function QuickNotes:toggleNotesMenu()
	notes:refreshFromDisk();

	local win_id, buffr = view:toggleQuickMenu(notes:getNotes())

	if win_id ~= nil and buffr ~= nil then
		vim.keymap.set("n", "n", function()
			view:toggleQuickMenu();
			notes:new()
		end, { buffer = buffr, silent = true });

		vim.keymap.set("n", "<CR>", function()
			local selected_file = vim.api.nvim_get_current_line();

			view:toggleQuickMenu();
			notes:openNote(selected_file);
		end, { buffer = buffr, silent = true });

		vim.keymap.set("n", "b", function()
			view:toggleQuickMenu();
			notes:browse();
		end, { buffer = buffr, silent = true });

		vim.keymap.set("n", "d", function()
			local selected_file = vim.api.nvim_get_current_line();

			notes:delete(selected_file);
			view:setBufferContent(notes:getNotes());
		end, { buffer = buffr, silent = true });
	end
end

function QuickNotes:openLastNote()
	notes:openLastNote();
end

function QuickNotes:new()
	notes:new();
end

function QuickNotes:browse()
	notes:browse();
end

return QuickNotes;
