extends RichTextLabel

@export var score_manager: Node  # перетащи сюда ScoreManager из сцены

func _ready():
	if score_manager:
		if score_manager.has_signal("score_changed"):
			score_manager.score_changed.connect(_on_score_changed)
		if score_manager.has_signal("round_changed"):
			score_manager.round_changed.connect(_on_round_changed)
		if score_manager.has_signal("game_over"):
			score_manager.game_over.connect(_on_game_over)
	_refresh()

func _on_score_changed(_scores: Dictionary) -> void:
	_refresh()

func _on_round_changed(_round: int) -> void:
	_refresh()

func _on_game_over(winner_id: String) -> void:
	# можно подсветить или показать финальный текст
	text = "%s\nWinner: %s" % [text, ("Tie" if winner_id == "" else winner_id)]

func _refresh() -> void:
	if not score_manager: return
	var round_num: int = score_manager.get_round()
	var scores: Dictionary = score_manager.get_scores()
	var players: Array = score_manager.players if "players" in score_manager else scores.keys()

	# ищем максимум
	var best := -INF
	for p in players:
		best = max(best, int(scores.get(p, 0)))

	var parts: Array[String] = []
	for p in players:
		var s := int(scores.get(p, 0))
		var name := "%s" % p if s == best else str(p)
		parts.append("%s: %d" % [name, s])

	text = "Round %d — %s" % [round_num, " | ".join(parts)]
