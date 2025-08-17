# PlayerTurnState.gd
extends StateBase

# --- Параметры (проставь в инспекторе для надёжности) ---
@export var turn_sm_path: NodePath
@export var player_controller_path: NodePath
@export var score_manager_path: NodePath
@export var player_id: String = "Player"

# --- Кэш-ссылки (заполняются в _ready) ---
var turn_sm: TurnSM
var player_controller: Node
var score: ScoreManager

# Чтобы не ловить повторные коннекты, храним флаг
var _connected_once := false

func _ready() -> void:
	turn_sm = get_node_or_null(turn_sm_path) as TurnSM
	player_controller = get_node_or_null(player_controller_path)
	score = get_node_or_null(score_manager_path) as ScoreManager

	turn_sm = (turn_sm if turn_sm else ($"../../TurnSM" as TurnSM))
	turn_sm = (turn_sm if turn_sm else (get_tree().get_first_node_in_group("turn_sm") as TurnSM))

	player_controller = player_controller if player_controller else $"../../PlayerController"
	score = (score if score else ($"../../ScoreManager" as ScoreManager))

	# print("PlayerTurnState: turn_sm=", turn_sm, " controller=", player_controller, " score=", score)

func _enter(_data := {}) -> void:
	if score == null:
		push_error("PlayerTurnState: ScoreManager not found or script not attached.")
		return
	if turn_sm == null:
		push_error("PlayerTurnState: TurnSM not found. Set turn_sm_path or add TurnSM to group 'turn_sm'.")
		return
	if player_controller == null:
		push_error("PlayerTurnState: PlayerController not found.")
		return

	score.begin_turn(player_id)

	turn_sm.set_process(true)
	turn_sm.set_process_input(true)
	turn_sm.set_controller(player_controller)
	turn_sm.transition_to(turn_sm.start_state)

	if not _connected_once and turn_sm.has_signal("turn_finished"):
		turn_sm.turn_finished.connect(_on_turn_finished, CONNECT_ONE_SHOT)
		_connected_once = true

	# Опционально: включим визуальные подсказки
	#if turn_sm.ui_arrow: turn_sm.ui_arrow.visible = true
	#if turn_sm.ui_power: turn_sm.ui_power.visible = true

func _exit() -> void:
	# Выключать TurnSM здесь не обязательно (NPCTurn сделает своё),
	# но можно «погасить» UI, чтобы не мигало между ходами.
	# if turn_sm:
		# if turn_sm.ui_power: turn_sm.ui_power.visible = false
		# Стрелку можно оставить до Shoot, но если хочешь — спрячь:
		# if turn_sm.ui_arrow: turn_sm.ui_arrow.visible = false
	_connected_once = false  # готовим флаг для следующего входа

func _on_turn_finished() -> void:
	# Ход игрока окончен — передаём управление NPC
	emit_signal("request_transition", "NpcTurn")
