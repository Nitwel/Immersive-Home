extends StoreClass
const StoreClass = preload ("./store.gd")

func _init():
	self.state = R.state({
		"devices": []
	})

	HomeApi.on_connect.connect(func():
		var devices=await HomeApi.get_devices()

		devices.sort_custom(func(a, b):
			return a.values()[0]["name"].to_lower() < b.values()[0]["name"].to_lower()
		)

		for device in devices:
			device.values()[0]["entities"].sort_custom(func(a, b):
				return a.to_lower() < b.to_lower()
			)

		self.state.devices=devices
	)

	HomeApi.on_disconnect.connect(func():
		self.state.devices=[]
	)

func clear():
	pass
