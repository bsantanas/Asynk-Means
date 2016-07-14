import json 
def updateJsonFile():
	f = open("urls.txt", "r")

	l = "something"
	data = []
	while l:
		l = f.readline()
		print(l)
		data.append(l.rstrip())

	jsonFile = open("images.json", "w+")
	jsonFile.write(json.dumps(data))
	jsonFile.close()
	print('done, %d new urls' % len(data))

updateJsonFile()
