extends StoreClass
## Stores general settings for the app

const StoreClass = preload ("./store.gd")

enum CursorStyle {
	DEFAULT,
	RETRO
}

func _init():
	_save_path = "user://settings.json"

	self.state = R.store({
		## The adapter to use for connecting with a backend
		"type": "HASS_WS",
		"url": "ws://192.168.188.22:8123",
		"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmMjM5NmRmOTMzMWU0NDExOTk5N2EzNjM5ZTc5NGE0NSIsImlhdCI6MTcxOTMyNzM3NywiZXhwIjoyMDM0Njg3Mzc3fQ.DWQmEOguXe9Lno65-MtXhEQj7VUnIUBCbyw9v2cy7bE",
		## If the voice assistant should be enabled
		"voice_assistant": false,
		## If the onboarding process has been completed
		"onboarding_complete": false,
		"cursor_style": CursorStyle.DEFAULT
	})

func clear():
	self.state.type = "HASS_WS"
	self.state.url = "ws://192.168.188.22:8123"
	self.state.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmMjM5NmRmOTMzMWU0NDExOTk5N2EzNjM5ZTc5NGE0NSIsImlhdCI6MTcxOTMyNzM3NywiZXhwIjoyMDM0Njg3Mzc3fQ.DWQmEOguXe9Lno65-MtXhEQj7VUnIUBCbyw9v2cy7bE"
	self.state.voice_assistant = false
	self.state.onboarding_complete = false
	self.state.cursor_style = CursorStyle.DEFAULT
