function redraw()
	--term.clear()
	term.setCursorPos(1, 1)

	local topLine = global.getVar("topLine")
	local lineskip = 0

	-- TODO maybe this should, like the real vim, have that when a line is
	-- to long to render instead an '@' shows up indicating that there is more
	-- TODO also, then a line as longer than the number of characters on the screen,
	-- displaying lines before the lines breaks down
	-- 
	-- This is a while loop to be able to do the check is go around
	local i=topLine
	while i <= topLine + global.getVar("termY") - 2 - lineskip do
		term.clearLine()
		local tLine = global.getLine(i)
		if tLine ~= nil then
			for l=1, string.len(tLine) do
				if i == global.getVar("currentLine") and
				   l == global.getVar("currentColumn") then
					term.blit(tLine:sub(l,l), "f", "0")
				else
					term.write(tLine:sub(l,l))
				end
				if l % global.getVar("termX") == 0 then
					lineskip = lineskip + 1
					io.write("\n")
					term.clearLine()
				end
			end
			-- if inputing data at the end of the line
			if global.getVar("currentColumn") == string.len(tLine) + 1 and
			   global.getVar("currentLine") == i then
				term.blit(" ", "f", "0")
			end
		else
			io.write("~")
		end
		io.write("\n")
		i = i + 1
	end
end

-- for error messages shown at the bottom of the screen
function echoerr( message )
	term.setCursorPos(1, global.getVar("termY"))
	if term.isColor() then
		term.setBackgroundColour( colors.red )
	end
	term.write( message )
	if term.isColor() then
		term.setBackgroundColour( colors.black )
	end
end

-- for other messages to be shown at the bottom of the screen
function echo( message )
	term.setCursorPos(1, global.getVar("termY"))
	term.write( message )
end

-- returns false if line couldn't be redrawn
function redrawLine( lineNo )
	local topLine = global.getVar("topLine")
	local line = global.getLine( lineNo )

	if lineNo < topLine then
		return false
	end
	if lineNo >= topLine + global.getVar("termX") then
		return false
	end

	local positionOnScreen = lineNo - topLine
	for i=topLine, lineNo do
	end
end

function drawLine( lineNo )
	local tLine = global.getLine( lineNo )
	for l=1, string.len(tLine) do
		if i == global.getVar("currentLine") and
		   l == global.getVar("currentColumn") then
			term.blit(tLine:sub(l,l), "f", "0")
		else
			term.write(tLine:sub(l,l))
		end
		if l % global.getVar("termX") == 0 then
			lineskip = lineskip + 1
			io.write("\n")
		end
	end
end

function debug( message )
	term.setCursorPos(global.getVar("termX") - string.len(message) + 1,
	                  global.getVar("termY"))
	if message==nil then
		term.write("nil")
	else
		term.write(message)
	end
	os.pullEvent("key")
end


