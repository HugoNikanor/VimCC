--/utils/vimfiles/apiloader.loadAPI( "/utils/vimfiles/" );
os.loadAPI( "/utils/vimfiles/apiloader" )
apiloader.load()

-- start main
local args = {...}

local termX, termY = term.getSize()
global.setVar("termX", termX)
global.setVar("termY", termY)


global.setVar("hasChanged", false)

-- TODO check if file is read only
if #args < 1 then
	error("please specify a file")
end

local sPath = shell.resolve( args[1] )
if fs.exists( sPath ) and fs.isDir( sPath ) then
	print( "Cannot edit a directory." )
	return
end
global.setVar("fileName", sPath)



-- what absolute line are selected
global.setVar("currentLine", 1)
global.setVar("currentColumn", 1)
global.setVar("topLine", 1)


local lines = file.read(global.getVar("fileName"))
global.setLines(lines)



screen.redraw()



if not fs.isDir("/.vimlog") then
	fs.makeDir("/.vimlog")
end
logger.init("/.vimlog/vimlog-"..os.day().."-"..os.time(), config.get("logLevel"))
logger.info("log file created")


vimode.normalMode()

apiloader.unload()
term.setCursorPos(1, 1)
term.clear()
