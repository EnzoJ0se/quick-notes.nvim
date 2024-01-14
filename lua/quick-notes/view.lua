local M = {};

-- @class ViewSettings
-- @field width_ratio number
-- @field win_id number
local ViewSettings = {};

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

	self.win_id = win;

	return win, buffer
end

--@param content table
function M:toggleQuickMenu(content)
	local win_id, buffr = M:createView(nil, table.getn(content));

	vim.api.nvim_buf_set_lines(buffr, 0, -1, true, content)

	return win_id, buffr
end

return M;
