# TextLegibility
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Makes Label3D text bolder as it gets smaller on screen, so it stays legible at a distance instead of fading into a gray blur.

Thin strokes narrower than a pixel get blended with the background. A same-colored outline thickens every stroke; with MSDF fonts it is computed from the glyph's distance field, so it is cheap (one extra pass on the same atlas) and doesn't change the text layout.  Only labels that have no outline of their own (outline_size == 0) and use an MSDF font are managed.

## Properties

| Name                     | Type                                                                               | Default |
| ------------------------ | ---------------------------------------------------------------------------------- | ------- |
| [_labels](#prop--labels) | [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | `{}`    |

## Methods

| Returns                                                                            | Name                                                                                                                |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| [Font](https://docs.godotengine.org/en/stable/classes/class_font.html)             | [_label_font](#-label-font) ( label: [Label3D](https://docs.godotengine.org/en/stable/classes/class_label3d.html) ) |
| [FontFile](https://docs.godotengine.org/en/stable/classes/class_fontfile.html)     | [_msdf_font](#-msdf-font) ( font: [Font](https://docs.godotengine.org/en/stable/classes/class_font.html) )          |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_on_node_added](#-on-node-added) ( node: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) )  |
| void                                                                               | [_ready](#-ready) (  )                                                                                              |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [_settings](#-settings) ( label: [Label3D](https://docs.godotengine.org/en/stable/classes/class_label3d.html) )     |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_update](#-update) ( _delta: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) )            |

## Constants

### FULL_SIZE_ANGLE = `0.015` {#const-FULL-SIZE-ANGLE}

Apparent em size (font_size * pixel_size / distance, in radians) at and above which text gets no extra weight. 0.015 = an 18mm em seen from 1.2m.

### ICON_FONT = `<Object>` {#const-ICON-FONT}

Icon glyphs fill their em with much thinner strokes than letters, so they are treated as if their em were this much smaller.

### ICON_SIZE_FACTOR = `0.5` {#const-ICON-SIZE-FACTOR}

No description provided yet.

### MAX_WEIGHT_OF_MSDF_RANGE = `0.95` {#const-MAX-WEIGHT-OF-MSDF-RANGE}

Upper bound as a fraction of the em. MSDF fonts can only draw outlines up to msdf_pixel_range / (2 * msdf_size) before artifacts (0.21 for Montserrat, 0.18 for the icons); the per-font limit is this fraction of that.

### META_SETTINGS = `"_text_legibility"` {#const-META-SETTINGS}

No description provided yet.

### WEIGHT_PER_STEP = `0.11` {#const-WEIGHT-PER-STEP}

Outline added per unit of (FULL_SIZE_ANGLE / angle - 1), as a fraction of the em. Tuned so an 18mm em at 3m gets an outline of ~3 font pixels (0.17 em).

## Property Descriptions

### _labels: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#prop--labels}

Label3D -> true. Labels leave the set when freed or taken out of the tree; node_added puts them back if they re-enter.

## Method Descriptions

### _label_font (label: [Label3D](https://docs.godotengine.org/en/stable/classes/class_label3d.html)  ) -> [Font](https://docs.godotengine.org/en/stable/classes/class_font.html) {#-label-font}

Same lookup as Label3D: own font, else the project theme / custom font, else the engine fallback.

### _msdf_font (font: [Font](https://docs.godotengine.org/en/stable/classes/class_font.html)  ) -> [FontFile](https://docs.godotengine.org/en/stable/classes/class_fontfile.html) {#-msdf-font}

The underlying FontFile if it renders as MSDF, else null.

### _on_node_added (node: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-on-node-added}

No description provided yet.

### _ready ( ) -> void {#-ready}

No description provided yet.

### _settings (label: [Label3D](https://docs.godotengine.org/en/stable/classes/class_label3d.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#-settings}

Per-label settings, recomputed when the label's font changes (e.g. a button switching to its icon font). Only labels without their own outline, in an MSDF font, are managed.

### _update (_delta: [float](https://docs.godotengine.org/en/stable/classes/class_float.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-update}

No description provided yet.
