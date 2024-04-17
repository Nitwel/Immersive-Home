var groups = {}
var counter = 0

func create(entities):
	var index = str(counter)
	groups[index] = entities
	counter += 1

	return "group.%s" % index

func add_entity(id: String, entity):
	if is_group(id) == false:
		return false

	groups[id.replace("group.", "")].append(entity)
	return true

func update_entities(id: String, entities):
	if is_group(id) == false:
		return false

	groups[id.replace("group.", "")] = entities
	return true

func remove_entity(id: String, entity):
	if is_group(id) == false:
		return false

	groups[id.replace("group.", "")].erase(entity)
	return true

func remove(id: String):
	if is_group(id) == false:
		return false
	return groups.erase(id.replace("group.", ""))

func is_group(id: String):
	return id.begins_with("group.")

func get_group(id: String):
	if is_group(id) == false:
		return null

	return groups[id.replace("group.", "")]