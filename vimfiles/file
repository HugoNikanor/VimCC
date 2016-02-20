function write()
	local file = fs.open(global.getVar("fileName"), "w")
	for i=1, global.getLength() do
		-- TODO this crashes if the file is write only
		file.writeLine(global.getLine(i))
	end
	file.close()

	global.setVar("hasChanged", false)
end

--[[
	Returns the contents of the set file in a table
	of strings
]]--
function read(path)
	local file = io.open(global.getVar("fileName"), "r")
	local lines = {}
	if fs.exists( global.getVar("fileName") ) then
		local tempLine = file:read()

		while tempLine ~= nil do
			lines[#lines + 1] = tempLine
			tempLine = file:read()
		end
		file:close()

		-- inserts a new line if the file is complealty empty
		if( lines[1] == nil ) then
			lines[#lines + 1] = ""
		end
	else
		lines[#lines + 1] = ""
	end
	return lines
end
