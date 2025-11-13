extends Node
class_name BaseController

# Base controller defines the minimal API turn states rely on.
# Concrete controllers (player/NPC) override the relevant methods.

func get_active_cap() -> RigidBody3D:
	return null

func get_aim_dir() -> Vector3:
	return Vector3.FORWARD

func get_power() -> float:
	return 0.0

func arm_to_start() -> void:
	pass

func start_charge() -> void:
	pass

func cancel_charge() -> void:
	pass

func shoot() -> void:
	push_error("BaseController.shoot() must be implemented by subclasses")
