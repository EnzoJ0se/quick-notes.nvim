local notes = require("quick-notes.notes");
local view = require("quick-notes.view");


local QuickNotesGroup = vim.api.nvim_create_augroup("QuickNotes", {})

-- @class QuickNotesSettings
-- @field notes_dir string
-- @field note_file_extension string
-- @field open_command string
-- @field augroup_id number
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

function QuickNotes:toggleNotesMenu()
	notes:refreshFromDisk();

	local win_id, buffr = view:toggleView(notes:getNotes())

	if win_id ~= nil and buffr ~= nil then
		vim.keymap.set("n", "n", function()
			view:toggleView();
			notes:new()
		end, { buffer = buffr, silent = true });

		vim.keymap.set("n", "<CR>", function()
			local selected_file = vim.api.nvim_get_current_line();

			view:toggleView();
			notes:openNote(selected_file);
		end, { buffer = buffr, silent = true });

		vim.keymap.set("n", "b", function()
			view:toggleView();
			notes:browse();
		end, { buffer = buffr, silent = true });

		vim.keymap.set("n", "d", function()
			local selected_file = vim.api.nvim_get_current_line();

			notes:delete(selected_file);
			view:setBufferContent(notes:getNotes());
		end, { buffer = buffr, silent = true });

		vim.keymap.set("n", "p", function()
			local selected_file = vim.api.nvim_get_current_line();

			view:toggleView();
			self:toggleFilePreview(selected_file);
		end, { buffer = buffr, silent = true });
	end
end

-- @param note_name string
function QuickNotes:toggleFilePreview(note_name)
	local win_id, buffr = view:toggleView(notes:getNoteContent(note_name), note_name);

	if win_id ~= nil and buffr ~= nil then
		vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buffr })

		vim.api.nvim_buf_set_name(buffr, QuickNotes.notes_dir .. "/" .. note_name);

		vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
			group = QuickNotesGroup,
			buffer = buffr,
			callback = function()
				notes:saveNote(note_name, view:getBufferContent());
			end,
		})
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
