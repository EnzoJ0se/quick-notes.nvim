local M = {};

-- @class ViewSettings
-- @field width_ratio number
local ViewSettings = {};

-- @class NotesWin
-- @field win_id number
-- @field buffr number
-- @field is_closing boolean
local NotesWin = {};

-- @param opts ViewSettings|nil
function M:init(opts)
	if opts then
		ViewSettings = opts
	else
		ViewSettings.width_ratio = 0.80
	end
end

-- @param title string|nil
-- @param rows number
function M:createView(title, rows)
	local view = vim.api.nvim_list_uis();
	local width = math.floor(view[1].width * ViewSettings.width_ratio);

	local buffer = vim.api.nvim_create_buf(false, true);
	local win = vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		title = title or "Notes",
		title_pos = "",
		row = rows,
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = 10,
		style = "minimal",
		border = "single",
	});

	NotesWin.win_id = win;
	NotesWin.buffr = buffer;

	return win, buffer
end

function M:closeView()
	if NotesWin.is_closing then
		return;
	end

	NotesWin.is_closing = true;

	if NotesWin.win_id ~= nil and vim.api.nvim_win_is_valid(NotesWin.win_id) then
		vim.api.nvim_win_close(NotesWin.win_id, true);
	end

	if NotesWin.buffr ~= nil and vim.api.nvim_buf_is_valid(NotesWin.buffr) then
		vim.api.nvim_buf_delete(NotesWin.buffr, { force = true });
	end

	NotesWin.win_id = nil;
	NotesWin.buffr = nil;
	NotesWin.is_closing = false;
end

-- @param content? table
-- @return number, number
function M:toggleQuickMenu(content)
	if NotesWin.win_id ~= nil then
		M:closeView();

		return nil, nil;
	end

	local win_id, buffr = M:createView(nil, table.getn(content));

	vim.api.nvim_buf_set_lines(buffr, 0, -1, true, content)

	vim.keymap.set("n", "q", function() M:toggleQuickMenu() end, { buffer = buffr, silent = true });
	vim.keymap.set("n", "<ESC>", function() M:toggleQuickMenu() end, { buffer = buffr, silent = true });

	return win_id, buffr
end

-- @param content string
function M:setBufferContent(content)
	vim.api.nvim_buf_set_lines(NotesWin.buffr, 0, -1, true, content)
end

return M;
