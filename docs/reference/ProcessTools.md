# ProcessTools
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Methods

| Returns                                                                        | Name                                                                                                                                                                                                           |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html) | [throttle](#throttle) ( callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html), delay: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) )                |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)   | [timed_signal](#timed-signal) ( target_signal: [Signal](https://docs.godotengine.org/en/stable/classes/class_signal.html), timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) ) |

## Method Descriptions

### throttle (callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html) , delay: [int](https://docs.godotengine.org/en/stable/classes/class_int.html)  ) -> [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html) {#throttle}

Calls the callback at most once every `delay` milliseconds. The first call runs right away. Calls that arrive inside the window are collapsed, and the latest one runs when the window ends, so the final value is never lost. Pending calls are dropped if the callback's object has been freed.

### timed_signal (target_signal: [Signal](https://docs.godotengine.org/en/stable/classes/class_signal.html) , timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#timed-signal}

Waits for `target_signal` and returns its argument, or `ERR_TIMEOUT` if it doesn't emit within `timeout` seconds.
