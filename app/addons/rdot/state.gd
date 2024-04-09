extends RdotNode
class_name RdotStateInternal

var equal: Callable = func(this, a, b): a == b
var value: Variant = null

static func createSignal(initialValue: Variant):
	var node = RdotStateInternal.new()
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

static func signalGetFn(this: RdotStateInternal):
	RdotGraph.getInstance().producerAccessed(this)
	return this.value

static func signalSetFn(node: RdotStateInternal, newValue: Variant):
	var graph := RdotGraph.getInstance()

	assert(graph.producerUpdatesAllowed())

	if !node.equal.call(node.wrapper, node.value, newValue):
		node.value = newValue
		signalValueChanged(node)

static func signalUpdateFn(node: RdotStateInternal, updater: Callable):
	var graph := RdotGraph.getInstance()

	assert(graph.producerUpdatesAllowed())

	signalSetFn(node, updater.call(node.value))

static func signalValueChanged(node: RdotStateInternal):
	var graph := RdotGraph.getInstance()
	
	node.version += 1
	graph.producerIncrementEpoch()
	graph.producerNotifyConsumers(node)
	if !graph.postSignalSetFn.is_null():
		graph.postSignalSetFn.call()
