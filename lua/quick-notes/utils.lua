M = {};

-- @param base_table table
-- @param merge_table table
function M:mergeTables(base_table, merge_table)
	for i, item in pairs(merge_table) do
		table.insert(base_table, item)
	end
end


return M;
