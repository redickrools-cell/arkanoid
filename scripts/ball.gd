extends CharacterBody2D
## Ball: moves with a velocity, bounces off walls, bricks and the paddle.
## Sticks to the paddle until launched (Space / left mouse click).

signal lost
signal brick_hit(points: int)

const LAUNCH_SPEED := 350.0
const MAX_SPEED := 600.0
const SPEED_UP_PER_BOUNCE := 1.03

@export var speed := LAUNCH_SPEED

var velocity := Vector2.ZERO
var stuck := true          # ball sits on the paddle before launch
var launched := false      # prevents double-launch handling
var _paddle: Node2D = null

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Keep the ball's motion perfectly smooth regardless of frame rate.
	set_physics_process(true)


func set_paddle(paddle: Node2D) -> void:
	_paddle = paddle
	stick_to_paddle()


func stick_to_paddle() -> void:
	stuck = true
	launched = false
	velocity = Vector2.ZERO
	if _paddle:
		global_position = _paddle.global_position + Vector2(0, -22)


func launch() -> void:
	if not stuck:
		return
	stuck = false
	launched = true
	# Launch upward with a slight random horizontal component.
	var dir := Vector2(randf_range(-0.4, 0.4), -1.0).normalized()
	velocity = dir * speed


func _physics_process(delta: float) -> void:
	if stuck:
		if _paddle:
			global_position = _paddle.global_position + Vector2(0, -22)
		if Input.is_action_just_pressed("launch_ball"):
			launch()
		return

	# Move manually so we can reflect precisely at contact points.
	var collision := move_and_collide(velocity * delta)
	if collision:
		_handle_collision(collision)
		# Slide along the surface for the remainder of this frame's motion.
		var remaining := velocity * delta
		remaining = remaining.slide(collision.normal)
		move_and_collide(remaining)


func _handle_collision(collision: KinematicCollision2D) -> void:
	var collider := collision.collider as Node

	# Wall / ceiling bounce.
	if collider is StaticBody2D and not collider.is_in_group("brick"):
		velocity = velocity.bounce(collision.normal)
		return

	# Brick hit: bounce, score, destroy the brick.
	if collider.is_in_group("brick"):
		velocity = velocity.bounce(collision.normal)
		speed = min(speed * SPEED_UP_PER_BOUNCE, MAX_SPEED)
		velocity = velocity.normalized() * speed
		var pts: int = collider.hit_points if "hit_points" in collider else 10
		emit_signal("brick_hit", pts)
		collider.queue_free()
		return

	# Paddle bounce: influence direction by where the ball hits the paddle.
	if collider.is_in_group("paddle"):
		var paddle_half: float = collider.collision_half_width if "collision_half_width" in collider else 60.0
		var offset := clampf((global_position.x - collider.global_position.x) / paddle_half, -1.0, 1.0)
		# Map offset to an angle between roughly -60 and +60 degrees from vertical.
		var angle := deg_to_rad(offset * 60.0)
		velocity = Vector2(sin(angle), -cos(angle)) * speed
		# Nudge the ball above the paddle to avoid re-collision jitter.
		global_position += Vector2(0, -2)
		return


func _on_visible_screen_exited() -> void:
	# Ball fell below the level -> life lost.
	emit_signal("lost")
