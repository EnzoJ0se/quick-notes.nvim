local utils = require('quick-notes.utils');

local M = {};

-- @class Notes
-- @field dir string
-- @field file_type string
-- @field files table
-- @field last_note string
-- @field open_command string
local Notes = {};

-- @param dir string
-- @param file_type string
-- @param open_command? string
function M:init(dir, file_type, open_command)
	Notes = {};
	Notes.dir = vim.fn.expand('$HOME') .. dir;
	Notes.file_type = file_type;
	Notes.files = {};
	Notes.open_command = (open_command or "vsplit") .. " ";
end

-- @return table
function M:getNotes()
	return Notes.files;
end

-- @return string
function M:new()
	local note_name = vim.fn.input("Note name: ");

	local note_file = Notes.dir .. "/" .. note_name .. Notes.file_type;

	Notes.last_note = note_file;
	io.open(note_file, "w"):close();
	vim.cmd(Notes.open_command .. note_file);

	return note_file;
end

-- @param note string
function M:openNote(note)
	local notePath = Notes.dir .. '/' .. note;

	Notes.last_note = notePath;
	vim.cmd(Notes.open_command .. notePath);
end

function M:openLastNote()
	if Notes.last_note == nil then
		return;
	end

	vim.cmd(Notes.open_command .. Notes.last_note);
end

function M:browse()
	vim.cmd("e " .. Notes.dir)
end

-- @param note string
function M:delete(note)
	local notePath = Notes.dir .. '/' .. note;

	vim.fn.delete(notePath);

	M:refreshFromDisk();
end

--@param note_name string
function M:getNoteContent(note_name)
	if vim.fn.getfsize(Notes.dir .. '/' .. note_name) <= 0 then
		return nil;
	end

	return vim.fn.readfile(Notes.dir .. '/' .. note_name);
end

function M:refreshFromDisk()
	Notes.files = {};

	local dirData = vim.fn.readdir(Notes['dir']);

	for _, item in pairs(dirData) do
		if string.find(item, '.' .. Notes['file_type']) ~= nil then
			table.insert(Notes.files, item)
		else
			utils:mergeTables(Notes.files, self:readSubDirContent(item));
		end
	end

	return Notes
end

-- @param dir string
-- @return table
function M:readSubDirContent(dir)
	local dirData = vim.fn.readdir(Notes['dir'] .. '/' .. dir);
	local dataToReturn = {};

	for _, item in pairs(dirData) do
		if string.find(item, '.' .. Notes['file_type']) ~= nil then
			table.insert(dataToReturn, dir .. '/' .. item)
		else
			utils:mergeTables(dataToReturn, self:readSubDirContent(dir .. '/' .. item));
		end
	end

	return dataToReturn;
end

-- @param note_name string
-- @param content string
function M:saveNote(note_name, content)
	require("plenary.path"):new(Notes.dir .. '/' .. note_name):write(content, "w+")
end

return M;
