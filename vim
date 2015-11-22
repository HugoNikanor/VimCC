function redrawScreen()
	term.setCursorPos(1, 1)
	term.clear()
	for i=currentLine, currentLine+termY-2 do
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
			term.setCursorPos(1, line)
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
	while running do
		local event, keyPress, beingHeld = os.pullEventRaw("key")

		-- basic cursor move commands
		if keyPress == keys.l then
			cursorX = cursorX + 1
		end
		if keyPress == keys.h then
			cursorX = cursorX - 1
		end
		if keyPress == keys.j then
			cursorY = cursorY + 1
			if cursorY > termY - 2 then
				cursorY = termY - 2
				currentLine = currentLine + 1
			end
			if cursorY > length then
				cursorY = length
			end
			if currentLine > length then
				currentLine = length
			end
			redrawScreen()
		end
		if keyPress == keys.k then
			cursorY = cursorY - 1
			if cursorY < 1 then
				cursorY = 1
				currentLine = currentLine - 1
			end
			if currentLine < 1 then
				currentLine = 1
			end
			redrawScreen()
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

		if keyPress == keys.i then
			cursorX = insertMode(cursorY, cursorX, "here")
		end
		if keyPress == keys.a then
			cursorX = insertMode(cursorY, cursorX, "after")
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
local file = fs.open(fileName, "r")

-- what absolute line are selected
currentLine = 1
currentColumn = 1

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
