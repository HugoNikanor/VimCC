apiPath = "/utils/vimfiles/"
apis = {
	"command",
	"config",
	"file",
	"global",
	"logger",
	"screen",
	"vimode",
}

function load()
	for i=1, #apis do
		local test = os.loadAPI(apiPath..apis[i])
		if not test then
			error(apis[i])
		end
	end
end

function unload()
	for i=1, #apis do
		os.unloadAPI(apis[i])
	end
	os.unloadAPI("apiloader")
end
