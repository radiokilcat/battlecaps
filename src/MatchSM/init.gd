extends StateBase

@onready var cap_scene = preload("res://scenes/cap.tscn")

@export var player_id: String = "Player"
@export var npc_id: String    = "NPC"

@export var clear_board_on_start: bool = true
@export var reset_active_cap_pose: bool = true
@export var caps_container: Node
@export var caps_stack_size: int = 3
@export var spacing: Vector2 = Vector2(0.6, 0.6)  # шаг XZ между капсами
@export var base_y: float = 0.5           # высота центра капсы
@export var stack_origin: Vector3 = Vector3(0, 0, 3) # центр стопки (вперёд от битки)

@onready var score: Node             = $"../../ScoreManager"
@onready var turn_sm: Node           = $"../../TurnSM"
@onready var player_controller: Node = $"../../PlayerController"
@onready var npc_controller: Node    = $"../../NpcController"
@onready var active_cap: Node        = $"../../PlayerSlamCap"

func stack_caps():
	var cap_count = caps_stack_size
	var cap_height = 0.3
	var start_position = Vector3(0, 1, 0)

	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for child in caps_container.get_children():
		child.queue_free()

	for i in range(cap_count):
		var cap_instance = cap_scene.instantiate()

		var horizontal_offset = Vector3(
			rng.randf_range(-0.05, 0.05),
			0,
			rng.randf_range(-0.05, 0.05)
		)

		var vertical_offset = Vector3(0, i * cap_height, 0)
		cap_instance.position = start_position + vertical_offset + horizontal_offset

		cap_instance.rotation_degrees.y = rng.randf_range(-10, 10)
		caps_container.add_child(cap_instance)

func _reset_active_cap() -> void:
	if not active_cap or not (active_cap is RigidBody3D):
		return
	active_cap.linear_velocity  = Vector3.ZERO
	active_cap.angular_velocity = Vector3.ZERO
	active_cap.sleeping = false
	active_cap.global_transform = Transform3D(Basis(), Vector3(0, 0.5, -3))


func _enter(_data := {}) -> void:
	if turn_sm:
		turn_sm.set_process(false)
		turn_sm.set_process_input(false)

	# Подготовка поля
	stack_caps() if clear_board_on_start else null

	# Сброс позиции битки
	_reset_active_cap() if reset_active_cap_pose and active_cap else null

	# Старт матча
	score.start_match([player_id, npc_id]) if score and score.has_method("start_match") else push_warning(
		"InitState: ScoreManager не найден или без метода start_match()."
	)

	# Привязка битки к контроллерам
	player_controller.active_cap = active_cap if player_controller and "active_cap" in player_controller else null
	npc_controller.active_cap    = active_cap if npc_controller and "active_cap" in npc_controller else null

	# Переход к первому ходу
	emit_signal("request_transition", "PlayerTurn")


func _exit() -> void:
	pass
