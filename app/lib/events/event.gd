extends Resource
## Base class for all events
class_name Event

## Merges the current event with another event. This is used in the EventSystem internally.
func merge(event: Event):
	assert(self.is_class(event.get_class()), "Can only merge events of the same type.")

	for prop in event.get_property_list():
		if prop.name in self:
			self.set(prop.name, event.get(prop.name))
