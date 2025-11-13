extends StateMachine
class_name TurnSM

signal turn_finished        # эмитится из ResolveState, когда ход завершён

var controller: BaseController = null

@export var arrow_path: NodePath            # UI/Arrow (Node3D или Control/Node2D)
@export var power_path: NodePath            # UI/PowerBar (Control)
@export var physics_watcher_path: NodePath  # узел с методами start_watch()/all_caps_stopped()

@onready var _aim_power: AimPower = $Aim

@onready var ui_arrow: Node = (
	get_node_or_null(arrow_path) if arrow_path != NodePath("")
	else get_node_or_null("../UI/Arrow")
)

@onready var ui_power: Node = (
	get_node_or_null(power_path) if power_path != NodePath("")
	else get_node_or_null("../UI/PowerBar")
)

@onready var physics_watcher: PhysicsWatcher = (
	(get_node_or_null(physics_watcher_path) as PhysicsWatcher) if physics_watcher_path != NodePath("")
	else (get_node_or_null("../PhysicsWatcher") as PhysicsWatcher)
)

# -------------------- ПУБЛИЧНЫЙ API --------------------

## Назначить контроллер (вызывается из PlayerTurn/NpcTurn)
func set_controller(c: BaseController) -> void:
	controller = c

## Показать/спрятать стрелку
func show_arrow(v: bool) -> void:
	if ui_arrow == null: return
	# у Node3D и CanvasItem есть свойство visible
	if ui_arrow.has_method("set_visible"):
		ui_arrow.set_visible(v)
	elif "visible" in ui_arrow.get_property_list():
		ui_arrow.visible = v

func show_power(v: bool) -> void:
	if ui_power == null: return
	if ui_power.has_method("set_visible"):
		ui_power.set_visible(v)
	elif "visible" in ui_power.get_property_list():
		ui_power.visible = v

func start_watch() -> void:
	if physics_watcher:
		physics_watcher.start_watch()

func all_caps_stopped() -> bool:
	if physics_watcher:
		return physics_watcher.all_caps_stopped()
	return false

func force_finish_turn() -> void:
	emit_signal("turn_finished")


func _ready() -> void:
	add_to_group("turn_sm")
	super._ready()
	_connect_state_signals()

func _connect_state_signals() -> void:
	_aim_power.charge_started.connect(_on_charge_started)
	_aim_power.charge_changed.connect(_on_charge_changed)
	_aim_power.charge_released.connect(_on_charge_released)
	_aim_power.charge_canceled.connect(_on_charge_canceled)

# сигналы от AimPower
func _on_charge_started() -> void:
	print("начали заряд")
	# например: UI/PowerBar.show()

func _on_charge_changed(power: float) -> void:
	print("заряд:", power)
	# UI/PowerBar.set_value(power)

func _on_charge_released(power: float) -> void:
	print("заряд отпущен:", power)
	# здесь можешь сразу вызвать transition_to("Shoot"), если хочешь делать переход извне

func _on_charge_canceled() -> void:
	print("заряд отменён")
	# UI/PowerBar.hide()

# -------------------- Утилиты для стрелки (необязательно) --------------------

## Унифицированный способ обновить визуал стрелки из состояний
## dir — нормализованный, power ∈ [0..1] (можно не передавать)
func update_arrow(start: Vector3, dir: Vector3, power: float = 1.0) -> void:
	if ui_arrow == null: return

	if ui_arrow.has_method("set_from"):
		ui_arrow.set_from(start, dir, power)
		return
	if ui_arrow.has_method("update_from"):
		ui_arrow.update_from(start, dir, power)
		return

	# fallback для Node3D: поставить в точку и повернуть по направлению
	if ui_arrow is Node3D:
		var n3d := ui_arrow as Node3D
		n3d.global_position = start
		n3d.look_at(start + dir, Vector3.UP)
		# Если у модели длина по Z и хочешь масштаб от силы — раскомментируй:
		# n3d.scale = Vector3(n3d.scale.x, n3d.scale.y, lerp(0.5, 2.5, clamp(power, 0.0, 1.0)))
