extends Node

## Calls the latest callback if the function is not called again within the delay
func debounce(callback: Callable, delay: int) -> Callable:
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	add_child(timer)

	timer.timeout.connect(func():
		var args=timer.get_meta("args")
		callback.callv(args)
		timer.set_meta("args", null)
	)

	# TODO: Implement variadic arguments when available https://github.com/godotengine/godot/pull/82808
	var wrapper = func(arg1=null, arg2=null, arg3=null, arg4=null, arg5=null, arg6=null, arg7=null, arg8=null, arg9=null):
		var args = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9].slice(0, callback.get_argument_count())
		timer.set_meta("args", args)
		timer.stop()
		timer.start(delay / 1000.0)

	return wrapper

## Calls the latest callback each time the time since the last call is greater than the delay
func throttle(callback: Callable, delay: int) -> Callable:
	var last_called = 0

	var wrapper = func(arg1=null, arg2=null, arg3=null, arg4=null, arg5=null, arg6=null, arg7=null, arg8=null, arg9=null):
		var args = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9].slice(0, callback.get_argument_count())

		var now = Time.get_ticks_msec()
		if now - last_called > delay:
			last_called = now
			callback.callv(args)

	return wrapper

## Combines debounce and throttle
func throttle_bouce(callback: Callable, delay: int) -> Callable:
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	add_child(timer)

	timer.timeout.connect(func():
		var args=timer.get_meta("args")
		if args == null:
			return

		callback.callv(args)
		timer.set_meta("args", null)
	)

	# TODO: Implement variadic arguments when available https://github.com/godotengine/godot/pull/82808
	var wrapper = func(arg1=null, arg2=null, arg3=null, arg4=null, arg5=null, arg6=null, arg7=null, arg8=null, arg9=null):
		var args = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9].slice(0, callback.get_argument_count())
		timer.set_meta("args", args)
		
		if timer.is_stopped():
			callback.callv(args)
			timer.start(delay / 1000.0)
			timer.set_meta("args", null)

	return wrapper

func timed_signal(target_signal: Signal, timeout: int):
	var promise = Promise.new(func(resolve, _reject):
		var timer=get_tree().create_timer(timeout)
		
		timer.timeout.connect(func():
			resolve.call(Error.ERR_TIMEOUT)
		)

		target_signal.connect(func(result):
			resolve.call(result))
	)

	var result = await promise.settled
	return result.payload