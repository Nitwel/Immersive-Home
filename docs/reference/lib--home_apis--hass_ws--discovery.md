# Discovery
**Inherits:** [RefCounted](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

## Description

Finds Home Assistant installs on the local network using mDNS (zeroconf).

Home Assistant announces itself as `_home-assistant._tcp.local`. Queries are sent from a random port, which makes them "legacy unicast" queries (RFC 6762, section 6.7): responders answer straight to that port. So no multicast group has to be joined, which would need a multicast lock on Android.

## Methods

| Returns                                                                                                                                                        | Name                                                                                                                                                                                                                                                                                                                                                             |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                                                                                   | [_append_u16](#-append-u16) ( packet: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html), value: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) )                                                                                                                                                |
| [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html)                                                                   | [_build_query](#-build-query) ( questions: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) )                                                                                                                                                                                                                                            |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] | [_collect_installs](#-collect-installs) ( records: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] )                                                                                                                                              |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] | [_find](#-find) ( records: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\], type: [int](https://docs.godotengine.org/en/stable/classes/class_int.html), name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `""` ) |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)                                                                                       | [_missing_questions](#-missing-questions) ( records: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] )                                                                                                                                            |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] | [_parse_packet](#-parse-packet) ( data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) )                                                                                                                                                                                                                           |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)                                                                             | [_read_name](#-read-name) ( data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html), offset: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) )                                                                                                                                                   |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)                                                                             | [_read_txt](#-read-txt) ( data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) )                                                                                                                                                                                                                                   |
| [int](https://docs.godotengine.org/en/stable/classes/class_int.html)                                                                                           | [_read_u16](#-read-u16) ( data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html), offset: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) )                                                                                                                                                     |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] | [discover](#discover) ( tree: [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html), timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) = `2.0` )                                                                                                                                                      |

## Constants

### CLASS_IN = `1` {#const-CLASS-IN}

No description provided yet.

### MDNS_ADDRESS = `"224.0.0.251"` {#const-MDNS-ADDRESS}

No description provided yet.

### MDNS_PORT = `5353` {#const-MDNS-PORT}

No description provided yet.

### QUERY_INTERVAL = `600` {#const-QUERY-INTERVAL}

Milliseconds between repeated queries, as UDP packets can get lost.

### SERVICE = `"_home-assistant._tcp.local"` {#const-SERVICE}

No description provided yet.

### SetupCode = `<Object>` {#const-SetupCode}

No description provided yet.

### TYPE_A = `1` {#const-TYPE-A}

No description provided yet.

### TYPE_PTR = `12` {#const-TYPE-PTR}

No description provided yet.

### TYPE_SRV = `33` {#const-TYPE-SRV}

No description provided yet.

### TYPE_TXT = `16` {#const-TYPE-TXT}

No description provided yet.

## Method Descriptions

### static _append_u16 (packet: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) , value: [int](https://docs.godotengine.org/en/stable/classes/class_int.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-append-u16}

No description provided yet.

### static _build_query (questions: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)  ) -> [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) {#-build-query}

No description provided yet.

### static _collect_installs (records: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\]  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] {#-collect-installs}

No description provided yet.

### static _find (records: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] , type: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) , name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `""`  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] {#-find}

No description provided yet.

### static _missing_questions (records: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\]  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#-missing-questions}

Asks for the service first, then for the records of found instances that were not included in the answers so far.

### static _parse_packet (data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html)  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] {#-parse-packet}

No description provided yet.

### static _read_name (data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) , offset: [int](https://docs.godotengine.org/en/stable/classes/class_int.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#-read-name}

Reads a (possibly compressed) domain name. Returns `{"name": String, "end": int}` where `end` is the offset right after the name, or an empty dictionary if it's malformed.

### static _read_txt (data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#-read-txt}

No description provided yet.

### static _read_u16 (data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) , offset: [int](https://docs.godotengine.org/en/stable/classes/class_int.html)  ) -> [int](https://docs.godotengine.org/en/stable/classes/class_int.html) {#-read-u16}

No description provided yet.

### static discover (tree: [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html) , timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) = `2.0`  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)\] {#discover}

Searches the network for `timeout` seconds and returns the installs found as `{"name": String, "url": String, "version": String, "uuid": String}`, where `url` is the websocket URL expected by the hass_ws adapter.
