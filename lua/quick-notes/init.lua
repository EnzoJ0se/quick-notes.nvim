local notes = require("quick-notes.notes");
local view = require("quick-notes.view");

-- @class QuickNotesSettings
-- @field notes_dir string
-- @field note_file_extension string
-- @field last_note string
local QuickNotes = {};

-- @param self QuickNotes
-- @param ops QuickNotesOptions | nil
-- @return QuickNotes
function QuickNotes:setup(self, ops)
	if ops == nil then
		QuickNotes.notes_dir = "/QuickNotes";
		QuickNotes.note_file_extension = ".md";
	else
		QuickNotes = ops;
	end

	notes:init(QuickNotes.notes_dir, QuickNotes.note_file_extension);
	view:init();

	return self;
end

function QuickNotes:toggleNotesMenu()
	notes:refreshFromDisk();

	view:toggleQuickMenu(notes:getNotes())
end


return QuickNotes;
