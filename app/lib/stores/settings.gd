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
		"url": "wss://mr5g.dynamicdevices.co.uk",
		"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI3ZThiOGE3M2I0Nzc0NGE4YmJmNDA1MGYxOTg5NGRkNyIsImlhdCI6MTczOTYyMDM4OCwiZXhwIjoyMDU0OTgwMzg4fQ.vzNFjWb9eIRu8-3yjyDtwWyMlYpaIXulDgvUiZOtBtM",
		## If the voice assistant should be enabled
		"voice_assistant": false,
		## If the onboarding process has been completed
		"onboarding_complete": false,
		"cursor_style": CursorStyle.DEFAULT,
		## Whether we are using developer menu or not
		"dev_state": false
	})

func clear():
	self.state.type = "HASS_WS"
	self.state.url = ""
	self.state.token = ""
	self.state.voice_assistant = false
	self.state.onboarding_complete = false
	self.state.cursor_style = CursorStyle.DEFAULT
