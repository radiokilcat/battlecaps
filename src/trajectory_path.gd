extends MeshInstance3D

## Draws a line indicating the predicted path of a falling cap.
## Call [method show_path] to display an animated line from ``start``
## toward ``end``. Calling [method update_path] moves the line
## smoothly as the cap or target position changes.

@export var line_color: Color = Color.CADET_BLUE
@export var duration: float = 0.2

var _mesh := ImmediateMesh.new()
var _material := StandardMaterial3D.new()

var _start: Vector3 = Vector3.ZERO
var _end: Vector3 = Vector3.ZERO
var _target_start: Vector3 = Vector3.ZERO
var _target_end: Vector3 = Vector3.ZERO

func _ready() -> void:
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.albedo_color = line_color
	_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	_mesh.surface_end()
	mesh = _mesh
	material_override = _material
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	var t: float = min(1.0, delta / duration)
	_start = _start.lerp(_target_start, t)
	_end = _end.lerp(_target_end, t)
	_update_mesh()

func show_path(start: Vector3, end: Vector3) -> void:
	_start = start
	_end = start
	_target_start = start
	_target_end = end
	visible = true

func update_path(start: Vector3, end: Vector3) -> void:
	_target_start = start
	_target_end = end

func _update_mesh() -> void:
	if _start.distance_to(_end) <= 0.0:
		hide()
		return
	visible = true
	_mesh.clear_surfaces()
	_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	_mesh.surface_add_vertex(_start)
	_mesh.surface_add_vertex(_end)
	_mesh.surface_end()
