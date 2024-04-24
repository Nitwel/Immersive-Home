extends RdotNode
class_name RdotComputedInternal

enum State {
	SET = 0,
	UNSET = 1,
	COMPUTING = 2,
	ERRORED = 3
}

var value: Variant = null
var state: State = State.UNSET
var error = null
var computation := Callable()
var equal := func(this, a, b): return a == b

static func computedGet(node: RdotComputedInternal) -> Variant:
	var graph := RdotGraph.getInstance()

	graph.producerUpdateValueVersion(node)
	graph.producerAccessed(node)

	assert(node.state != State.ERRORED, "Error in computed.")

	return node.value

static func createdComputed(computation: Callable):
	var node = RdotComputedInternal.new()
	node.computation = computation
	
	var computed = func():
		return computedGet(node)

	return [computed, node]

func producerMustRecompute(node: RdotNode) -> bool:
	return node.state == State.UNSET or node.state == State.COMPUTING

func _init():
	self.dirty = true
	self.producerRecomputeValue = func(node: RdotNode):
		assert(node.state != State.COMPUTING, "Detected cycle in computations.")

		var graph := RdotGraph.getInstance()
		
		var oldState = node.state
		var oldValue = node.value
		node.state = State.COMPUTING

		var prevConsumer = graph.consumerBeforeComputation(node)
		var newValue = node.computation.call(node.wrapper)
		var oldOk = oldState != State.UNSET&&oldState != State.ERRORED
		var wasEqual = oldOk&&node.equal.call(node.wrapper, oldValue, newValue)

		graph.consumerAfterComputation(node, prevConsumer)

		if wasEqual:
			node.value = oldValue
			node.state = oldState
			return

		node.value = newValue
		node.state = State.SET
		node.version += 1
