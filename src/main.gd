extends Node3D

@onready var mode_1_button = $UI/mode_1
@onready var mode_2_button = $UI/mode_2
@onready var mode_3_button = $UI/mode_3
@onready var mode_4_button = $UI/mode_4
@onready var impulseLabel = $UI/impulse
@onready var impulseSlider = $UI/impulseSlider
# @onready var label_player1: Label = $UI/Label_Player1
# @onready var label_player2: Label = $UI/Label_Player2
@onready var label_up := $UI/sumUp
@onready var label_down := $UI/sumDown
@onready var flash := $UI/WhiteFlash
@onready var centerText := $UI/CenterText
@onready var turnSMText := $UI/turnSMLabel
@onready var matchSMText := $UI/matchSMLabel

@onready var trajectory_path := $TrajectoryPath/MeshInstance3D


@onready var match_sm = $MatchSM
@onready var turn_sm = $TurnSM
@onready var player_controller = $PlayerController
@onready var npc_controller = $NpcController

var rng = RandomNumberGenerator.new()
var up_count = 0
var down_count = 0
var bat_impulse = 100
var throw_bat = false
var held_cap: RigidBody3D = null
const SPAWN_HEIGHT = 4.0

func _ready():
	rng.randomize()
	# throwUpButton.pressed.connect(throw_caps)
	# stackCapsButton.pressed.connect(stack_caps_1)
	# mode_1_button.pressed.connect(run_mode_1)
	# impulseSlider.connect("value_changed", Callable(self, "_on_slider_value_changed"))
	# В TurnSM пока никого не ставим, контроллер назначается состояниями PlayerTurn/NpcTurn
	# Запускаем матч
	match_sm.transition_to("Init")


func flash_and_show_text(text: String) -> void:
# flash.modulate.a = 1.0
	# flash.visible = true
	centerText.text = text
	centerText.visible = true

	await get_tree().create_timer(1.0).timeout

	# flash.modulate.a = 0.0
	centerText.visible = false

# func _unhandled_input(event):
# 	if not throw_bat:
# 			return
# 	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
# 			if event.pressed:
# 					_begin_hold()
# 			elif held_cap:
# 					_release_hold()

# func _process(_delta):
# 		if held_cap:
# 				_update_hold()

# func _on_slider_value_changed(value):
# 	bat_impulse = value
# 	impulseLabel.text =  "impulse value: %d" % bat_impulse

# var visited_caps = []

# func count_fallen():
# 	for cap in get_tree().get_nodes_in_group("caps"):
# 		if not cap is RigidBody3D:
# 			continue

# 		if cap in visited_caps:
# 			continue

# 		var up_vector = cap.global_transform.basis.y

# 		if up_vector.dot(Vector3.UP) > 0.9:
# 			up_count += 1
# 		elif up_vector.dot(Vector3.DOWN) > 0.9:
# 			down_count += 1
		
# 		visited_caps.append(cap)
	

# 	label_up.text = "face up: %d" % up_count
# 	label_down.text = "face down: %d" % down_count

# func wait_until_caps_stop() -> void:
# 	while true:
# 		var all_stopped := true
# 		for cap in get_tree().get_nodes_in_group("caps"):
# 			if cap.linear_velocity.length() > 0.05 or cap.angular_velocity.length() > 0.05:
# 				all_stopped = false
# 				break
# 		if all_stopped:
# 			break
# 		await get_tree().process_frame

# func drop_cap_at_cursor_position():
# 	var camera = get_viewport().get_camera_3d()
# 	if camera == null:
# 		return

# 	var mouse_pos = get_viewport().get_mouse_position()
# 	var ray_origin = camera.project_ray_origin(mouse_pos)
# 	var ray_direction = camera.project_ray_normal(mouse_pos)

# 	# Определим, куда упадёт капса — например, на Y = 0 (пол)
# 	var plane = Plane(Vector3.UP, 0)
# 	var hit_pos = plane.intersects_ray(ray_origin, ray_direction)

# 	if hit_pos != null:
# 		var cap_instance = cap_scene.instantiate()
# 		cap_instance.position = hit_pos + Vector3.UP * 2.0  # немного выше, чтобы падала
# 		caps_container.add_child(cap_instance)

# 		# Добавим лёгкий подброс
# 		var rng = RandomNumberGenerator.new()
# 		rng.randomize()

# 		var impulse = Vector3(
# 			rng.randf_range(-0.5, 0.5),
# 			rng.randf_range(4.0, 6.0),
# 			rng.randf_range(-0.5, 0.5)
# 		)
# 		cap_instance.apply_impulse(Vector3.ZERO, impulse)

# 		var torque = Vector3(
# 			rng.randf_range(-3.0, 3.0),
# 			rng.randf_range(-5.0, 5.0),
# 			rng.randf_range(-3.0, 3.0)
# 		)
# 		cap_instance.apply_torque_impulse(torque)

# func drop_cap_straight_down():
# 	var camera = get_viewport().get_camera_3d()
# 	if camera == null:
# 		return

# 	var mouse_pos = get_viewport().get_mouse_position()
# 	var ray_origin = camera.project_ray_origin(mouse_pos)
# 	var ray_direction = camera.project_ray_normal(mouse_pos)

# 	# Пересекаем с плоскостью пола (Y=0)
# 	var plane = Plane(Vector3.UP, 0)
# 	var hit_pos = plane.intersects_ray(ray_origin, ray_direction)
# 	if hit_pos != null:
# 		var cap_instance = cap_scene.instantiate()
# 		PhysicsServer3D.body_set_enable_continuous_collision_detection(cap_instance, true)

