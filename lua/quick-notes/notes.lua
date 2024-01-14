local utils = require('quick-notes.utils');

local M = {};

-- @class Notes
-- @field dir string
-- @field file_type string
-- @field files table
local Notes = {};

-- @param dir string
-- @param file_type string
function M:init(dir, file_type)
	Noted = {};
	Notes.dir = vim.fn.expand('$HOME') .. dir;
	Notes.file_type = file_type;
	Notes.files = {};
end

-- @return table
function M:getNotes()
	return Notes.files;
end

-- @param note_name string
-- @return string
function M:new(note_name)
	local note_file = Notes.dir .. "/" .. note_name .. '.' .. Notes.file_type;

	io.open(vim.fn.expand("$HOME") .. note_file, "w"):close();

	return note_file;
end

-- @param note string
function M:openNote(note)
	local notePath = vim.fn.expand("$HOME") .. Notes.dir .. '/' .. note .. Notes.file_type;

	-- TODO: open the note
end

function M:openLastNote()
	if Notes.last_note == nil then
		return;
	end

	vim.cmd("e " .. Notes.last_note);
end

function M:browse()
	vim.cmd("vslit e " .. vim.expand("$HOME") .. Notes.dir)
end

function M:refreshFromDisk()
	local dirData = vim.fn.readdir(Notes['dir']);

	for i, item in pairs(dirData) do
		if string.find(item, '.' .. Notes['file_type']) ~= nil then
			table.insert(Notes.files, item)
		else
			print('sub item');
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

	for i, item in pairs(dirData) do
		if string.find(item, '.' .. Notes['file_type']) ~= nil then
			table.insert(dataToReturn, dir .. '/' .. item)
		else
			utils:mergeTables(dataToReturn, self:readSubDirContent(dir .. '/' .. item));
		end
	end

	return dataToReturn;
end

return M;
