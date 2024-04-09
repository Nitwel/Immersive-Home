extends RdotNode
class_name RdotState

var equal: Callable = func(this, a, b): a == b
var value: Variant = null

static func createSignal(initialValue: Variant):
	var node = RdotState.new()
	node.value = initialValue

	var getter = func():
		RdotGraph.getInstance().producerAccessed(node)
		return node.value

	return [getter, node]

static func setPostSignalSetFn(fn: Callable) -> Callable:
	var graph := RdotGraph.getInstance()
	var prev = graph.postSignalSetFn
	graph.postSignalSetFn = fn
	return prev

static func signalGetFn(this: RdotState):
	RdotGraph.getInstance().producerAccessed(this)
	return this.value

static func signalSetFn(node: RdotState, newValue: Variant):
	var graph := RdotGraph.getInstance()

	assert(graph.producerUpdatesAllowed())

	if !node.equal.call(node.wrapper, node.value, newValue):
		node.value = newValue
		signalValueChanged(node)

static func signalUpdateFn(node: RdotState, updater: Callable):
	var graph := RdotGraph.getInstance()

	assert(graph.producerUpdatesAllowed())

	signalSetFn(node, updater.call(node.value))

static func signalValueChanged(node: RdotState):
	var graph := RdotGraph.getInstance()
	
	node.version += 1
	graph.producerIncrementEpoch()
	graph.producerNotifyConsumers(node)
	if !graph.postSignalSetFn.is_null():
		graph.postSignalSetFn.call()
