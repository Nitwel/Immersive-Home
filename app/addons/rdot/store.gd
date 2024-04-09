extends Object
class_name RdotStore

var _proxied_value = {}
var _property_list = []

func _init(initial_value: Dictionary={}):
	_proxied_value = initial_value

	_property_list = _proxied_value.keys().map(func(key):
		return {
			"name": key,
			"type": typeof(_proxied_value[key])
		}
	)

func _get(property):
	_access_property(property)

	if _proxied_value[property] is RdotStore:
		return _proxied_value[property]

	return _proxied_value[property].value

func _set(property, value):
	_access_property(property)

	_proxied_value[property].value = value

	return true

func _access_property(property):
	if (_proxied_value[property] is R.RdotState) == false:
		_proxied_value[property] = R.state(_proxied_value[property])

func _get_property_list():
	return _property_list
