extends StateBase

@export var player_id: String = "Player"
@export var npc_id: String    = "NPC"

@export var clear_board_on_start: bool = true
@export var reset_active_cap_pose: bool = true

@onready var score: Node             = $"../../ScoreManager"
@onready var turn_sm: Node           = $"../../TurnSM"
@onready var player_controller: Node = $"../../PlayerController"
@onready var npc_controller: Node    = $"../../NpcController"
@onready var active_cap: Node        = $"../../BitCap"

func _enter(_data := {}) -> void:
	# Выключаем TurnSM на время подготовки
	if turn_sm:
		turn_sm.set_process(false)
		turn_sm.set_process_input(false)

	# Подготовка поля
	_setup_board() if clear_board_on_start else null

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


func _setup_board() -> void:
	for cap in get_tree().get_nodes_in_group("caps"):
		cap.linear_velocity  = Vector3.ZERO if cap.has_method("set_linear_velocity") else cap.linear_velocity
		cap.angular_velocity = Vector3.ZERO if cap.has_method("set_angular_velocity") else cap.angular_velocity
		# при желании: cap.global_position = ... (твои стартовые координаты)

func _reset_active_cap() -> void:
	if not active_cap or not (active_cap is RigidBody3D):
		return
	active_cap.linear_velocity  = Vector3.ZERO
	active_cap.angular_velocity = Vector3.ZERO
	active_cap.sleeping = false
	active_cap.global_transform = Transform3D(Basis(), Vector3(0, 0.5, -3))
