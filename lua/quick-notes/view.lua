local buffer = require("quick-notes.buffer");
local notes = require("quick-notes.notes");

-- @class ViewSettings
-- @field width_ratio number
-- @field title string
-- @field row number
-- @field col number
-- @field height number
local ViewSettings = {};

-- @class View
-- @field settings ViewSettings
-- @field win_id number
-- @field buffr buffer
-- @field is_closing boolean
local View = {};

-- @param opts? ViewSettings|nil
function View:init(opts)
	if opts then
		View.settings = opts;
	else
		View.settings = { width_ratio = 0.80 };
	end
end

-- @param opts ViewSettings
-- return number, buffer
function View:createView(opts)
	local view = vim.api.nvim_list_uis();
	local width = math.floor(view[1].width * (View.settings.width_ratio or 0.8));

	local buffr = buffer:new();

	local win = vim.api.nvim_open_win(buffer.id, true, {
		relative = "editor",
		title = opts.title or "Notes",
		title_pos = "",
		row = opts.row or 8,
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = opts.height or 10,
		style = "minimal",
		border = "rounded",
	});

	View.win_id = win;
	View.buffr = buffr;

	return win, buffer
end

function View:closeView()
	if View.is_closing then
		return;
	end

	View.is_closing = true;

	if View.buffr ~= nil then
		View.buffr:close();
	end

	if View.win_id ~= nil and vim.api.nvim_win_is_valid(View.win_id) then
		vim.api.nvim_win_close(View.win_id, true);
	end

	View.win_id = nil;
	View.buffr = nil;
	View.is_closing = false;
end

-- @param content? table
-- @param opts ViewSettings
-- @return number, buffer
function View:toggleView(content, opts)
	if View.win_id ~= nil then
		View:closeView();

		return nil, nil;
	end

	local win_id = View:createView(opts or { row = table.getn(content or {}) });

	if content ~= nil then
		View.buffr:setBufferContent(content);
	end

	vim.keymap.set("n", "q", function() View:toggleView() end, { buffer = View.buffr.id, silent = true });
	vim.keymap.set("n", "<ESC>", function() View:toggleView() end, { buffer = View.buffr.id, silent = true });

	vim.api.nvim_create_autocmd({ "BufLeave" }, {
		group = require("quick-notes").augroup_id,
		buffer = View.buffr.id,
		callback = function()
			require("quick-notes").view:toggleView()
		end,
	})

	return win_id, buffer
end

-- @param quick_notes quick_notes
function View:setMenuKeyMaps(quick_notes)
	vim.keymap.set("n", "<CR>", function()
		local selected_file = vim.api.nvim_get_current_line();

		quick_notes:toggleNotesMenu()
		notes:openNote(selected_file);
	end, { buffer = View.buffr.id, silent = true });

	vim.keymap.set("n", "<C-n>", function()
		quick_notes:toggleNotesMenu()
		notes:new()
	end, { buffer = View.buffr.id, silent = true });

	vim.keymap.set("n", "<C-b>", function()
		quick_notes:toggleNotesMenu()
		notes:browse();
	end, { buffer = View.buffr.id, silent = true });

	vim.keymap.set("n", "<C-d>", function()
		local selected_file = vim.api.nvim_get_current_line();

		if not notes:isValidNote(selected_file) then
			return;
		end

		notes:delete(selected_file);
		View:setBufferContent(notes:getNotes());
	end, { buffer = View.buffr.id });

	vim.keymap.set("n", "<C-o>", function()
		local selected_file = vim.api.nvim_get_current_line();

		if not notes:isValidNote(selected_file) then
			return;
		end

		quick_notes:toggleNotesMenu();
		quick_notes:toggleFilePreview(selected_file);
	end, { buffer = View.buffr.id, silent = true });
end

return View;
