extends Node

const Connection = preload ("connection.gd")

signal on_authenticated()
signal _try_auth(success: bool)

enum AuthError {
	OK = 0,
	INVALID_TOKEN = 1,
	TIMEOUT = 2,
	UNKNOWN = 3
}

var connection: Connection
var token: String

var authenticated := false

func _init(connection: Connection):
	self.connection = connection

func authenticate(token: String=self.token) -> AuthError:
	self.token = token
	connection.on_packed_received.connect(_handle_message)

	var error = await ProcessTools.timed_signal(_try_auth, 10.0)

	if error == Error.ERR_TIMEOUT:
		return AuthError.TIMEOUT
	elif error == Error.ERR_CANT_RESOLVE:
		return AuthError.INVALID_TOKEN
	elif error == Error.OK:
		return AuthError.OK

	return AuthError.UNKNOWN

func _handle_message(message):
	match message["type"]:
		"auth_required":
			connection.send_packet({"type": "auth", "access_token": self.token})
		"auth_ok":
			authenticated = true
			_try_auth.emit(Error.OK)
			on_authenticated.emit()
		"auth_invalid":
			_try_auth.emit(Error.ERR_CANT_RESOLVE)
			EventSystem.notify("Failed to authenticate with Home Assistant. Check your token and try again.", EventNotify.Type.DANGER)
			connection.handle_disconnect()

func on_disconnect():
	authenticated = false