extends Event
## Emits a message to the user
class_name EventNotify

enum Type {
	## The message is informational
	INFO,
	## The message is a success message
	SUCCESS,
	## The message is a warning
	WARNING,
	## The message is an error
	DANGER
}

## The message to emit
var message: String

## The type of message to emit
var type: Type