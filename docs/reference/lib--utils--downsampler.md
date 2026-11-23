# Downsampler
**Inherits:** [RefCounted](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

## Description

Streams stereo audio frames down to mono 16 bit PCM at a lower sample rate.

Each output sample is the average of the input frames it covers (a box filter), which suppresses most of the aliasing that plain sample dropping causes. State is kept between calls so no frames are lost at chunk borders.

## Properties

| Name                   | Type                                                                     | Default |
| ---------------------- | ------------------------------------------------------------------------ | ------- |
| [_acc](#prop--acc)     | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) | `0.0`   |
| [_count](#prop--count) | [int](https://docs.godotengine.org/en/stable/classes/class_int.html)     | `0`     |
| [_phase](#prop--phase) | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) | `0.0`   |
| [ratio](#prop-ratio)   | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |         |

## Methods

| Returns                                                                            | Name                                                                                                                                                                                             |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| void                                                                               | [_init](#-init) ( source_rate: [float](https://docs.godotengine.org/en/stable/classes/class_float.html), target_rate: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) ) |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [process](#process) ( frames: [PackedVector2Array](https://docs.godotengine.org/en/stable/classes/class_packedvector2array.html) )                                                               |

## Property Descriptions

### _acc: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#prop--acc}

No description provided yet.

### _count: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) {#prop--count}

No description provided yet.

### _phase: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#prop--phase}

No description provided yet.

### ratio: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#prop-ratio}

No description provided yet.

## Method Descriptions

### _init (source_rate: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) , target_rate: [float](https://docs.godotengine.org/en/stable/classes/class_float.html)  ) -> void {#-init}

No description provided yet.

### process (frames: [PackedVector2Array](https://docs.godotengine.org/en/stable/classes/class_packedvector2array.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#process}

Converts the given stereo frames. Returns little-endian signed 16 bit PCM and the peak absolute amplitude of the converted samples.
