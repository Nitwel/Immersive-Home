extends Object
class_name CDTreplace

var cdt = null
var points = null
var edges = null
var triangles = null

func init(a,b,c):
	if ClassDB.can_instantiate("ConstrainedTriangulation"):
		cdt = ClassDB.instantiate("ConstrainedTriangulation")
		cdt.init(a,b,c)

func insert_vertices(lpoints):
	if cdt:
		cdt.insert_vertices(lpoints)
	else:
		points = lpoints

func insert_edges(ledges):
	if cdt:
		cdt.insert_edges(ledges)
	else:
		edges = ledges

func erase_outer_triangles():
	if cdt:
		cdt.erase_outer_triangles()
	else:
		if len(edges) == 2*len(points) and edges[0] == edges[-1]:
			triangles = Geometry2D.triangulate_polygon(points)
		else:
			print("Non-simple CDT triangulation")

func get_all_vertices():
	if cdt:
		return cdt.get_all_vertices()
	else:
		return points
	
func get_all_triangles():
	if cdt:
		return cdt.get_all_triangles()
	elif triangles:
		return triangles
	else:
		return PackedInt32Array()
	
