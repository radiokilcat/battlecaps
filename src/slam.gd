extends RigidBody3D

signal cap_stopped(result: Globals.DIR_POS, owner: int)

@export var top_value: int = 1
@export var bottom_value: int = 1
@export var owner_id: int = 1

@export var use_editor_start := true       # брать стартовую позу из того, как стоит в сцене
@export var start_xform: Transform3D       # сюда можно руками сохранить позу (если use_editor_start=false)
@export var lift_mm := 2.0                 # чуть приподнимем при ресете, чтобы не клипалось о стол
@export var hide_when_inactive := true  # опционально: прятать неактивную битку


var is_stopped = false

func set_active() -> void:
	reset_to_start()
	freeze = false
	sleeping = false
	if hide_when_inactive and (self is Node3D):
		visible = true

func set_inactive() -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true
	sleeping = true
	if hide_when_inactive and (self is Node3D):
		visible = false


func _ready() -> void:
	if use_editor_start:
		start_xform = global_transform
	set_inactive()  # по умолчанию обе заморожены

func set_start_from_current() -> void:
	start_xform = global_transform

func reset_to_start() -> void:
	if start_xform == Transform3D():
		return
	var xf := start_xform
	xf.origin += xf.basis.y.normalized() * (lift_mm * 0.001)

	global_transform = xf
	set_inactive()

func _physics_process(delta):
	if is_stopped:
		return

	if linear_velocity.length() < 0.05 and angular_velocity.length() < 0.05:
		is_stopped = true
		emit_result()

func emit_result():
	var up_vector = global_transform.basis.y
	if up_vector.dot(Vector3.UP) > 0.9:
		emit_signal("cap_stopped", Globals.DIR_POS.UP,  owner_id)
	elif up_vector.dot(Vector3.DOWN) > 0.9:
		emit_signal("cap_stopped", Globals.DIR_POS.DOWN, owner_id)
	else:
		emit_signal("cap_stopped", Globals.DIR_POS.RIB, owner_id)
