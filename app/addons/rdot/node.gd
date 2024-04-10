extends RefCounted
class_name RdotNode

var version := 0
var lastCleanEpoch := 0
var dirty := false

## Array[RdotNode] | null
var producerNode = null

## Array[int] | null
var producerLastReadVersion = null

## Array[int] | null
var producerIndexOfThis = null
var nextProducerIndex := 0

## Array[RdotNode] | null
var liveConsumerNode = null

## Array[int] | null
var liveConsumerIndexOfThis = null
var consumerAllowSignalWrites := false
var consumerIsAlwaysLive := false

var watched: Callable = Callable()
var unwatched: Callable = Callable()
var wrapper

func producerMustRecompute(node: RdotNode) -> bool:
	return false

var producerRecomputeValue: Callable = Callable()
var consumerMarkedDirty: Callable = Callable()
var consumerOnSignalRead: Callable = Callable()

# func _to_string():
# 	return "RdotNode {\n" + ",\n\t".join(get_property_list().map(func(dict): return dict.name + ": " + str(get(dict.name)))) + "\n}"
