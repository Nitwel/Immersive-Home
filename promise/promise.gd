extends RefCounted
class_name Promise


enum Status {
	RESOLVED,
	REJECTED
}


signal settled(status: PromiseResult)
signal resolved(value: Variant)
signal rejected(reason: Rejection)


## Generic rejection reason
const PROMISE_REJECTED := "Promise rejected"


var is_settled := false


func _init(callable: Callable):
	resolved.connect(
		func(value: Variant): 
			is_settled = true
			settled.emit(PromiseResult.new(Status.RESOLVED, value)), 
		CONNECT_ONE_SHOT
	)
	rejected.connect(
		func(rejection: Rejection):
			is_settled = true
			settled.emit(PromiseResult.new(Status.REJECTED, rejection)), 
		CONNECT_ONE_SHOT
	)
	
	callable.call_deferred(
		func(value: Variant):
			if not is_settled:
				resolved.emit(value),
		func(rejection: Rejection):
			if not is_settled:
				rejected.emit(rejection)
	)

	
func then(resolved_callback: Callable) -> Promise:
	resolved.connect(
		resolved_callback, 
		CONNECT_ONE_SHOT
	)
	return self
	
	
func catch(rejected_callback: Callable) -> Promise:
	rejected.connect(
		rejected_callback, 
		CONNECT_ONE_SHOT
	)
	return self
	
	
static func from(input_signal: Signal) -> Promise:
	return Promise.new(
		func(resolve: Callable, _reject: Callable):
			var number_of_args := input_signal.get_object().get_signal_list() \
				.filter(func(signal_info: Dictionary) -> bool: return signal_info["name"] == input_signal.get_name()) \
				.map(func(signal_info: Dictionary) -> int: return signal_info["args"].size()) \
				.front() as int
			
			if number_of_args == 0:
				await input_signal
				resolve.call(null)
			else:
				# only one arg in signal is allowed for now
				var result = await input_signal
				resolve.call(result)
	)


static func from_many(input_signals: Array[Signal]) -> Array[Promise]:
	return input_signals.map(
		func(input_signal: Signal): 
			return Promise.from(input_signal)
	)

	
static func all(promises: Array[Promise]) -> Promise:
	return Promise.new(
		func(resolve: Callable, reject: Callable):
			var resolved_promises: Array[bool] = []
			var results := []
			results.resize(promises.size())
			resolved_promises.resize(promises.size())
			resolved_promises.fill(false)
	
			for i in promises.size():
				promises[i].then(
					func(value: Variant):
						results[i] = value
						resolved_promises[i] = true
						if resolved_promises.all(func(value: bool): return value):
							resolve.call(results)
				).catch(
					func(rejection: Rejection):
						reject.call(rejection)
				)
	)
	
	
static func any(promises: Array[Promise]) -> Promise:
	return Promise.new(
		func(resolve: Callable, reject: Callable):
			var rejected_promises: Array[bool] = []
			var rejections: Array[Rejection] = []
			rejections.resize(promises.size())
			rejected_promises.resize(promises.size())
			rejected_promises.fill(false)
	
			for i in promises.size():
				promises[i].then(
					func(value: Variant): 
						resolve.call(value)
				).catch(
					func(rejection: Rejection):
						rejections[i] = rejection
						rejected_promises[i] = true
						if rejected_promises.all(func(value: bool): return value):
							reject.call(PromiseAnyRejection.new(PROMISE_REJECTED, rejections))
				)
	)


class PromiseResult:
	var status: Status
	var payload: Variant
	
	func _init(_status: Status, _payload: Variant):
		status = _status
		payload = _payload
		
		
class Rejection:
	var reason: String
	var stack: Array
	
	func _init(_reason: String):
		reason = _reason
		stack = get_stack() if OS.is_debug_build() else []
		
		
	func as_string() -> String:
		return ("%s\n" % reason) + "\n".join(
			stack.map(
				func(dict: Dictionary) -> String: 
					return "At %s:%i:%s" % [dict["source"], dict["line"], dict["function"]]
		))
	

class PromiseAnyRejection extends Rejection:
	var group: Array[Rejection]
	
	func _init(_reason: String, _group: Array[Rejection]):
		super(_reason)
		group = _group
