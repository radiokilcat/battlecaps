extends Node2D  # Или CharacterBody2D, если нужен физический контроль

@export var speed := 200.0  # пикселей в секунду

func _process(delta):
	var input := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	position.x += input * speed * delta
	
