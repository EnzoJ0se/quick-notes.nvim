-- @class Buffer
-- @field id number
local Buffer = {}

-- @return Buffer
function Buffer:new()
	Buffer.id = vim.api.nvim_create_buf(false, true);

	return Buffer;
end

function Buffer:close()
	if vim.api.nvim_buf_is_valid(Buffer.id) then
		vim.api.nvim_buf_delete(Buffer.id, { force = true });
	end

	Buffer.id = nil;
end

-- @param content string
function Buffer:setBufferContent(content)
	vim.api.nvim_buf_set_lines(Buffer.id, 0, -1, true, content)
end

-- return string
function Buffer:getBufferContent()
	local data = vim.api.nvim_buf_get_lines(Buffer.id, 0, -1, true);
	local content = "";

	for _, line in pairs(data) do
		if line ~= nil then
			content = content .. line .. "\n";
		end
	end

	return content;
end

return Buffer;
