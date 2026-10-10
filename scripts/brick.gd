extends StaticBody2D
## Brick: destroyed on the first ball hit; awards points.
## Higher rows are worth more points and tinted differently.

@export var hit_points := 10

const COLORS := [
	Color(0.95, 0.35, 0.35),  # red
	Color(0.95, 0.6, 0.25),   # orange
	Color(0.95, 0.85, 0.3),   # yellow
	Color(0.5, 0.9, 0.4),     # green
	Color(0.4, 0.7, 0.95),    # blue
	Color(0.75, 0.5, 0.95),   # purple
]


func _ready() -> void:
	add_to_group("brick")
	# Top rows (higher points) get cooler colors; index by point value.
	var idx := clampi(int(hit_points / 10.0) - 1, 0, COLORS.size() - 1)
	$ColorRect.color = COLORS[idx]
