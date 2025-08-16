extends Node
class_name ScoreManager

signal score_changed(scores: Dictionary)
signal game_over(winner_id: String)
signal round_changed(current_round: int)

## ====== Настройки матча ======
@export var target_score: int = 10
@export var max_rounds: int = 0
@export var points_per_knockout: int = 1

## ====== Состав игроков (без строгого Array[String]) ======
@export var players: Array = ["Player", "NPC"]  # нормализуем внутри

## ====== Текущее состояние ======
var scores: Dictionary = {}             # ключи: StringName → int
var current_player: StringName = &""    # чей ход
var current_round: int = 1
var turn_count: int = 0

## Накопители текущего хода
var _pending_knockouts: int = 0
var _pending_caps: Array = []           # Array[Node], оставим гибким

func _ready() -> void:
	_normalize_players()
	_reset_scores()

## --- Публичный API ---

func start_match(new_players: Array = []) -> void:
	if new_players.size() > 0:
		players = new_players.duplicate()
		_normalize_players()
	_reset_scores()
	current_round = 1
	turn_count = 0
	current_player = &""
	_emit_score_changed()

func begin_turn(player_id) -> void:
	current_player = _sn(player_id)
	_pending_knockouts = 0
	_pending_caps.clear()

func register_knockout(cap: Node) -> void:
	_pending_knockouts += 1
	_pending_caps.append(cap)

func update_after_turn() -> bool:
	if current_player == &"":
		push_warning("ScoreManager.update_after_turn(): current_player не установлен. Вызовите begin_turn().")
		return false

	# 1) Начисление очков
	var gained := _pending_knockouts * points_per_knockout
	scores[current_player] = int(scores.get(current_player, 0)) + gained

	# 2) Сброс накопителей
	_pending_knockouts = 0
	_pending_caps.clear()

	# 3) Ходы/раунды
	turn_count += 1
	if players.size() > 0 and players.find(current_player) == players.size() - 1:
		current_round += 1
		round_changed.emit(current_round)

	_emit_score_changed()

	# 4) Проверка победителя
	if is_game_over():
		game_over.emit(winner_id())
		return true
	return false

func is_game_over() -> bool:
	if target_score > 0:
		for p in players:
			if int(scores.get(p, 0)) >= target_score:
				return true
	if max_rounds > 0 and current_round > max_rounds:
		return true
	return false

func winner_id() -> String:
	if target_score > 0:
		for p in players:
			if int(scores.get(p, 0)) >= target_score:
				return String(p)
	if max_rounds > 0 and current_round > max_rounds:
		var best_p: StringName = &""
		var best_score := -INF
		var tie := false
		for p in players:
			var s: int = int(scores.get(p, 0))
			if s > best_score:
				best_score = s
				best_p = p
				tie = false
			elif s == best_score:
				tie = true
		return "" if tie else String(best_p)
	return ""

## Удобные геттеры
func get_score(player_id) -> int:
	return int(scores.get(_sn(player_id), 0))

func get_scores() -> Dictionary:
	# возвращаем копию (ключи останутся StringName — это ок)
	return scores.duplicate(true)

func get_round() -> int:
	return current_round

## --- Вспомогательное ---

func _reset_scores() -> void:
	scores.clear()
	for p in players:
		scores[p] = 0

func _emit_score_changed() -> void:
	score_changed.emit(scores.duplicate(true))

func _normalize_players() -> void:
	var norm: Array = []
	for p in players:
		norm.append(_sn(p))
	players = norm

func _sn(x) -> StringName:
	return x if x is StringName else StringName(str(x))
