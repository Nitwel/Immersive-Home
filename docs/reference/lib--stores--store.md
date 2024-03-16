# Store
**Inherits:** [RefCounted](https://docs.godotengine.org/de/4.x/classes/class_refcounted.html)
    
## Description

Abstract class for saving and loading data to and from a file.

## Properties

| Name                           | Type                                                                      | Default |
| ------------------------------ | ------------------------------------------------------------------------- | ------- |
| [_loaded](#prop--loaded)       | [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | `false` |
| [_save_path](#prop--save-path) | [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | `null`  |

## Methods

| Returns                                                                   | Name                                                                                                            |
| ------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| void                                                                      | [clear](#clear) (  )                                                                                            |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [create_dict](#create-dict) (  )                                                                                |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [is_loaded](#is-loaded) (  )                                                                                    |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [load_local](#load-local) ( path: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )   |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [save_local](#save-local) ( path: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )   |
| void                                                                      | [use_dict](#use-dict) ( dict: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) ) |

## Signals

### on_loaded ( ) {#on-loaded}

Signal emitted when the data is loaded.

### on_saved ( ) {#on-saved}

Signal emitted when the data is saved.



## Constants

### VariantSerializer = `<Object>` {#const-VariantSerializer}

No description provided yet.

## Property Descriptions

### _loaded: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#prop--loaded}

No description provided yet.

### _save_path: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#prop--save-path}

No description provided yet.

## Method Descriptions

###  clear ( ) -> void {#clear}

Resets the data to its default state.

###  create_dict ( ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#create-dict}

No description provided yet.

###  is_loaded ( ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#is-loaded}

Returns true if the data has been loaded.

###  load_local (path: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#load-local}

No description provided yet.

###  save_local (path: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#save-local}

No description provided yet.

###  use_dict (dict: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html)  ) -> void {#use-dict}

No description provided yet.
