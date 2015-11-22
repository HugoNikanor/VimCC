function redrawScreen()
	term.setCursorPos(1, 1)
	term.clear()
	for i=topLine, topLine+termY-2 do
		if lines[i] ~= nil then
			print(lines[i])
		else
			print("~")
		end
	end
end

function writeFile()
	local file = fs.open(fileName, "w")
	for i=1, length do
		file.writeLine(lines[i])
	end
	file.close()

	hasChanged = false
end

function commandMode() 
	local command = ""
	local pos = 1
	term.setCursorPos(1, termY)
	term.clearLine()
	term.write(":")

	-- TODO find better way to 'eat' event
	os.sleep(0.1)
	

	local running = true
	local event, key = os.pullEvent()
	while running do
		if event == "key" then
			if key == keys.enter then
				term.clearLine()
				running = false
				return command
			end
			-- tab is escape
			if key == keys.tab then
				term.clearLine()
				running = false
			end
			if key == keys.backspace then
				term.setCursorPos(pos, termY)

				command = string.sub(command, 1, string.len(command) - 1)
				pos = pos - 1
				if pos < 1 then
					pos = 1
				end
			end
		end
		if event == "char" then
			--command[pos] = key
			command = command..key
			pos = pos + 1
			term.setCursorPos(pos, termY)
			term.write(key)
		end
		event, key = os.pullEvent()
	end
end

-- @returns
-- cursorX, the cursor pos after edits
function insertMode(line, column, pos)
	os.sleep(0.1)

	local strBefore
	local strAfter

	-- Also have 'begining' and 'end'
	if pos == "here" then
		strBefore = string.sub(lines[line], 1, column - 1)
		strAfter = string.sub(lines[line], column)
	elseif pos == "after" then
		strBefore = string.sub(lines[line], 1, column)
		strAfter = string.sub(lines[line], column + 1)
		column = column + 1
	elseif pos == "beginning" then
		strBefore = ""
		strAfter = lines[line]
		column = 1
	elseif pos == "end" then
		strBefore = lines[line]
		strAfter = ""
		column = string.len(lines[line]) + 1
	end

	term.setCursorPos( column, line )

	local event, key = os.pullEvent()
	while true do
		if event == "key" then
			-- tab is escape
			if key == keys.tab then
				return column
			end
			-- You currently can backspace past the screen
			if key == keys.backspace then
				strBefore = string.sub(strBefore, 1, string.len(strBefore) - 1)
				column = column - 1

				term.clearLine()
				term.setCursorPos(1, line)
				term.write(strBefore..strAfter)
				lines[line] = strBefore..strAfter

				term.setCursorPos(column, line)
			end
			-- insert linebreak
			if key == keys.enter then
				hasChanged = true

				lines[line] = strBefore
				table.insert(lines, line + 1, strAfter)
				strAfter = ""
				length = length + 1

				redrawScreen()

				column = 1
				term.setCursorPos(column, line)

			end
		end
		-- text entry
		if event == "char" then
			hasChanged = true

			strBefore = strBefore..key
			term.clearLine()
			term.setCursorPos(1, currentLine-topLine+1)
			term.write(strBefore..strAfter)
			lines[line] = strBefore..strAfter

			column = column + 1
			term.setCursorPos(column, line)
		end
		event, key = os.pullEvent()
	end


end

