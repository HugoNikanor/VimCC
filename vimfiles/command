local function getNumber( presses, startPos )
	local noTemp
	local number = ""
	local keyAfter = ""

	local i = startPos
	temp = presses[i]
	while temp ~= nil do
		local tempNo = tonumber( temp )
		if tempNo ~= nil then
			number = number .. tempNo
		else
			keyAfter = temp
			break
		end
		i = i + 1
		temp = presses[i]
	end
	
	if number == "" then
		number = tonumber(1)
	else
		number = tonumber(number)
	end

	return number, i, keyAfter
end

local function parseViCommand( presses ) 
	local numbers = { tonumber(1), tonumber(1) }
	local otherMod

	local sPos = 1
	numbers[1], sPos, otherMod = getNumber( presses, sPos )
	numbers[2] = getNumber( presses, sPos + 1 )

	return otherMod, numbers[1], numbers[2]
end

local function cursorVerticalMove( numberMod )
		local curLine = global.getVar("currentLine") + numberMod

		-- Check how many lines are on the screen
		local linesOnScreen = 0
		local skippedLines = 0
		local i=global.getVar("topLine")
		while i <= global.getVar("topLine") + global.getVar("termY") - 2 - skippedLines do
			if i > global.getLength() then break end
			linesOnScreen = linesOnScreen + 1

			-- Please don't toture me to hard for this
			local ch = math.floor(string.len(global.getLine(i)) / (global.getVar("termX") + 0.000001))
			skippedLines = skippedLines + ch

			i = i + 1

		end

		--logger.info("skippedLines " .. skippedLines)
		--logger.info("linesOnScreen " .. linesOnScreen)

		while curLine < 1 do
			curLine = curLine + 1
		end
		while curLine > global.getLength() do
			curLine = curLine - 1
		end

		-- scroll topLine upwards/downwards until curLine is on the screen
		while curLine < global.getVar("topLine") do
			global.setVar("topLine", global.getVar("topLine") - 1)
		end
		while curLine > global.getVar("topLine") + linesOnScreen - 1 do
			global.setVar("topLine", global.getVar("topLine") + 1)
		end
		global.setVar("currentLine", curLine)

		-- Fix the column if it's to large
		if global.getVar("actualColumn") > global.getVar("currentColumn") then
			global.setVar("currentColumn", global.getVar("actualColumn"))
		end
		local curX = global.getVar("currentColumn")
		local strLen = string.len(global.getLine(curLine))
		if curX > strLen then
			curX = strLen
		end
		if strLen == 0 then
			curX = 1
		end
		global.setVar("currentColumn", curX)
end

