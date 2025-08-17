extends StateMachine
class_name TurnSM

signal turn_finished        # эмитится из ResolveState, когда ход завершён

## Контроллер текущего хода (PlayerController или NpcController)
var controller: Node = null

@export var arrow_path: NodePath            # UI/Arrow (Node3D или Control/Node2D)
@export var power_path: NodePath            # UI/PowerBar (Control)
@export var physics_watcher_path: NodePath  # узел с методами start_watch()/all_caps_stopped()

@onready var ui_arrow: Node = (
	get_node_or_null(arrow_path) if arrow_path != NodePath("")
	else get_node_or_null("../UI/Arrow")
)

@onready var ui_power: Node = (
	get_node_or_null(power_path) if power_path != NodePath("")
	else get_node_or_null("../UI/PowerBar")
)

@onready var physics_watcher: Node = (
	get_node_or_null(physics_watcher_path) if physics_watcher_path != NodePath("")
	else get_node_or_null("../PhysicsWatcher")
)

func _ready() -> void:
	add_to_group("turn_sm")     # для удобного поиска из PlayerTurn/NpcTurn
	super._ready()

# -------------------- ПУБЛИЧНЫЙ API --------------------

## Назначить контроллер (вызывается из PlayerTurn/NpcTurn)
func set_controller(c: Node) -> void:
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
	if physics_watcher and physics_watcher.has_method("start_watch"):
		physics_watcher.start_watch()

func all_caps_stopped() -> bool:
	return physics_watcher and physics_watcher.has_method("all_caps_stopped") \
		and physics_watcher.all_caps_stopped()

func force_finish_turn() -> void:
	emit_signal("turn_finished")

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
