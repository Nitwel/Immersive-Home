extends RefCounted
class_name RdotGraph

static var instance: RdotGraph = null

static func getInstance() -> RdotGraph:
	if instance == null:
		instance = RdotGraph.new()
	return instance

var activeConsumer: RdotNode = null
var inNotificationPhase := false

var epoch := 1

var postSignalSetFn := Callable()
var watcherPending := false

var watcher = R.Watcher.new(func(_arg):
	if watcherPending:
		return

	watcherPending=true
	var endOfFrame=func():

		watcherPending=false
		for s in watcher.getPending():
			s.do_get()

		watcher.watch()

	endOfFrame.call_deferred()
)

func setActiveConsumer(consumer: RdotNode) -> RdotNode:
	var prev = activeConsumer
	activeConsumer = consumer
	return prev

func getActiveConsumer() -> RdotNode:
	return activeConsumer

func isInNotificationPhase() -> bool:
	return inNotificationPhase

func producerAccessed(node: RdotNode):
	assert(inNotificationPhase == false, "Signal read during notification phase")

	if activeConsumer == null:
		return

	if activeConsumer.consumerOnSignalRead.is_null() == false:
		activeConsumer.consumerOnSignalRead.call(node)

	var idx = activeConsumer.nextProducerIndex;
	activeConsumer.nextProducerIndex += 1

	assertConsumerNode(activeConsumer)

	if idx < activeConsumer.producerNode.size()&&activeConsumer.producerNode[idx] != node:
		if consumerIsLive(activeConsumer):
			var staleProducer = activeConsumer.producerNode[idx]
			producerRemoveLiveConsumerAtIndex(staleProducer, activeConsumer.producerIndexOfThis[idx])

	if RdotArray.do_get(activeConsumer.producerNode, idx) != node:
		RdotArray.do_set(activeConsumer.producerNode, idx, node)
		RdotArray.do_set(activeConsumer.producerIndexOfThis, idx, producerAddLiveConsumer(node, activeConsumer, idx) if consumerIsLive(activeConsumer) else 0)

	RdotArray.do_set(activeConsumer.producerLastReadVersion, idx, node.version)

func producerIncrementEpoch():
	epoch += 1

func producerUpdateValueVersion(node: RdotNode):
	if consumerIsLive(node)&&!node.dirty:
		return

	if !node.dirty&&node.lastCleanEpoch == epoch:
		return

	if !node.producerMustRecompute(node)&&!consumerPollProducersForChange(node):
		node.dirty = false;
		node.lastCleanEpoch = epoch
		return

	if node.producerRecomputeValue.is_null() == false:
		node.producerRecomputeValue.call(node)

	node.dirty = false
	node.lastCleanEpoch = epoch

func producerNotifyConsumers(node: RdotNode):
	if node.liveConsumerNode == null:
		return

	var prev = inNotificationPhase
	inNotificationPhase = true

	for consumer in node.liveConsumerNode:
		if !consumer.dirty:
			consumerMarkDirty(consumer)

	inNotificationPhase = prev

func producerUpdatesAllowed() -> bool:
	return activeConsumer == null||activeConsumer.consumerAllowSignalWrites != false

func consumerMarkDirty(node: RdotNode):
	node.dirty = true
	producerNotifyConsumers(node)

	if node.consumerMarkedDirty.is_null() == false:
		node.consumerMarkedDirty.call(node)

func consumerBeforeComputation(node: RdotNode) -> RdotNode:
	if node:
		node.nextProducerIndex = 0

	return setActiveConsumer(node)

func consumerAfterComputation(node: RdotNode, prevConsumer: RdotNode):
	setActiveConsumer(prevConsumer)

	if node == null||node.producerNode == null||node.producerIndexOfThis == null||node.producerLastReadVersion == null:
		return

	if consumerIsLive(node):
		for i in range(node.nextProducerIndex, node.producerNode.size()):
			producerRemoveLiveConsumerAtIndex(node.producerNode[i], node.producerIndexOfThis[i])

	while node.producerNode.size() > node.nextProducerIndex:
		node.producerNode.pop_back()
		node.producerLastReadVersion.pop_back()
		node.producerIndexOfThis.pop_back()

func consumerPollProducersForChange(node: RdotNode) -> bool:
	assertConsumerNode(node)

	for i in range(node.producerNode.size()):
		var producer = node.producerNode[i]
		var seenVersion = node.producerLastReadVersion[i]

		if seenVersion != producer.version:
			return true

		producerUpdateValueVersion(producer)

		if seenVersion != producer.version:
			return true

	return false

func consumerDestroy(node: RdotNode):
	assertConsumerNode(node)

	if consumerIsLive(node):
		for i in range(node.producerNode.size()):
			producerRemoveLiveConsumerAtIndex(node.producerNode[i], node.producerIndexOfThis[i])

	node.producerNode.clear()
	node.producerLastReadVersion.clear()
	node.producerIndexOfThis.clear()

	if node.liveConsumerNode:
		node.liveConsumerNode.clear()
		node.liveConsumerIndexOfThis.clear()

static func producerAddLiveConsumer(node: RdotNode, consumer: RdotNode, indexOfThis: int) -> int:
	assertProducerNode(node)
	assertConsumerNode(node)

	if node.liveConsumerNode.size() == 0:
		if node.watched.is_null() == false:
			node.watched.call(node.wrapper)

		for i in range(node.producerNode.size()):
			node.producerIndexOfThis[i] = producerAddLiveConsumer(node.producerNode[i], node, i)

	node.liveConsumerIndexOfThis.push_back(indexOfThis)
	node.liveConsumerNode.push_back(consumer)

	return node.liveConsumerNode.size() - 1

static func producerRemoveLiveConsumerAtIndex(node: RdotNode, idx: int):
	assertProducerNode(node)
	assertConsumerNode(node)

	assert(idx < node.liveConsumerNode.size(), "active consumer index %s is out of bounds of %s consumers)" % [idx, node.liveConsumerNode.size()])

	if node.liveConsumerNode.size() == 1:
		if node.unwatched.is_null() == false:
			node.unwatched.call(node.wrapper)

		for i in range(node.producerNode.size()):
			producerRemoveLiveConsumerAtIndex(node.producerNode[i], node.producerIndexOfThis[i])

	var lastIdx = node.liveConsumerNode.size() - 1
	node.liveConsumerNode[idx] = node.liveConsumerNode[lastIdx]
	node.liveConsumerIndexOfThis[idx] = node.liveConsumerIndexOfThis[lastIdx]

	node.liveConsumerNode.pop_back()
	node.liveConsumerIndexOfThis.pop_back()

	if idx < node.liveConsumerNode.size():
		var idxProducer = node.liveConsumerIndexOfThis[idx]
		var consumer = node.liveConsumerNode[idx]
		assertConsumerNode(consumer)
		consumer.producerIndexOfThis[idxProducer] = idx

static func consumerIsLive(node: RdotNode) -> bool:
	return node.consumerIsAlwaysLive||(node.liveConsumerNode != null&&node.liveConsumerNode.size() > 0)

static func assertConsumerNode(node: RdotNode):
	if node.producerNode == null:
		node.producerNode = []
	if node.producerIndexOfThis == null:
		node.producerIndexOfThis = []
	if node.producerLastReadVersion == null:
		node.producerLastReadVersion = []

static func assertProducerNode(node: RdotNode):
	if node.liveConsumerNode == null:
		node.liveConsumerNode = []
	if node.liveConsumerIndexOfThis == null:
		node.liveConsumerIndexOfThis = []
