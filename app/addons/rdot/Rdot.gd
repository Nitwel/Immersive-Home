class_name R

static func state(value: Variant, options: Dictionary={}):
	if value is Dictionary:
		return store(value)

	return RdotState.new(value, options)

static func store(value: Dictionary):
	return RdotStore.new(value)

static func computed(computation: Callable, options: Dictionary={}):
	return RdotComputed.new(computation, options)

## DIY overloading of
## bind(target, prop, value)
## bind(target, prop, value, watch_signal)
## bind(target, prop, store, key, watch_signal)
static func bind(target, prop, value, arg1=null, arg2=null):
	if value is RdotStore:
		return _bind_store(target, prop, value, arg1, arg2)

	if value is RdotState or value is RdotComputed:
		return _bind_state(target, prop, value, arg1)

	assert(false, "Invalid arguments to bind, value must be a RdotState, a RdotComputed or a RdotStore")

static func _bind_store(target, prop, store: RdotStore, key, watch_signal=null):
	store._access_property(key)

	return _bind_state(target, prop, store._proxied_value[key], watch_signal)

static func _bind_state(target, prop, value, watch_signal=null):
	assert(state != null, "target cannot be null")

	var graph = RdotGraph.getInstance()

	var watch_c = func(new_value):
		value.value = new_value

	var c = computed(func(_arg):
		var oldValue=target.get(prop)

		if oldValue != value.value:
			target.set(prop, value.value)
	)

	if watch_signal:
		watch_signal.connect(watch_c)

	graph.watcher.watch([c])
	c.do_get()

	return func():
		graph.watcher.unwatch([c])
		if watch_signal:
			watch_signal.disconnect(watch_c)

static func effect(callback: Callable):
	var graph = RdotGraph.getInstance()

	var deconstructor := Callable()
	var c = computed(func(_arg):
		if !deconstructor.is_null():
			deconstructor.call()

		if callback.is_valid() == false:
			return

		var result=callback.call(_arg)

		if result is Callable:
			deconstructor=result
	)

	graph.watcher.watch([c])
	c.do_get()

	return func():
		if !deconstructor.is_null():
			deconstructor.call()
		
		graph.watcher.unwatch([c])

class RdotState:
	var node: RdotStateInternal
	var value = null:
		get:
			return do_get()
		set(value):
			do_set(value)
	
	func _init(value: Variant, options: Dictionary={}):
		var ref = RdotStateInternal.createSignal(value)
		var node = ref[1]
		self.node = node
		node.wrapper = self

		if !options.is_empty():
			var equals = options.get("equals")

			if !equals.is_null():
				node.equals = equals

	func do_get():
		return RdotStateInternal.signalGetFn.call(self.node)

	func do_set(value: Variant):
		var graph = RdotGraph.getInstance()
		
		assert(graph.isInNotificationPhase() == false, "Writes to signals not permitted during Watcher callback")

		var ref = self.node

		RdotStateInternal.signalSetFn.call(ref, value)

class RdotComputed:
	var node: RdotComputedInternal
	var value = null:
		get:
			return do_get()
		set(value):
			pass
	
	func _init(computation: Callable, options: Dictionary={}):
		var ref = RdotComputedInternal.createdComputed(computation)
		var node = ref[1]
		node.consumerAllowSignalWrites = true
		self.node = node
		node.wrapper = self

		if options:
			var equals = options.get("equals")

			if !equals.is_null():
				node.equals = equals

	func do_get():
		return RdotComputedInternal.computedGet(node)

class Watcher:
	var node: RdotNode

	func _init(notify: Callable):
		var node = RdotNode.new()
		node.wrapper = self
		node.consumerMarkedDirty = notify
		node.consumerIsAlwaysLive = true
		node.consumerAllowSignalWrites = false
		node.producerNode = []
		self.node = node
	
	## signals: Array[RdotState | RComputed]
	func _assertSignals(signals: Array):
		for s in signals:
			assert(s is RdotState or s is RdotComputed, "Watcher expects signals to be RdotState or RdotComputed")

	func watch(signals:=[]):
		_assertSignals(signals)

		var graph = RdotGraph.getInstance()

		var node = self.node
		node.dirty = false
		var prev = graph.setActiveConsumer(node)
		for s in signals:
			graph.producerAccessed(s.node)

		graph.setActiveConsumer(prev)

	func unwatch(signals: Array):
		_assertSignals(signals)

		var graph = RdotGraph.getInstance()

		var node = self.node
		graph.assertConsumerNode(node)

		var indicesToShift = []
		for i in range(node.producerNode.size()):
			if signals.has(node.producerNode[i].wrapper):
				graph.producerRemoveLiveConsumerAtIndex(node.producerNode[i], node.producerIndexOfThis[i])
				indicesToShift.append(i)

		for idx in indicesToShift:
			var lastIdx = node.producerNode.size() - 1
			node.producerNode[idx] = node.producerNode[lastIdx]
			node.producerIndexOfThis[idx] = node.producerIndexOfThis[lastIdx]

			node.producerNode.pop_back()
			node.producerIndexOfThis.pop_back()
			node.nextProducerIndex -= 1

			if idx < node.producerNode.size():
				var idxConsumer = node.producerNode[idx]
				var producer = node.producerNode[idx]

				graph.assertProducerNode(producer)

				producer.liveConsumerIndexOfThis[idxConsumer] = idx

	## Returns Array[RComputed]
	func getPending() -> Array:
		var node = self.node

		return node.producerNode.filter(func(n): return n.dirty).map(func(n): return n.wrapper)
