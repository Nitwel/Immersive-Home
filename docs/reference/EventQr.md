# EventQr
**Inherits:** [EventBubble](/reference/EventBubble.html)

## Description

Emitted when a QR code was scanned with the virtual keyboard.

Bubbles up from the focused node (the `target`) and calls `_on_qr_scan(event)`. Set `bubbling` to false to handle the content yourself, otherwise the keyboard types it into the focused input.

## Properties

| Name               | Type                                                                       | Default |
| ------------------ | -------------------------------------------------------------------------- | ------- |
| [text](#prop-text) | [String](https://docs.godotengine.org/en/stable/classes/class_string.html) |         |

## Property Descriptions

### text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#prop-text}

The content of the QR code
