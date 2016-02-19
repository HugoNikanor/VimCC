function commandMode() 
	local command = ""
	local pos = 1
	term.setCursorPos(1, global.getVar("termY"))
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

			if key == config.get("escBtn") then
				term.clearLine()
				running = false
			end

			if key == keys.backspace then
				term.setCursorPos(pos, global.getVar("termY"))

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
			term.setCursorPos(pos, global.getVar("termY"))
			term.write(key)
		end
		event, key = os.pullEvent()
	end
end

function insertText( pos, text )
	global.setVar( "hasChanged", true )
	local line, column

	if pos == "newline"    or
	   pos == "prevline" then
	   line = global.getVar("currentLine") + 1
	   global.insertLine( line, text )
	else
		line = global.getVar("currentLine")
		if pos == "here" then
			column = global.getVar("currentColumn")
		elseif pos == "after" then
			column = global.getVar("currentColumn") + 1
		elseif pos == "beginning" then
			column = string.len(string.match(global.getLine(line), "%s*"))
			column = column + 1
		elseif pos == "0" then
			column = 1
		elseif pos == "end" then
			column = string.len(global.getLine(line))
		end
		strBefore = string.sub(global.getLine( line ), 1, column - 1)
		strAfter  = string.sub(global.getLine( line ), column )

		global.setLine( line, strBefore .. text .. strAfter )
	end


end

-- pos: where should insert mode be entered in realtion to the cursor
function insertMode( pos )
	-- TODO find better way to eat event
	os.sleep(0.1)

	local strBefore
	local strAfter

	local strChange = ""

	global.setVar("hasChanged", true)

	if pos == "here" then
	elseif pos == "after" then
		global.setVar("currentColumn", global.getVar("currentColumn") + 1)
	elseif pos == "beginning" then
		global.setVar("currentColumn", string.len(string.match(global.getCurLine(), "%s*")) + 1) 
	elseif pos == "0" then
		global.setVar("currentColumn", 1)
	elseif pos == "end" then
		global.setVar("currentColumn", string.len(global.getCurLine()) + 1)
	elseif pos == "newline" then
		global.setVar("hasChanged", true)
		global.setVar("currentLine", global.getVar("currentLine") + 1)
		global.insertLine(global.getVar("currentLine"), "")
		global.setVar("currentColumn", 1)
	elseif pos == "prevline" then
		global.setVar("hasChanged", true)
		global.insertLine(global.getVar("currentLine") + 1, global.getCurLine())
		global.setLine(global.getVar("currentLine"), "")
		global.setVar("currentColumn", 1)
	end

	strBefore = string.sub(global.getCurLine(), 1, global.getVar("currentColumn") - 1)
	strAfter = string.sub(global.getCurLine(), global.getVar("currentColumn"))

	-- TODO the cursor should blink while in insert mode
	screen.redraw()

	local event, key = os.pullEvent()
	while true do
		if event == "key" then

			if key == config.get("escBtn") then
				-- the cursor can be one step to far to the right
				-- this happens when appending text to a line
				local strLen = string.len(global.getCurLine())
				if global.getVar("currentColumn") > strLen then
					global.setVar("currentColumn", strLen)
				end

				break
			end

			-- TODO You currently can backspace past the screen
			if key == keys.backspace then
				strBefore = string.sub(strBefore, 1, string.len(strBefore) - 1)
				global.setVar("currentColumn", global.getVar("currentColumn") - 1)
				global.setLine(global.getVar("currentLine"), strBefore..strAfter)

				strChange = string.sub( strChange, 1, string.len(strChange) - 1 )

				--term.setCursorPos(column, line)
			end

			if key == keys.delete then
				strAfter = string.sub(strAfter, 2)
				global.setLine(global.getVar("currentLine"), strBefore..strAfter)

				--term.setCursorPos(column, line)
			end

			-- TODO this sholud be better
			if key == keys.enter then
				global.setVar("hasChanged", true)

				global.setLine(global.getVar("currentLine"), strBefore)

				global.setVar("currentLine", global.getVar("currentLine") + 1)
				global.setVar("currentColumn", 1)
				global.insertLine(global.getVar("currentLine"), strAfter)
				strBefore = ""

				strChange = strChange .. "\n"

				--screen.redraw()
			end

			screen.redraw()
		end

		-- text entry
		if event == "char" then
			global.setVar("hasChanged", true)
			global.setVar("currentColumn", global.getVar("currentColumn") + 1)

			strBefore = strBefore..key
			strChange = strChange .. key
			
			global.setLine(global.getVar("currentLine"), strBefore..strAfter)

			screen.redraw()
		end

		-- pull next event
		event, key = os.pullEvent()
	end

	return strChange
end

function normalMode()
	term.setCursorBlink(false)


	local keyPresses = {}

	global.setVar("running", true)
	while global.getVar("running") do
		local event, key = os.pullEvent()

		if event == "key" then
			if key == config.get("escBtn") then
				keyPresses = {}
			end
		end
		if event == "char" then
			if key == ":" then
				local cmd = commandMode() or ""
				command.runExCommand( cmd )
				keyPresses = {}
			end

			keyPresses[#keyPresses + 1] = key

			local triggered = command.runViCommand( keyPresses )

			if triggered then
				keyPresses = {}
			end
		end
	end
end