goToStart = nil
goToEndOfLine = nil
-- horizontal deletion delets one character less than the cursor moves,
-- This is sometimes useful but most of the time not
local function move( command, numberMod, actionType, otherMod )
	-- merges current line with the next line, removes that line ('J')
	if otherMod == "delete" then
		global.setVar("hasChanged", true)
	end
	if command == "delEol" then
		for i=1, numberMod do
			local nextLine = global.getVar("currentLine") + 1
			local mSpace
			if otherMod == "space" then mSpace = " " else mSpace = "" end
			if global.getLine(nextLine) ~= nil then
				global.setCurLine( 
					global.getCurLine() .. 
					mSpace ..
					global.getLine( nextLine ))
				global.removeLine( nextLine )
			end
		end
		global.setVar("hasChanged", true)

	elseif command == "horiz" then
		if string.len( global.getCurLine() ) == 0 then return end
		if actionType == "delete" or actionType == "yank" then
			local curX = global.getVar("currentColumn")

			if actionType == "delete" then
				local temp = global.getCurLine()
				-- used since some thing differ when moving forwards and backwarsd
				local backMod = 1
				if numberMod < 0 then
					temp = string.reverse( temp )
					-- TODO cases in the far edge of the string
					curX = string.len( temp ) - curX + 2
					backMod = 0
				end

				local goal = curX + math.abs(numberMod) + backMod

				local outString = 
					string.sub( temp, 0, curX - 1 ) ..
					string.sub( temp, goal )

				if numberMod < 0 then
					outString = string.reverse( outString )
					move( "horiz", numberMod, "move", "n" )
				end
				global.setCurLine( outString )

				if otherMod == "i" then
					vimode.insertMode("here")
				end
			 end

		elseif actionType == "switchCase" then
			local lowerCase = {
				'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
				'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
			}
			local upperCase = {
				'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
				'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
			}
			local start = global.getVar("currentColumn")
			local line = global.getCurLine()

			logger.info( "numberMod start: " .. numberMod )

			for i=start, numberMod + start - 1 do
				for c=1, #lowerCase do
					local hasChanged = false
					if line:sub(i, i) == lowerCase[c] then
						line = line:sub(1, i - 1) .. upperCase[c] .. line:sub( i + 1 )
						logger.info( "made " .. lowerCase[c] .. " upper case" )
						hasChanged = true
					end
					if line:sub(i, i) == upperCase[c] and not hasChanged then
						line = line:sub(1, i - 1) .. lowerCase[c] .. line:sub( i + 1 )
						logger.info( "made " .. upperCase[c] .. " lower case" )
					end
				end
			end
			global.setCurLine( line )
			logger.info( "numberMod end: " .. numberMod )
			move( "horiz", numberMod, "move", "n" )


		else -- simple move
			local xBefore = global.getVar("currentColumn")
			local xAfter = xBefore + numberMod
			if xAfter < 1 then xAfter = 1 end
			if xAfter > string.len(global.getCurLine()) then
				xAfter = string.len(global.getCurLine()) end
			global.setVar("currentColumn", xAfter)
			global.setVar("actualColumn" , xAfter)
		end
		
	elseif command == "vert" then
		if actionType == "delete" or actionType == "yank" then
			if numberMod < 0 then
				if -numberMod > global.getVar("currentLine") then
					numberMod = -(global.getVar("currentLine") - 1)
				end
				move( "vert", numberMod, "move", "n" )
			end
			goToStart( "move", "line" )
			move( "delEol", math.abs(numberMod), "delEol", "n" )

			goToEndOfLine( "delete", "n" )
			move( "delEol", 1, "delEol", "n" )
		else
			cursorVerticalMove( numberMod )
		end
	end
	screen.redraw()
end

goToEndOfLine = function( actionType, subMod )
	move(
		"horiz",
		string.len(global.getCurLine()) - global.getVar("currentColumn") + 1,
		actionType, subMod )
end

-- this needs to be non local for it to work, maybe, perhaps. I have just given up
goToStart = function( actionType, location )
	-- location can be ( line | text )
	local wsS, wsE = 
		string.find( global.getCurLine(), "%s+" )
	if location == "text" then
		if wsS ~= 1 then wsE = 0 end
	else 
		wsE = 0 
	end
	move( "horiz",
		  -(global.getVar("currentColumn") - (wsE + 1)),
		  actionType, subMod)
end

