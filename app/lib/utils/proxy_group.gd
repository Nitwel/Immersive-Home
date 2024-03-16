extends RefCounted
## A group of proxies that will be updated when one of them is updated
class_name ProxyGroup

var proxies = []

func proxy(_get: Callable, _set: Callable):
	var _proxy
	_proxy = Proxy.new(_get, func(value):
		_set.call(value)
		
		for p in proxies:
			if p != _proxy:
				p.on_set.emit(value)
	)

	proxies.append(_proxy)

	return _proxy
	