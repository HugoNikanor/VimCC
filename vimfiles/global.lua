local globals = {
	termX = 0,
	termY = 0,
	hasChanged = false,
	fileName = "",
	currentLine = 1,
	currentColumn = 1,
	-- Used when scrolling between lines
	-- note that this still doesn't behave
	-- exactly like the real deal. See one char lines
	-- and last character on line
	actualColumn = 1,

	topLine = 1,
	running = true,
}

function getVar(key)
	local temp = globals[key]
	if temp == nil then
		error("get:no such key: " .. key)
	end
	return globals[key]
end

function setVar(key, value)
	local temp = globals[key]
	if temp == nil then
		error( "set:no such key: " .. key )
	end
	if value == nil then
		error( "you forgot the value: " .. key )
	end
	globals[key] = value
end

------------------------------

local lines = {}
local length = 0

function getLines()
	return lines
end

-- screen uses the possible nil value that this may return
function getLine(lineNo)
	return lines[lineNo]
end

function getCurLine()
	return lines[globals["currentLine"]];
end

function setCurLine( text )
	lines[globals["currentLine"]] = text
end

function setLine(lineNo, text)
	lines[lineNo] = text
end

function setLines(inLines)
	lines = inLines
	length = #lines
end

function removeLine(lineNo)
	table.remove(lines, lineNo)
	length = length - 1
end

function insertLine( pos, text )
	table.insert(lines, pos, text)
	length = length + 1
end

function getLength()
	return length
end
