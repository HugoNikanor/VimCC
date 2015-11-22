function commandMode() 
	local command = ""
	local pos = 1
	term.setCursorPos(1, termY)
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

function insertMode(cursorX, cursorY)
end

function normalMode()
	term.setCursorBlink(true)
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
		end
		if keyPress == keys.k then
			cursorY = cursorY - 1
		end

		-- Check if alt-gr is down and colon is pressed
		-- special case for my computer
		if prevKey == 184 then
			if keyPress == 52 then
				--print("colon pressed")
				local command = commandMode()
				if command == "q" then
					running = false;
				end
			end
		end

		if keyPress == keys.i then
			insertMode(cursorX, cursorY)
		end

		term.setCursorPos(cursorX, cursorY)
		prevKey = keyPress
	end
end

-- start main
local args = {...}
termX, termY = term.getSize()

local file = fs.open(args[1], "r")
--local tmpFile = fs.open("."..args[1]..".swp", "w")


--term.clear()
--term.setCursorPos(1, 1)

lines = {}
local counter = 0
local tempLine = file.readLine()
while tempLine ~= nil do
	counter = counter + 1
	lines[counter] = tempLine
	tempLine = file.readLine()
end
length = counter


term.setCursorPos(1, 1)
term.clear()
for i=1, length do
	print(lines[i])
end
print(length)





normalMode()


term.setCursorPos(1, 1)
term.clear()
