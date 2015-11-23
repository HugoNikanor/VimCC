
local apiPath = "/utils/vimfiles/"
local apis = {
	"global",
	"vimode",
	"screen",
	"file",
}
for i=1, #apis do
	os.loadAPI(apiPath..apis[i])
end




-- start main
local args = {...}

local termX, termY = term.getSize()
global.setVar("termX", termX)
global.setVar("termY", termY)


global.setVar("hasChanged", false)

local fileName = args[1]
global.setVar("fileName", fileName)

-- what absolute line are selected
global.setVar("currentLine", 1)
global.setVar("currentColumn", 1)
global.setVar("topLine", 1)


local lines = file.read(global.getVar("fileName"))
global.setLines(lines)



screen.redraw()





vimode.normalMode()




for i=1, #apis do
	os.unloadAPI(apiPath..apis[i])
end
term.setCursorPos(1, 1)
term.clear()
