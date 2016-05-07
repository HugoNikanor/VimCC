-- Script for downloading and "installing" the VimCC program for 
-- ComputerCraft computers
-- More information at https://github.com/HugoNikanor/VimCC

print( "This program will connect to the web, download some files and write them to some newly created directories in the file system." )
print( "continue? [yn]" )
local key = 0
while not (key == keys.n or key == keys.y) do
	evt, key = os.pullEvent("key")
end
if key == keys.n then
	key = 0
	error("user quitted")
end


if fs.exists("/utils") then
	if not fs.isDir("/utils") or fs.isReadOnly("/utils") then
		error("'/utils' is problematic, sort it out!")
	end
else
	fs.makeDir("/utils")
end
fs.makeDir("/utils/vimfiles")

if not http.request("https://github.com/hugonikanor/vimcc") then
	error("couldn't connect to the servers for download")
end

local filenames = {
	"command.lua",
	"config.lua",
	"file.lua",
	"global.lua",
	"logger.lua",
	"screen.lua",
	"vim.lua",
	"vimode.lua",
	"vimrcDefault.lua",
	"apiloader.lua"
}

local baseurl = "https://raw.githubusercontent.com/HugoNikanor/VimCC/master/vimfiles/"

print("downloading vim from github...")

for i=1, #filenames do
	local filedata = http.get( baseurl .. filenames[i] );

	print("downloading " .. filenames[i] .. "..." )
	local file = fs.open("/utils/vimfiles/" .. filenames[i]:sub(1, -5), "w")
	file.write( filedata.readAll() )
	file.close()
end
print("files downloaded!")

fs.makeDir("/bin")
fs.copy( "/utils/vimfiles/vim", "/bin/vim" )

print( "write 'shell.setPath(shell.path()..\":/bin\")' to the end of your startup script? This will alow vim to be started from anywhere" )
print( "continue? [yn]" )
local key = 0
while not (key == keys.n or key == keys.y) do
	evt, key = os.pullEvent("key")
end

if key == keys.y then
	local startupFile = fs.open("/startup", "a")
	startupFile.write( 'shell.setPath(shell.path()..":/bin")\n' )
	startupFile.close()

	print("Setup completed!")
	print("Restart your computer to update the startup script")
else
	print("Setup completed!")
end