function normalMode()
	term.setCursorBlink(true)
	-- what line vissible on the screen is selected
	local cursorX, cursorY = 1, 1
	term.setCursorPos(cursorX, cursorY)

	local running = true

	local prevKey = nil

	local numMod = "0"

	while running do
		local event, keyPress, beingHeld = os.pullEventRaw("key")

		-- TODO
		-- '-' might behave strange
		local inNumber = tonumber(keyPress)
		inNumber = inNumber - 1
		if keyPress ~= nil then
			if inNumber >= 1 and inNumber <= 9 then
				numMod = numMod..inNumber
			end
			if inNumber == 10 then
				numMod = numMod.."0"
			end
		end

		-- basic cursor move commands
		if keyPress == keys.l then
			if tonumber(numMod) == 0 then
				numMod = "1"
			end
			cursorX = cursorX + tonumber(numMod)
			numMod = "0"
		end
		if keyPress == keys.h then
			if tonumber(numMod) == 0 then
				numMod = "1"
			end
			cursorX = cursorX - tonumber(numMod)
			numMod = "0"
		end
		if keyPress == keys.j then
			if tonumber(numMod) == 0 then
				numMod = "1"
			end
			cursorY = cursorY + tonumber(numMod)
			currentLine = currentLine + tonumber(numMod)
			numMod = "0"
			if cursorY > termY - 2 then
				cursorY = termY - 2
				topLine = topLine + 1
			end
			if cursorY > length then
				cursorY = length
				currentLine = length
			end
			if currentLine > length then
				currentLine = length
				topLine = length
			end
			redrawScreen()
		end
		if keyPress == keys.k then
			if tonumber(numMod) == 0 then
				numMod = "1"
			end
			cursorY = cursorY - tonumber(numMod)
			currentLine = currentLine - tonumber(numMod)
			numMod = "0"
			if cursorY < 1 then
				cursorY = 1
				topLine = topLine - 1
			end
			if currentLine < 1 then
				currentLine = 1
				topLine = 1
			end
			redrawScreen()
		end

		if keyPress == keys.x then
			if tonumber(numMod) == 0 then
				numMod = "1"
			end
			hasChanged = true;
			temp = lines[currentLine]
			a = string.sub(temp, 1, cursorX - 1)
			b = string.sub(temp, cursorX + tonumber(numMod), string.len(temp)) 
			lines[currentLine] = a..b
			redrawScreen()
			numMod = "0"
		end

		if keyPress == keys.d and prevKey == keys.d then
			hasChanged = true;
			if tonumber(numMod) == 0 then
				numMod = "1"
			end
			for i=1, tonumber(numMod) do
				table.remove(lines, currentLine)
			end
			numMod = "0"
			redrawScreen()
		end

		-- currently sets the line jumped to as the top line
		-- TODO possible bugs
		-- allows the sceen to scroll further than usual
		-- when entering a 0 manually, still goes to bottom
		if keyPress == keys.g and prevKey == keys.rightShift or prevKey == keys.leftShift then
			if tonumber(numMod) == 0 or tonumber(numMod) > length then
				currentLine = length
				topLine = length
			else
				currentLine = tonumber(numMod)
				topLine = currentLine
			end
			numMod = "0"
			redrawScreen()
		end

		if keyPress == keys.i then
			if prevKey == keys.leftShift or prevKey == keys.rightShift then
				cursorX = insertMode(currentLine, cursorX, "beginning")
			else
				cursorX = insertMode(currentLine, cursorX, "here")
			end
		end
		if keyPress == keys.a then
			if prevKey == keys.leftShift or prevKey == keys.rightShift then
				cursorX = insertMode(currentLine, cursorX, "end")
			else
				cursorX = insertMode(currentLine, cursorX, "after")
			end
		end

		-- Check if alt-gr is down and colon is pressed
		-- special case for my computer
		if prevKey == 184 then
			if keyPress == 52 then
				--print("colon pressed")
				local command = commandMode()
				if command == "q" then
					if hasChanged then
						term.setCursorPos(1, termY)
						term.setBackgroundColour( colors.red )
						term.write("No write since last change, ! to override")
						term.setBackgroundColour( colors.black )
					else
						running = false;
					end
				end
				if command == "q!" then
					running = false;
				end
				if command == "w" then
					writeFile()
				end
				if command == "wq" then
					writeFile()
					running = false
				end
			end
		end

		term.setCursorPos(cursorX, cursorY)
		prevKey = keyPress
	end
end

-- start main
local args = {...}
termX, termY = term.getSize()

hasChanged = false

fileName = args[1]
--TODO create new file if file doesn't exist
--TODO other safeguards
local file = fs.open(fileName, "r")

-- what absolute line are selected
currentLine = 1
currentColumn = 1

topLine = 1

lines = {}
local counter = 0
local tempLine = file.readLine()
while tempLine ~= nil do
	counter = counter + 1
	lines[counter] = tempLine
	tempLine = file.readLine()
end
length = counter
file.close()

redrawScreen()





normalMode()


term.setCursorPos(1, 1)
term.clear()
