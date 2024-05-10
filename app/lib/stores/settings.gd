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
		"url": "",
		"token": "",
		## If the voice assistant should be enabled
		"voice_assistant": false,
		## If the onboarding process has been completed
		"onboarding_complete": false,
		"cursor_style": CursorStyle.DEFAULT
	})

func clear():
	self.state.type = "HASS_WS"
	self.state.url = ""
	self.state.token = ""
	self.state.voice_assistant = false
	self.state.onboarding_complete = false
	self.state.cursor_style = CursorStyle.DEFAULT
