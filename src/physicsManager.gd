extends Node
class_name PhysicsWatcher

@export var capsContainer: Node

@export var min_speed: float = 0.05
var watching := false

func start_watch():
	watching = true

func all_caps_stopped() -> bool:
	if not watching: return false
	for cap in capsContainer.get_children():
		if cap is RigidBody3D:
			if not cap.sleeping and cap.linear_velocity.length() > min_speed:
				return false
	return true
