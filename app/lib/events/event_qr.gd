extends EventBubble
## Emitted when a QR code was scanned with the virtual keyboard.
##
## Bubbles up from the focused node (the [member target]) and calls [code]_on_qr_scan(event)[/code].
## Set [member bubbling] to false to handle the content yourself, otherwise the
## keyboard types it into the focused input.
class_name EventQr

## The content of the QR code
var text: String
