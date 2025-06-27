extends StoreClass
const StoreClass = preload ("./store.gd")

const device1 = {"name":"Offline", "id":"abcabcabcabc", "entities":[
			{"name":"chevron", "id":"chevron.three"},
			{"name":"ent", "id":"button.three"},
			{"name":"station", "id":"station.three"},
			{"name":"custom_label", "id":"custom_label.three"}
		] }

func _init():
	self.state = R.state({"devices":[device1.duplicate(true)]})
	HomeApi.on_connect.connect(func():
		print("HASS Connected, getting devices")
		var devices = await HomeApi.get_devices()
		devices.append(device1.duplicate(true))
		for device in devices:
			if device["name"] == null:
				device["name"] = device["id"]
		devices.sort_custom(func(a, b):
			return a["name"].to_lower() < b["name"].to_lower()
		)

		var bverbosedevicelist = false
		if bverbosedevicelist:
			print("\nDevices list:")
		var knowndevices = [ ]
		for device in devices:
			if bverbosedevicelist:
				prints(device["name"], device["id"])
				await App.get_tree().create_timer(0.1).timeout
			if device["name"] == null:
				device["name"] = device["id"]
				
			var knownentities = [ ]
			for entity in device["entities"]:
				if EntityFactory.isknownentity(entity["id"]):
					if entity["name"] == null:
						entity["name"] = entity["id"]
					if bverbosedevicelist:
						print(" ", entity)
					knownentities.append(entity)
			knownentities.sort_custom(func(a, b):
				return a["name"].to_lower() < b["name"].to_lower()
			)
			if knownentities:
				device["entities"] = knownentities
				knowndevices.append(device)
				if knownentities[0]["id"].contains("nodered"):
					device["name"] = "Node Red"
			
		self.state.devices = knowndevices
		print("calling update_house on connect so we can make all the callables")
		App.house.update_house()
	)

	HomeApi.on_disconnect.connect(func():
		pass # self.state.devices=[]
	)

func clear():
	pass
