static func timed_signal(target: Node, target_signal: Signal, timeout: int):
	var promise = Promise.new(func(resolve, reject):
		var timer=target.get_tree().create_timer(timeout)
		
		timer.timeout.connect(func():
			resolve.call(Error.ERR_TIMEOUT)
		)

		target_signal.connect(func(result):
			resolve.call(result))
	)

	var result = await promise.settled
	return result.payload