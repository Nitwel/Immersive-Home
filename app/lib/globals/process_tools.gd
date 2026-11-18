@tool
extends Node

## Calls the callback at most once every [param delay] milliseconds.
## The first call runs right away. Calls that arrive inside the window are
## collapsed, and the latest one runs when the window ends, so the final value
## is never lost.
## Pending calls are dropped if the callback's object has been freed.
func throttle(callback: Callable, delay: int) -> Callable:
	# Dictionaries are shared by reference, so changes made inside the lambdas persist between calls.
	var state = {
		"last_called": -delay,
		"pending_args": null,
		"scheduled": false,
	}

	var flush = func():
		state.scheduled = false
		var args = state.pending_args
		state.pending_args = null

		if args == null || !callback.is_valid():
			return

		state.last_called = Time.get_ticks_msec()
		callback.callv(args)

	var wrapper = func(...args: Array):
		var elapsed = Time.get_ticks_msec() - state.last_called

		if elapsed >= delay && !state.scheduled:
			state.last_called = Time.get_ticks_msec()
			callback.callv(args)
			return

		state.pending_args = args

		if !state.scheduled:
			state.scheduled = true
			# SceneTreeTimers are freed by the tree after they fire, so nothing leaks.
			get_tree().create_timer(max(delay - elapsed, 0) / 1000.0).timeout.connect(flush)

	return wrapper

## Waits for [param target_signal] and returns its argument, or [constant ERR_TIMEOUT]
## if it doesn't emit within [param timeout] seconds.
func timed_signal(target_signal: Signal, timeout: float):
	# Lambdas capture locals by value, so `resolve` is handed over through a shared dictionary.
	var holder = {"resolve": null}
	var on_signal = func(result):
		if holder.resolve != null:
			holder.resolve.call(result)

	var promise = Promise.new(func(resolve, _reject):
		holder.resolve=resolve
		get_tree().create_timer(timeout).timeout.connect(func():
			resolve.call(Error.ERR_TIMEOUT)
		)
		target_signal.connect(on_signal)
	)

	var result = await promise.settled

	if target_signal.is_connected(on_signal):
		target_signal.disconnect(on_signal)

	return result.payload
