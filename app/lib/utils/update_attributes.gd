class_name Update

static func props(node: Node, prop_names=[]):
	for prop in prop_names:
		node.set(prop, node.get(prop))
