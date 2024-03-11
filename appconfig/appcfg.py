import json

f = open('appconfig.json')

data = json.load(f)
print(data["Settings:FontColor"])
print(data["Settings:Message"])
f.close()
