extends RefCounted
## Turns an OpenMapTiles vector tile (OpenFreeMap) into compact data for the maps:
##
##   "areas":     [[style, points, triangle indices, is hole]] filled polygons
##                (water, parks, landuse, buildings), triangulated here on the worker
##                thread so drawing them is cheap
##   "lines":     [[style, points]] roads, railways, rivers
##   "labels":    [[style, text, point, rank]] place and water names
##   "buildings": [[min_height_m, height_m, ring]] for the 3D map
##   "woods", "parks": [ring] for scattering trees in the 3D map
##
## Coordinates are in tile units (0..1). Styles are keys of the palette in
## vector_map.gd. Runs on a worker thread, so it must not touch the scene tree.

const Mvt = preload ("./mvt.gd")
const Tiles = preload ("./map_tiles.gd")

const LAYERS = ["water", "waterway", "landuse", "landcover", "park", "building", "transportation", "place", "water_name"]
## Height used when OpenMapTiles has none (it usually derives one from levels).
const DEFAULT_HEIGHT = 8.0

const LANDUSE_STYLES = {
	"residential": "residential", "suburb": "residential", "neighbourhood": "residential",
	"commercial": "commercial", "retail": "commercial", "industrial": "commercial", "garages": "commercial", "railway": "commercial",
	"cemetery": "green", "pitch": "green", "playground": "green", "stadium": "green", "zoo": "green", "theme_park": "green",
	"hospital": "institution", "school": "institution", "university": "institution", "college": "institution", "kindergarten": "institution",
}
const LANDCOVER_STYLES = {
	"wood": "wood", "grass": "green", "wetland": "green", "farmland": "farmland", "sand": "sand", "ice": "ice", "rock": "rock",
}
const ROAD_STYLES = {
	"motorway": "motorway", "trunk": "motorway", "primary": "primary", "secondary": "secondary",
	"tertiary": "minor", "minor": "minor", "service": "service", "track": "path", "path": "path",
	"rail": "rail", "transit": "rail",
}
const PLACE_STYLES = {
	"city": "city", "town": "town", "village": "village", "suburb": "district", "quarter": "district", "neighbourhood": "district",
}

static func from_pbf(bytes: PackedByteArray) -> Dictionary:
	var layers = Mvt.new(bytes).decode(LAYERS)
	var result = {"areas": [], "lines": [], "labels": [], "buildings": [], "woods": [], "parks": []}

	for feature in _features(layers, "landuse"):
		var style = LANDUSE_STYLES.get(feature.properties.get("class"))
		if style != null and feature.type == 3:
			_add_areas(result, style, _rings(feature, layers.landuse.extent))

	for feature in _features(layers, "landcover"):
		var style = LANDCOVER_STYLES.get(feature.properties.get("class"))
		if style != null and feature.type == 3:
			var rings = _rings(feature, layers.landcover.extent)
			_add_areas(result, style, rings)
			if style == "wood":
				result.woods.append_array(_exterior(rings))

	for feature in _features(layers, "park"):
		if feature.type == 3 and feature.properties.get("class") == "park":
			var rings = _rings(feature, layers.park.extent)
			_add_areas(result, "green", rings)
			result.parks.append_array(_exterior(rings))

	for feature in _features(layers, "water"):
		if feature.type == 3 and feature.properties.get("brunnel") != "tunnel":
			_add_areas(result, "water", _rings(feature, layers.water.extent))

	for feature in _features(layers, "waterway"):
		if feature.type == 2 and feature.properties.get("brunnel") != "tunnel":
			var style = "river" if feature.properties.get("class") in ["river", "canal"] else "stream"
			for line in feature.geometry:
				result.lines.append([style, _normalized(line, layers.waterway.extent)])

	for feature in _features(layers, "building"):
		if feature.type != 3:
			continue
		var rings = _rings(feature, layers.building.extent)
		_add_areas(result, "building", rings)
		if not feature.properties.get("hide_3d", false):
			var height = float(feature.properties.get("render_height", DEFAULT_HEIGHT))
			var min_height = float(feature.properties.get("render_min_height", 0))
			for ring in _exterior(rings):
				result.buildings.append([min_height, height, ring])

	for feature in _features(layers, "transportation"):
		var style = ROAD_STYLES.get(feature.properties.get("class"))
		if style == null or feature.type != 2 or feature.properties.get("brunnel") == "tunnel":
			continue
		for line in feature.geometry:
			result.lines.append([style, _normalized(line, layers.transportation.extent)])

	for layer_name in ["place", "water_name"]:
		for feature in _features(layers, layer_name):
			if feature.type != 1 or feature.geometry.is_empty():
				continue
			var style = "water" if layer_name == "water_name" else PLACE_STYLES.get(feature.properties.get("class"))
			var text = feature.properties.get("name", feature.properties.get("name:latin"))
			if style == null or text == null:
				continue
			var point = feature.geometry[0][0] / float(layers[layer_name].extent)
			result.labels.append([style, str(text), point, int(feature.properties.get("rank", 10))])

	return result

## Triangulates each ring. Holes (negative area: islands, courtyards) are drawn in
## the land colour over their polygon.
static func _add_areas(result: Dictionary, style: String, rings: Array):
	for ring in rings:
		var indices = Geometry2D.triangulate_polygon(ring)
		if not indices.is_empty():
			result.areas.append([style, ring, indices, Mvt.ring_area(ring) < 0])

static func _features(layers: Dictionary, name: String) -> Array:
	return layers[name].features if layers.has(name) else []

## All rings of a polygon feature, normalized, keeping their winding.
static func _rings(feature: Dictionary, extent: float) -> Array:
	var rings = []
	for ring in feature.geometry:
		if ring.size() >= 3:
			rings.append(_normalized(ring, extent))
	return rings

static func _exterior(rings: Array) -> Array:
	return rings.filter(func(ring): return Mvt.ring_area(ring) > 0)

static func _normalized(points: PackedVector2Array, extent: float) -> PackedVector2Array:
	var result = PackedVector2Array()
	result.resize(points.size())
	for i in points.size():
		result[i] = points[i] / extent
	return result
