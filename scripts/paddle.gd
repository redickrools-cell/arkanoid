extends CharacterBody2D
## Paddle: moves left/right with arrow keys or A/D (and follows the mouse).

@export var move_speed := 500.0
@export var half_width := 64.0   # used by the ball to compute bounce angle

var _use_mouse := false


func _unhandled_input(event: InputEvent) -> void:
	# Switch to mouse control as soon as the player moves the mouse.
	if event is InputEventMouseMotion:
		_use_mouse = true


func _physics_process(delta: float) -> void:
	if _use_mouse:
		var target_x := get_global_mouse_position().x
		var diff := target_x - global_position.x
		velocity.x = clampf(diff / max(delta, 0.0001), -move_speed * 2.0, move_speed * 2.0)
	else:
		var dir := Input.get_axis("move_left", "move_right")
		velocity.x = dir * move_speed

	move_and_slide()

	# Keep the paddle inside the playfield walls.
	global_position.x = clampf(global_position.x, half_width + 16.0, 800.0 - half_width - 16.0)
