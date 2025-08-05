extends MeshInstance3D

## Draws a line indicating the predicted path of a falling cap.
## Call [method show_path] with the start and end positions to
## display the line; it will animate its length from the start
## point toward the end point.

@export var line_color: Color = Color.RED
@export var duration: float = 0.2

var _mesh := ImmediateMesh.new()
var _material := StandardMaterial3D.new()

func _ready() -> void:
    _material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    _material.albedo_color = line_color
    _mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    _mesh.surface_end()
    mesh = _mesh
    material_override = _material
    visible = false

func show_path(start: Vector3, end: Vector3) -> void:
    # Prepare tween to animate line growth
    visible = true
    var direction: Vector3 = end - start
    var length: float = direction.length()
    if length <= 0.0:
        hide()
        return
    direction = direction.normalized()

    var tween := create_tween()
    tween.tween_method(_update_line.bind(start, direction), 0.0, length, duration)

func update_path(start: Vector3, end: Vector3) -> void:
    """Instantly draws a line from ``start`` to ``end`` without animation."""
    var direction: Vector3 = end - start
    var length: float = direction.length()
    if length <= 0.0:
        hide()
        return
    direction = direction.normalized()
    visible = true
    _update_line(start, direction, length)

func _update_line(start: Vector3, dir: Vector3, current_length: float) -> void:
    var end_point := start + dir * current_length
    _mesh.clear_surfaces()
    _mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    _mesh.surface_add_vertex(start)
    _mesh.surface_add_vertex(end_point)
    _mesh.surface_end()
