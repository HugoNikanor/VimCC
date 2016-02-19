local filename
local file
logLevel = {
	NONE = 0,
	WARNINGS = 5,
	ALL = 10,
}
local level

function init( path, llevel )
	level = logLevel[llevel]
	if level > 0 then
		filename = path
		file = fs.open(filename, "a")
	end
end

function info( message )
	if level > 0 then 
		file.writeLine("INFO:"..message)
		file.flush()
	end
end

function warning( message )
	if level > 5 then
		file.writeLine("WARN:"..message)
		file.flush()
	end
end
