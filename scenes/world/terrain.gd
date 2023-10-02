@tool
extends Node3D

@export var zsize: int = 64
@export var ysize: int = 16
@export var terrain_color: Color = Color.PURPLE
@export var update: bool = false
@export var clear_geometry: bool = false
@export var noise: FastNoiseLite
@export var big_noise: FastNoiseLite
@export var noise_h: float = 3.0
@export var big_noise_h: float = 20.0

var mesh_left: SurfaceTool
var mesh_right: SurfaceTool

var tunnel_width: float = 26



# Called when the node enters the scene tree for the first time.
func _ready():
	_clear_geometry()
	_build_terrain()


func _build_terrain():
	var ml = SurfaceTool.new()
	var mr = SurfaceTool.new()
	
	ml.begin(Mesh.PRIMITIVE_TRIANGLES)
	mr.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(zsize + 1):
		for y in range(ysize + 1):
			var x: float = noise.get_noise_2d(
				z, y
			) * noise_h + (big_noise.get_noise_2d(
				z, y
			) * big_noise_h)

			var rx: float = x
			var lx: float = x
			
			var progress_factor = clamp((float(z) / (zsize + 1)), 0.0, 0.75)
			progress_factor *= progress_factor
			progress_factor = 1.0 - progress_factor
			
			rx += (tunnel_width / 2) * progress_factor
			lx -= (tunnel_width / 2) * progress_factor

			var height_factor = 1 - abs(y - (ysize / 2.0)) / (ysize / 2.0)
			lx *= height_factor
			rx *= height_factor
			ml.set_color(terrain_color)
			mr.set_color(terrain_color)

			var uv = Vector2()
			uv.x = inverse_lerp(0,ysize,y)
			uv.y = inverse_lerp(0,zsize,z)
			ml.set_uv(uv)
			mr.set_uv(uv)

			ml.add_vertex(Vector3(lx, y, -z))
			mr.add_vertex(Vector3(rx, y, -z))

	var vert: int = 0
	for z in zsize:
		for y in ysize:
			ml.set_smooth_group(vert)
			ml.add_index(vert)
			ml.add_index(vert + 1)
			ml.add_index(vert + ysize + 1)
			ml.add_index(vert + ysize + 1)
			ml.add_index(vert + 1)
			ml.add_index(vert + ysize + 2)
			mr.add_index(vert)
			mr.add_index(vert + 1)
			mr.add_index(vert + ysize + 1)
			mr.add_index(vert + ysize + 1)
			mr.add_index(vert + 1)
			mr.add_index(vert + ysize + 2)
			vert += 1
		vert += 1

#	mr.add_vertex(Vector3(1, 0, 0))
#	ml.add_vertex(Vector3(-1, 0, 1))
#	mr.add_vertex(Vector3(1, 0, 1))
#	ml.add_vertex(Vector3(-1, 1, 0))
#	mr.add_vertex(Vector3(1, 1, 0))
	
	ml.generate_normals(false)
	ml.generate_tangents()
#	ml.index()
	mr.generate_normals(false)
	mr.generate_tangents()
#	mr.index()
	$MeshLeft.mesh = ml.commit()
	$MeshRight.mesh = mr.commit()
	
	var csl = ConcavePolygonShape3D.new()
	csl.set_faces($MeshLeft.mesh.get_faces())
	$BodyLeft/CollisionShape3D.shape = csl
	var csr = ConcavePolygonShape3D.new()
	csr.backface_collision = true
	csr.set_faces($MeshRight.mesh.get_faces())
	$BodyRight/CollisionShape3D.shape = csr

func _clear_geometry():
	$BodyRight/CollisionShape3D.shape = null
	$BodyLeft/CollisionShape3D.shape = null
	$MeshLeft.mesh = null
	$MeshRight.mesh = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if update:
		update = false
		_build_terrain()
	if clear_geometry:
		clear_geometry = false
		_clear_geometry()
