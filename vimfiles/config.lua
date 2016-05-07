local defaultPath = "/utils/vimfiles/vimrcDefault"
local userPath = "/.vimrc"

local isDefault = os.loadAPI(defaultPath)
if not isDefault then
	error( "Sucks to be you, the vimrcDefault is missing (or possibly just broken)" )
end
os.loadAPI(userPath)

function get( key )
	local val
	if fs.exists("/.vimrc") then
		-- TODO this might crash if log level is NONE
		val = _G[".vimrc"][key]
		if val == nil then 
			val = vimrcDefault[key]
		end
	else
		val = vimrcDefault[key]
	end
	return val
end
