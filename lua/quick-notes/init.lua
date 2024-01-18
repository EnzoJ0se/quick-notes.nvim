local notes = require("quick-notes.notes");
local view = require("quick-notes.view");
local utils = require("quick-notes.utils");

local QuickNotesGroup = vim.api.nvim_create_augroup("QuickNotes", {})

-- @class QuickNotesSettings
-- @field notes_dir string
-- @field note_file_extension string
-- @field open_command string
-- @field augroup_id number
-- @field is_quick_menu_open boolean
-- @field is_file_preview_open boolean
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

	QuickNotes.augroup_id = QuickNotesGroup;
	notes:init(QuickNotes.notes_dir, QuickNotes.note_file_extension);
	view:init();

	QuickNotes.view = view;

	return self;
end

function QuickNotes:toggle()
	if QuickNotes.is_file_preview_open then
		QuickNotes:toggleFilePreview();
	end

	QuickNotes:toggleNotesMenu();
end

function QuickNotes:toggleNotesMenu()
	if QuickNotes.is_quick_menu_open then
		view:toggleView();
		QuickNotes.is_quick_menu_open = false;

		return;
	end

	notes:refreshFromDisk();

	local header = {
		"============================================================================================",
		"C-N = New Note | C-B = Browse Notes | C-O = Open  Note  | C-D = Delete Note | Q = Close Menu",
		"============================================================================================",
	};

	local content = notes:getNotes();
	table.insert(content, 1, header[3]);
	table.insert(content, 1, header[2]);
	table.insert(content, 1, header[1]);

	local win_id, buffr = view:toggleView(content)

	if win_id ~= nil and buffr ~= nil then
		QuickNotes.is_quick_menu_open = true;
		view:setMenuKeyMaps(QuickNotes);

		return;
	end

	QuickNotes.is_quick_menu_open = false;
end

-- @param note_name? string
function QuickNotes:toggleFilePreview(note_name)
	if QuickNotes.is_file_preview_open then
		view:toggleView();
		QuickNotes.is_file_preview_open = false;

		return;
	end

	if not notes:isValidNote(note_name) then
		return;
	end


	local win_id, buffr = view:toggleView(notes:getNoteContent(note_name), {
		title = note_name,
		row = 1,
		height = 40,
	});

	if win_id ~= nil and buffr ~= nil then
		QuickNotes.is_file_preview_open = true;

		vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buffr.id })
		vim.api.nvim_buf_set_name(buffr.id, QuickNotes.notes_dir .. "/" .. note_name);
		vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
			group = QuickNotesGroup,
			buffer = buffr.id,
			callback = function()
				notes:saveNote(note_name, view.buffr:getBufferContent());
			end,
		})

		return;
	end

	QuickNotes.is_file_preview_open = false;
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
