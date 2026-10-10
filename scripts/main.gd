extends Node2D
## Main game controller: spawns the brick wall, tracks score / lives / level,
## and shows win / lose overlays.

const BRICK_SCENE := preload("res://scenes/brick.tscn")

const GRID_COLS := 10
const GRID_ROWS := 6
const BRICK_SIZE := Vector2(70, 26)
const BRICK_GAP := 6.0
const WALL_THICKNESS := 16.0
const FIELD_WIDTH := 800.0
const FIELD_HEIGHT := 600.0

@export var starting_lives := 3

var score := 0:
	set(value):
		score = value
		if _score_label:
			_score_label.text = "Score: %d" % score
var lives := 3:
	set(value):
		lives = value
		if _lives_label:
			_lives_label.text = "Lives: %d" % lives
var level := 1:
	set(value):
		level = value
		if _level_label:
			_level_label.text = "Level: %d" % level

@onready var _paddle: CharacterBody2D = $Paddle
@onready var _ball: CharacterBody2D = $Ball
@onready var _bricks: Node2D = $Bricks
@onready var _score_label: Label = $UI/ScoreLabel
@onready var _lives_label: Label = $UI/LivesLabel
@onready var _level_label: Label = $UI/LevelLabel
@onready var _message: Label = $UI/Message
@onready var _hint: Label = $UI/Hint


func _ready() -> void:
	randomize()
	lives = starting_lives
	level = 1
	score = 0
	_build_bricks()
	_ball.set_paddle(_paddle)
	_ball.lost.connect(_on_ball_lost)
	_ball.brick_hit.connect(_on_brick_hit)
	_update_hint(true)


func _build_bricks() -> void:
	for child in _bricks.get_children():
		child.queue_free()

	var total_w := GRID_COLS * (BRICK_SIZE.x + BRICK_GAP) - BRICK_GAP
	var start_x := (FIELD_WIDTH - total_w) / 2.0
	var start_y := 90.0
	for row in GRID_ROWS:
		# Top rows are worth more points.
		var pts := (GRID_ROWS - row) * 10
		for col in GRID_COLS:
			var brick := BRICK_SCENE.instantiate()
			brick.hit_points = pts
			brick.position = Vector2(
				start_x + col * (BRICK_SIZE.x + BRICK_GAP) + BRICK_SIZE.x / 2.0,
				start_y + row * (BRICK_SIZE.y + BRICK_GAP) + BRICK_SIZE.y / 2.0
			)
			_bricks.add_child(brick)


func _on_brick_hit(points: int) -> void:
	score += points
	# Level complete when no bricks remain (they are queue_free'd, count live ones).
	await get_tree().process_frame
	if _bricks.get_child_count() <= 1:
		_next_level()


func _next_level() -> void:
	level += 1
	_ball.speed = min(_ball.speed + 40.0, _ball.MAX_SPEED)
	_ball.stick_to_paddle()
	_build_bricks()
	_message.text = "Level %d!" % level
	_show_message_temporarily()
	_update_hint(true)


func _on_ball_lost() -> void:
	lives -= 1
	if lives <= 0:
		_game_over()
	else:
		_ball.stick_to_paddle()
		_update_hint(true)


func _game_over() -> void:
	_ball.velocity = Vector2.ZERO
	_ball.stuck = true
	_message.text = "GAME OVER\nFinal score: %d\nPress R to restart" % score
	_message.visible = true
	_hint.visible = false


func _update_hint(visible_now: bool) -> void:
	_hint.visible = visible_now


func _show_message_temporarily() -> void:
	_message.visible = true
	await get_tree().create_timer(1.5).timeout
	_message.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if lives <= 0 and event is InputEventKey and event.pressed \
			and event.physical_keycode == KEY_R:
		get_tree().reload_current_scene()
