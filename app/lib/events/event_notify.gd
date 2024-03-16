extends Event
class_name EventNotify

enum Type {
	INFO,
	SUCCESS,
	WARNING,
	DANGER
}

var message: String
var type: Type