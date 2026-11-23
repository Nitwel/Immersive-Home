# EntityFactory
**Inherits:** [RefCounted](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

## Description

This class is used to create entities based on their type

## Properties

| Name                                         | Type                                                                     | Default |
| -------------------------------------------- | ------------------------------------------------------------------------ | ------- |
| [SUPPORTED_DOMAINS](#prop-SUPPORTED-DOMAINS) | [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) |         |

## Methods

| Returns                                                                      | Name                                                                                                                                                                                                            |
| ---------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [create_entity](#create-entity) ( id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), type: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null` ) |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)   | [get_entity_icon](#get-entity-icon) ( type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                        |
| [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)       | [is_supported](#is-supported) ( domain_or_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                      |

## Constants

### AirQualityEntity = `<Object>` {#const-AirQualityEntity}

No description provided yet.

### AlarmEntity = `<Object>` {#const-AlarmEntity}

No description provided yet.

### BinarySensorEntity = `<Object>` {#const-BinarySensorEntity}

No description provided yet.

### ButtonEntity = `<Object>` {#const-ButtonEntity}

No description provided yet.

### CalendarEntity = `<Object>` {#const-CalendarEntity}

No description provided yet.

### Camera = `<Object>` {#const-Camera}

No description provided yet.

### ClimateEntity = `<Object>` {#const-ClimateEntity}

No description provided yet.

### CoverEntity = `<Object>` {#const-CoverEntity}

No description provided yet.

### DateTimeEntity = `<Object>` {#const-DateTimeEntity}

No description provided yet.

### EventEntity = `<Object>` {#const-EventEntity}

No description provided yet.

### FanEntity = `<Object>` {#const-FanEntity}

No description provided yet.

### HumidifierEntity = `<Object>` {#const-HumidifierEntity}

No description provided yet.

### ICONS = `{"air_quality": "air", "alarm_control_panel": "shield", "automation": "smart_toy", "binary_sensor": "sensors", "button": "radio_button_checked", "calendar": "calendar_month", "camera": "photo_camera", "climate": "thermostat", "counter": "tag", "cover": "blinds", "date": "calendar_today", "datetime": "event", "device_tracker": "location_on", "event": "event", "fan": "mode_fan", "humidifier": "humidity_percentage", "image": "image", "input_boolean": "toggle_on", "input_button": "radio_button_checked", "input_number": "sliders", "input_select": "list", "input_text": "text_fields", "light": "lightbulb", "line_chart": "finance", "lock": "lock", "media_player": "play_circle", "number": "sliders", "person": "person", "scene": "palette", "script": "code", "select": "list", "sensor": "sensors", "sun": "wb_sunny", "switch": "toggle_on", "text": "text_fields", "time": "schedule", "timer": "timer", "todo": "checklist", "update": "system_update", "vacuum": "cleaning_services", "water_heater": "water_heater", "weather": "partly_cloudy_day", "zone": "location_on"}` {#const-ICONS}

No description provided yet.

### ImageEntity = `<Object>` {#const-ImageEntity}

No description provided yet.

### Light = `<Object>` {#const-Light}

No description provided yet.

### LineGraphEntity = `<Object>` {#const-LineGraphEntity}

No description provided yet.

### LockEntity = `<Object>` {#const-LockEntity}

No description provided yet.

### MediaPlayer = `<Object>` {#const-MediaPlayer}

No description provided yet.

### NumberEntity = `<Object>` {#const-NumberEntity}

No description provided yet.

### PersonEntity = `<Object>` {#const-PersonEntity}

No description provided yet.

### SCENES = `{"air_quality": <Object>, "alarm_control_panel": <Object>, "automation": <Object>, "binary_sensor": <Object>, "button": <Object>, "calendar": <Object>, "camera": <Object>, "climate": <Object>, "counter": <Object>, "cover": <Object>, "date": <Object>, "datetime": <Object>, "device_tracker": <Object>, "event": <Object>, "fan": <Object>, "humidifier": <Object>, "image": <Object>, "input_boolean": <Object>, "input_button": <Object>, "input_number": <Object>, "input_select": <Object>, "input_text": <Object>, "light": <Object>, "line_chart": <Object>, "lock": <Object>, "media_player": <Object>, "number": <Object>, "person": <Object>, "scene": <Object>, "script": <Object>, "select": <Object>, "sensor": <Object>, "sun": <Object>, "switch": <Object>, "text": <Object>, "time": <Object>, "timer": <Object>, "todo": <Object>, "update": <Object>, "vacuum": <Object>, "water_heater": <Object>, "weather": <Object>, "zone": <Object>}` {#const-SCENES}

Widget used for each Home Assistant domain. Several domains share a widget when they behave the same (e.g. input_boolean is a switch, scene/script are pressed once).

### SelectEntity = `<Object>` {#const-SelectEntity}

No description provided yet.

### Sensor = `<Object>` {#const-Sensor}

No description provided yet.

### SunEntity = `<Object>` {#const-SunEntity}

No description provided yet.

### Switch = `<Object>` {#const-Switch}

No description provided yet.

### TextEntity = `<Object>` {#const-TextEntity}

No description provided yet.

### TimerEntity = `<Object>` {#const-TimerEntity}

No description provided yet.

### TodoEntity = `<Object>` {#const-TodoEntity}

No description provided yet.

### UpdateEntity = `<Object>` {#const-UpdateEntity}

No description provided yet.

### VacuumEntity = `<Object>` {#const-VacuumEntity}

No description provided yet.

### WaterHeaterEntity = `<Object>` {#const-WaterHeaterEntity}

No description provided yet.

### WeatherEntity = `<Object>` {#const-WeatherEntity}

No description provided yet.

### ZoneEntity = `<Object>` {#const-ZoneEntity}

No description provided yet.

## Property Descriptions

### SUPPORTED_DOMAINS: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#prop-SUPPORTED-DOMAINS}

Home Assistant domains that create_entity can turn into an entity widget.

## Method Descriptions

### static create_entity (id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , type: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#create-entity}

No description provided yet.

### static get_entity_icon (type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#get-entity-icon}

No description provided yet.

### static is_supported (domain_or_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#is-supported}

Returns true if entities of this domain (or an entity id like "light.kitchen") can be placed.