# 		# Появляется над целевой точкой (высоту можно менять)
# 		var spawn_height = 4.0
# 		var start_pos = hit_pos + Vector3.UP * spawn_height
# 		cap_instance.position = start_pos

# 		trajectory_path.show_path(start_pos, hit_pos)

# 		caps_container.add_child(cap_instance)
# 		await get_tree().process_frame

# 		cap_instance.gravity_scale = 2.0

# 		# Немного вращения для реалистичности (опционально)
# 		# var torque = Vector3(
# 		#       rng.randf_range(-2.0, 2.0),
# 		#       rng.randf_range(-4.0, 4.0),
# 		#       rng.randf_range(-2.0, 2.0)
# 		# )
# 		var torque = Vector3(1, 2, 1)
# 		cap_instance.apply_torque_impulse(torque)
# 		cap_instance.mass = 50.0
# 		cap_instance.linear_velocity = Vector3(0, -50, 0)


# func _begin_hold():
# 	var camera = get_viewport().get_camera_3d()
# 	if camera == null:
# 			return
# 	var mouse_pos = get_viewport().get_mouse_position()
# 	var ray_origin = camera.project_ray_origin(mouse_pos)
# 	var ray_direction = camera.project_ray_normal(mouse_pos)
# 	var plane = Plane(Vector3.UP, 0)
# 	var hit_pos = plane.intersects_ray(ray_origin, ray_direction)
# 	if hit_pos == null:
# 			return
# 	held_cap = cap_scene.instantiate()
# 	PhysicsServer3D.body_set_enable_continuous_collision_detection(held_cap, true)
# 	caps_container.add_child(held_cap)
# 	var start_pos = hit_pos + Vector3.UP * SPAWN_HEIGHT
# 	held_cap.position = start_pos
# 	held_cap.freeze = true
# 	trajectory_path.show_path(start_pos, hit_pos)

# func _update_hold():
# 	var camera = get_viewport().get_camera_3d()
# 	if camera == null:
# 			return
# 	var mouse_pos = get_viewport().get_mouse_position()
# 	var ray_origin = camera.project_ray_origin(mouse_pos)
# 	var ray_direction = camera.project_ray_normal(mouse_pos)
# 	var plane = Plane(Vector3.UP, 0)
# 	var hit_pos = plane.intersects_ray(ray_origin, ray_direction)
# 	if hit_pos == null:
# 			return
# 	var start_pos = hit_pos + Vector3.UP * SPAWN_HEIGHT
# 	held_cap.position = start_pos
# 	trajectory_path.update_path(start_pos, hit_pos)

# func _release_hold():
# 	trajectory_path.hide()
# 	held_cap.freeze = false
# 	held_cap.gravity_scale = 2.0
# 	var torque = Vector3(1, 2, 1)
# 	held_cap.apply_torque_impulse(torque)
# 	held_cap.mass = 50.0
# 	held_cap.linear_velocity = Vector3(0, -50, 0)
# 	held_cap = null


# func stack_caps_1():
# 	var cap_count = 5
# 	var cap_height = 0.3
# 	var start_position = Vector3(0, 1, 0)

# 	var rng = RandomNumberGenerator.new()
# 	rng.randomize()

# 	for child in caps_container.get_children():
# 		child.queue_free()

# 	for i in range(cap_count):
# 		var cap_instance = cap_scene.instantiate()

# 		# Небольшой случайный сдвиг по X и Z
# 		var horizontal_offset = Vector3(
# 			rng.randf_range(-0.05, 0.05),
# 			0,
# 			rng.randf_range(-0.05, 0.05)
# 		)

# 		var vertical_offset = Vector3(0, i * cap_height, 0)
# 		cap_instance.position = start_position + vertical_offset + horizontal_offset

# 		# По желанию: добавить случайное вращение (чуть-чуть)
# 		cap_instance.rotation_degrees.y = rng.randf_range(-10, 10)

# 		caps_container.add_child(cap_instance)


# func throw_caps():
# 	up_count = 0
# 	down_count = 0
# 	var cap_count = 5
# 	var cap_height = 0.3
# 	var start_position = Vector3(0, 1, 0)

# 	for child in caps_container.get_children():
# 		child.queue_free()

# 	for i in range(cap_count):
# 		var cap_instance = cap_scene.instantiate()

# 		var horizontal_offset = Vector3(
# 			rng.randf_range(-0.3, 0.3),
# 			0,
# 			rng.randf_range(-0.3, 0.3)
# 		)
# 		cap_instance.position = start_position + horizontal_offset + Vector3(0, i * cap_height, 0)
# 		cap_instance.add_to_group("caps")
# 		caps_container.add_child(cap_instance)

# 		await get_tree().process_frame

# 		# Импульс подброса
# 		var impulse = Vector3(
# 			rng.randf_range(-1.5, 1.5),
# 			rng.randf_range(6.0, 9.0),
# 			rng.randf_range(-1.5, 1.5)
# 		)
# 		cap_instance.apply_impulse(Vector3.ZERO, impulse)

# 		# Вращательный импульс (torque)
# 		var torque = Vector3(
# 			rng.randf_range(-5.0, 5.0),  # вокруг X
# 			rng.randf_range(-10.0, 10.0), # вокруг Y
# 			rng.randf_range(-5.0, 5.0)   # вокруг Z
# 		)
# 		cap_instance.apply_torque_impulse(torque)

# 		await wait_until_caps_stop()
# 		count_fallen()
