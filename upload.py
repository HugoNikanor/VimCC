import re
import json
from urllib.parse import urlencode
from urllib.request import Request, urlopen

readmetext = None

readme = open("README.md", "r")
readmetext = readme.read()
readme.close()

with open("PASTEBIN_API_KEY", "r") as key, open("installer.lua", "r") as installer, open("README.md", "w") as readme:
	key = key.read()
	values = {
		'api_dev_key': key.strip(),
		'api_option': 'paste',
		'api_paste_code': installer.read(),
		'api_paste_format': 'lua',
	}
	url = "http://pastebin.com/api/api_post.php"
	data = urlencode(values)
	data = data.encode('utf-8')
	req = Request(url, data)
	with urlopen(req) as resp:
		response = resp.read().decode('utf-8').strip()
		if response[:1] == "B":
			print('Bad request, upload failed.')
			print(response)
			exit()
		code = response[20:]
		readmetext = re.sub("pastebin run \w+", "pastebin run " + code, readmetext)
		readmetext = re.sub("The current pastebin code: `\w+`", "The current pastebin code: `" + code + "`", readmetext)
		readme.write(readmetext)