-- command should be a 'char' array
--
-- returns if the command triggered something
function runViCommand( command )
	-- This is so that a command is't otherMod of itself
	local commandSub = {}
	for i=1, #command - 1 do
		commandSub[i] = command[i]
	end
	local otherMod, number1, number2 = parseViCommand( commandSub );
	local numMod = number1 * number2

	logger.info(" n1: " .. number1)
	logger.info(" n2: " .. number2) -- n2 isn't used...
	logger.info("--------" .. os.time())

	-- set this back to false if something shouldn't trigger
	-- but most things should trigger, thereby true by default
	local triggered = true

	local use = "move" -- default value
	local subMod = "n"
	if otherMod == "d" then
		use = "delete"
	elseif otherMod == "c" then
		use = "delete"
		subMod = "i"
	elseif otherMod == "y" then
		use = "yank"
	elseif otherMod == "" then
		use = "move"
	end

		-- this is first since they keys that come after 'z'
		-- is used in other commands
		if otherMod == "z" then
			local tLine
			    if command[#command] == "z" then
				tLine =
					global.getVar("currentLine") -
					math.floor(global.getVar("termY") / 2)
			elseif command[#command] == "t" then
				tLine = global.getVar("currentLine")
			elseif command[#command] == "b" then
				tLine =
					global.getVar("currentLine") -
					(global.getVar("termY") - 2)
			end
			if tLine ~= nil then
				if tLine < 1 then tLine = 1 end
				global.setVar("topLine", tLine)
			end

		elseif command[#command] == "f" or 
		       command[#command] == "t" then
		   local event, keyToFind = os.pullEvent("char")


			local tMod
			if command[#command] == "t" then
				tMod = 1/numMod
			else
				tMod = 0
			end
			for i=1, numMod do
				local startPos = 
					math.min(global.getVar("currentColumn") + 1,
					         string.len(global.getCurLine()))
				local tempX = string.find( global.getCurLine(), keyToFind,
					startPos ) or (global.getVar("currentColumn") + tMod) - 
					global.getVar("currentColumn") -
					numMod * tMod or 0
				move( "horiz", tempX, use, "n" )
			end
				
		elseif command[#command] == "l" then
			move( "horiz", numMod, use, subMod )
				
		elseif command[#command] == "h" then
			move( "horiz", -numMod, use, subMod )
				
		elseif command[#command] == "j" then
			move( "vert", numMod, use, subMod )

		elseif command[#command] == "k" then
			move( "vert", -numMod, use, subMod )

		elseif command[#command] == "$" then
			goToEndOfLine( use, subMod )

		elseif command[#command] == "^" then
			goToStart( use, "text" )

		elseif command[#command] == "0" and
		       tonumber(command[#command - 1]) == nil then
			goToStart( use, "line" )

		elseif command[#command] == "G" then
			local moveDist
			if numMod == 1 then
				moveDist = global.getLength() - global.getVar("currentLine")
			else
				moveDist = numMod - global.getVar("currentLine")
			end
			move( "vert", moveDist, use, subMod )

		elseif command[#command] == "g" and
		       command[#command - 1] == "g" then
				local moveDist = numMod - global.getVar("currentLine")
				move( "vert", moveDist, use, subMod )


		elseif command[#command] == "w" then
			for i=1, numMod do
				local tXS =
					string.find(global.getCurLine(), "[%s%p]", global.getVar("currentColumn"))
					or string.len(global.getCurLine())
				tXS = tXS - global.getVar("currentColumn") + 1
				if use == "delete" then tXS = tXS - 1 end
				move( "horiz", tXS, use, subMod )
			end
		
		elseif command[#command] == "e" then
			for i=1, numMod do
				local tXS =
					string.find(global.getCurLine(), "[%s%p]", global.getVar("currentColumn") + 2)
					or string.len(global.getCurLine())
				tXS = tXS - global.getVar("currentColumn") - 1
				move( "horiz", tXS, use, subMod )
			end

		elseif command[#command] == "b" then
			for i=1, numMod do
				local tempLine = string.reverse(global.getCurLine())
				local tXS =
					string.find(tempLine, "[%s%p]", string.len(tempLine) - global.getVar("currentColumn") + 1)
					or string.len(tempLine) + 1
				local moveDist = string.len(tempLine) - tXS - global.getVar("currentColumn") + 2
				-- this is used if the character directly behind the cursor is a space
				-- Then the cursor should jump to the next (previous) word
				if moveDist == 0 and tXS ~= string.len(tempLine) + 1 then
					move( "horiz", -1, use, "n" )
					moveDist =
						string.find(tempLine, "[%s%p]", string.len(tempLine) - global.getVar("currentColumn") + 2)
						or string.len(tempLine) + 1
					moveDist = string.len(tempLine) - moveDist - global.getVar("currentColumn") + 2
				end
				move( "horiz", moveDist, use, subMod )
			end

		elseif command[#command] == "W" then
			for i=1, numMod do
				local tXS =
					string.find(global.getCurLine(), "%s", global.getVar("currentColumn"))
					or string.len(global.getCurLine())
				tXS = tXS - global.getVar("currentColumn") + 1
				if use == "delete" then tXS = tXS - 1 end
				move( "horiz", tXS, use, subMod )
			end
		
		elseif command[#command] == "E" then
			for i=1, numMod do
				local tXS =
					string.find(global.getCurLine(), "%s", global.getVar("currentColumn") + 2)
					or string.len(global.getCurLine())
				tXS = tXS - global.getVar("currentColumn") - 1
				move( "horiz", tXS, use, subMod )
			end

		elseif command[#command] == "B" then
			for i=1, numMod do
				local tempLine = string.reverse(global.getCurLine())
				local tXS =
					string.find(tempLine, "%s", string.len(tempLine) - global.getVar("currentColumn") + 1)
					or string.len(tempLine) + 1
				local moveDist = string.len(tempLine) - tXS - global.getVar("currentColumn") + 2
				-- this is used if the character directly behind the cursor is a space
				-- Then the cursor should jump to the next (previous) word
				if moveDist == 0 and tXS ~= string.len(tempLine) + 1 then
					move( "horiz", -1, use, "n" )
					moveDist =
						string.find(tempLine, "%s", string.len(tempLine) - global.getVar("currentColumn") + 2)
						or string.len(tempLine) + 1
					moveDist = string.len(tempLine) - moveDist - global.getVar("currentColumn") + 2
				end
				move( "horiz", moveDist, use, subMod )
			end
		

		elseif command[#command] == "s" then
			move( "horiz", numMod - 1, "delete", "i" )


		elseif command[#command] == "S" then
			goToStart( "move", "line" )
			move( "delEol", numMod - 1, "delEol", "n" )
			goToEndOfLine( "delete", "i" )

		elseif command[#command] == "~" then
			move( "horiz", numMod, "switchCase", subMod )



		elseif command[#command] == "x" then
			move( "horiz", numMod - 1, "delete", subMod )
		elseif command[#command] == "X" then
			move( "horiz", -numMod - 1, "delete", subMod )
		


		elseif command[#command] == "J" then
			move( "delEol", numMod, "delEol", "space" )

		elseif command[#command] == "d" then
			if otherMod == "d" then
				goToStart( "move", "line" )
				move( "delEol", numMod - 1, "delEol", "noSpace" )
				goToEndOfLine( "delete", "n" )
				move( "delEol", 1, "delEol", "noSpace" )
			else
				triggered = false
			end
			
		elseif command[#command] == "c" then
			if otherMod == "c" then
				goToStart( "move", "line" )
				move( "delEol", numMod - 1, "delEol", "noSpace" )
				goToEndOfLine( "delete", "i" )
			else
				triggered = false
			end

		elseif command[#command] == "D" then
			for i=2, numMod do
				move( "delEol", 1, "delEol", "noSpace" )
			end
			goToEndOfLine( "delete", "n" )

		elseif command[#command] == "C" then
			for i=2, numMod do
				move( "delEol", 1, "delEol", "noSpace" )
			end
			goToEndOfLine( "delete", "n" )
			vimode.insertMode("here")

		elseif command[#command] == "r" then
			local ev, repl = os.pullEvent("char")
			move( "horiz", numMod - 1, "delete", subMod )
			vimode.insertText( 
				"here",
				string.rep( repl, numMod ))
			move( "horiz", numMod - 1, "move", "n" )
			


		elseif command[#command] == "i" then
			local str = vimode.insertMode("here")
			for i=2, numMod do
				vimode.insertText( "here", str )
			end
		
		elseif command[#command] == "I" then
			if otherMod == "g" then
				local str = vimode.insertMode("0")
				for i=2, numMod do
					vimode.insertText( "0", str )
				end
			else
				local str = vimode.insertMode("beginning")
				for i=2, numMod do
					vimode.insertText( "beginning", str )
				end
			end
		
		elseif command[#command] == "a" then
			local str = vimode.insertMode("after")
			for i=2, numMod do
				vimode.insertText( "here", str )
			end
		
		elseif command[#command] == "A" then
			local str = vimode.insertMode("end")
			for i=2, numMod do
				vimode.insertText( "end", str )
			end

		elseif command[#command] == "o" then
			local str = vimode.insertMode("newline")
			for i=2, numMod do
				vimode.insertText( "newline", str )
			end

		elseif command[#command] == "O" then
			local str = vimode.insertMode("prevline")
			for i=2, numMod do
				vimode.insertText( "prevline", str )
			end

		elseif otherMod == "Z" then
			if command[#command] == "Z" then
				file.write()
				global.setVar( "running", false )
			elseif command[#command] == "Q" then
				global.setVar( "running", false )
			end

		

		else
			-- if nothing happened then triggered sholud be false
			-- this is so I don't have to specify triggered=true on
			-- for every possible command
			triggered = false
		end


	screen.redraw()
	return triggered
end

local function parseExCommand( text ) 
	local len = string.len(text)
	local value = {}
	for i=1, #text do
		value[i] = text:sub(i, i)
	end
	return value
end

function runExCommand( command )
	local cmd = parseExCommand( command )

	local fun = {}

	function fun.q()
		if global.getVar("hasChanged") then
			screen.echoerr("No write since last change, ! to override")
		else
			global.setVar("running", false)
		end
	end
	fun["!"] = function()
		global.setVar("running", false)
	end
	function fun.w()
		file.write()
	end

	for i=1, #cmd do
		--screen.echoerr(cmd[i])
		if fun[cmd[i]] ~= nil then
			fun[cmd[i]]()
		else
			screen.echoerr("No such command")
		end
	end
end
