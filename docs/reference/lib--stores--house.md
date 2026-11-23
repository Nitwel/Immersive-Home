# House
**Inherits:** [Store](/reference/lib--stores--store.html)

## Description

Stores information about the house, its rooms and entities

## Methods

| Returns                                                                            | Name                                                                                                                 |
| ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [_defaults](#-defaults) (  )                                                                                         |
| void                                                                               | [_init](#-init) (  )                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [clear](#clear) (  )                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_room](#get-room) ( name: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [use_save_path](#use-save-path) ( path: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) ) |

## Constants

### DEMO_PATH = `"user://demo_house.json"` {#const-DEMO-PATH}

No description provided yet.

### PATH = `"user://house.json"` {#const-PATH}

Where the house is saved. The demo mode keeps its own house in DEMO_PATH, so it never touches the real one.

### StoreClass = `<Object>` {#const-StoreClass}

No description provided yet.

## Method Descriptions

### _defaults ( ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#-defaults}

No description provided yet.

### _init ( ) -> void {#-init}

No description provided yet.

### clear ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#clear}

No description provided yet.

### get_room (name: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-room}

No description provided yet.

### use_save_path (path: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#use-save-path}

Switches the file the house is saved in and loaded from. The house in memory is reset to an empty one, load_local() then reads the new file.
