extends StoreClass
const StoreClass = preload ("./store.gd")

func _init():
	self.state = R.state({
		"devices": []
	})

	HomeApi.on_connect.connect(func():
		self.state.devices=await HomeApi.get_devices()
	)

func clear():
	pass