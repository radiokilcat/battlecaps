extends Node
class_name PhysicsWatcher

@export var capsContainer: Node

@export var min_speed: float = 0.05
var watching := false

var _caps_container: Node = null
var _tracked_caps: Dictionary = {}      # Node → bool (лежит/сбит)
var _turn_baseline: Dictionary = {}     # снимок начала хода
var _removed_this_turn: Array = []
var _container_initialized := false

func _ready() -> void:
	_ensure_caps_container()

func start_watch():
	_ensure_caps_container()
	if _caps_container == null:
		push_warning("PhysicsWatcher.start_watch(): capsContainer is not assigned.")
		watching = false
		return
	watching = true
	_removed_this_turn.clear()
	_rebuild_tracking()
	_turn_baseline = _tracked_caps.duplicate()

func all_caps_stopped() -> bool:
	if not watching: return false
	_ensure_caps_container()
	if _caps_container == null:
		return false
	for cap in _caps_container.get_children():
		if cap is RigidBody3D:
			if not cap.sleeping and cap.linear_velocity.length() > min_speed:
				return false
	return true

func consume_new_knockouts() -> Array:
	if not watching:
		return []
	_ensure_caps_container()
	if _caps_container == null:
		return []
	var knocked: Array = _detect_new_knockouts()
	var valid_caps: Array = []
	for cap in knocked:
		if is_instance_valid(cap):
			valid_caps.append(cap)
	watching = false
	_turn_baseline = _tracked_caps.duplicate()
	_removed_this_turn.clear()
	return valid_caps

func _ensure_caps_container() -> void:
	if _caps_container and _container_initialized:
		return
	if _caps_container == null:
		_caps_container = capsContainer
	if _caps_container and not _container_initialized:
		_init_caps_container()
		_container_initialized = true

func _init_caps_container() -> void:
	var enter_callable := Callable(self, "_on_caps_child_entered")
	var exit_callable := Callable(self, "_on_caps_child_exiting")
	if _caps_container and _caps_container.has_signal("child_entered_tree") and not _caps_container.child_entered_tree.is_connected(enter_callable):
		_caps_container.child_entered_tree.connect(enter_callable)
	if _caps_container and _caps_container.has_signal("child_exiting_tree") and not _caps_container.child_exiting_tree.is_connected(exit_callable):
		_caps_container.child_exiting_tree.connect(exit_callable)
	_rebuild_tracking()

func _on_caps_child_entered(child: Node) -> void:
	if not _is_trackable_cap(child):
		return
	call_deferred("_track_cap", child)

func _on_caps_child_exiting(child: Node) -> void:
	if _tracked_caps.has(child):
		if _turn_baseline.has(child):
			_removed_this_turn.append(child)
		_tracked_caps.erase(child)

func _track_cap(cap: Node) -> void:
	if not _is_trackable_cap(cap):
		return
	_tracked_caps[cap] = _is_cap_knocked(cap)

func _rebuild_tracking() -> void:
	_tracked_caps.clear()
	if _caps_container == null:
		return
	for child in _caps_container.get_children():
		if _is_trackable_cap(child):
			_tracked_caps[child] = _is_cap_knocked(child)

func _update_tracking() -> void:
	var to_remove: Array = []
	for cap in _tracked_caps.keys():
		if not is_instance_valid(cap) or cap.get_parent() != _caps_container:
			to_remove.append(cap)
			continue
		_tracked_caps[cap] = _is_cap_knocked(cap)
	for cap in to_remove:
		if _turn_baseline.has(cap):
			_removed_this_turn.append(cap)
		_tracked_caps.erase(cap)

func _detect_new_knockouts() -> Array:
	_update_tracking()
	var newly_knocked: Array = []
	for cap in _tracked_caps.keys():
		var knocked_now := bool(_tracked_caps[cap])
		var knocked_before := bool(_turn_baseline.get(cap, false))
		if knocked_now and not knocked_before:
			newly_knocked.append(cap)
	for cap in _removed_this_turn:
		if cap not in newly_knocked:
			newly_knocked.append(cap)
	return newly_knocked

func _is_trackable_cap(node: Node) -> bool:
	return node is Node3D

func _is_cap_knocked(node: Node) -> bool:
	if not (node is Node3D):
		return false
	var basis_y := (node as Node3D).global_transform.basis.y
	return basis_y.dot(Vector3.UP) < 0.85
