extends RigidBody3D

signal cap_stopped(result: Globals.DIR_POS, owner: int)

@export var top_value: int = 1
@export var bottom_value: int = 1
@export var owner_id: int = 1

var is_stopped = false

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
