# StateMachine
**Inherits:** [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)
    
## Description

Abstract class for a state machine

## Properties

| Name                                 | Type                                                                            | Default |
| ------------------------------------ | ------------------------------------------------------------------------------- | ------- |
| [current_state](#prop-current-state) | [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)             |         |
| [states](#prop-states)               | [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) |         |

## Methods

| Returns                                                             | Name                                                                                                            |
| ------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| void                                                                | [_ready](#-ready) (  )                                                                                          |
| void                                                                | [change_to](#change-to) ( new_state: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )  |
| [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) | [get_state](#get-state) ( state_name: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) ) |

## Signals

### changed (state_name: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , old_state: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) {#changed}

No description provided yet.





## Property Descriptions

### current_state: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) {#prop-current-state}

No description provided yet.

### states: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) {#prop-states}

No description provided yet.

## Method Descriptions

###  _ready ( ) -> void {#-ready}

No description provided yet.

###  change_to (new_state: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> void {#change-to}

Change the current state to the new state

###  get_state (state_name: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) {#get-state}

Get the state with the given name
