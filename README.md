# Arkanoid Example (Godot 4)

A minimal, fully playable **Arkanoid / Breakout** example project for **Godot 4.x**
(GL Compatibility renderer). No external assets required — everything is drawn with
`ColorRect` nodes and GDScript.

## How to run

1. Install [Godot 4.2+](https://godotengine.org/download) (standard edition).
2. Open Godot → **Import** → select this folder's `project.godot` → **Import & Edit**.
3. Press **F5** (or the Play button). `scenes/main.tscn` is the main scene.

## Controls

| Action        | Keys                          |
|---------------|-------------------------------|
| Move paddle   | ← / → or A / D (mouse also works) |
| Launch ball   | Space or left mouse click     |
| Restart (after game over) | R                 |

## Gameplay features

- Ball sticks to the paddle and launches on demand; bounce angle depends on where
  the ball hits the paddle (classic Arkanoid feel).
- Bricks arranged in a 10×6 grid; top rows are worth more points and are colored differently.
- Ball speeds up slightly on every brick hit; speed increases each level.
- Clear all bricks to advance to the next level (ball gets faster).
- 3 lives; lose one when the ball falls below the paddle. Game-over screen with restart.
- HUD showing score, level, and lives.

## Project structure

```
project.godot          # Project config: main scene, input map, display settings
scenes/
  main.tscn            # Game scene: walls, paddle, ball, UI, brick container
  paddle.tscn          # CharacterBody2D paddle (group "paddle")
  ball.tscn            # CharacterBody2D ball with VisibleOnScreenNotifier2D
  brick.tscn           # StaticBody2D brick (group "brick"), reusable
scripts/
  main.gd              # Game loop: builds brick wall, score/lives/levels, UI
  paddle.gd            # Keyboard + mouse paddle movement
  ball.gd              # Physics, bouncing, launch logic, signals (lost, brick_hit)
  brick.gd             # Point value + row coloring
```

## Implementation notes

- The ball uses `CharacterBody2D.move_and_collide()` with manual velocity reflection
  (`velocity.bounce(collision.normal)`), which gives precise control over bounces.
- Collisions are distinguished via node groups (`"brick"`, `"paddle"`) instead of
  collision layers, keeping the example simple.
- A `VisibleOnScreenNotifier2D` placed below the paddle detects when the ball leaves
  the field and emits the `lost` signal.
- Input actions (`move_left`, `move_right`, `launch_ball`) are defined in
  `project.godot` so you can rebind them in *Project Settings → Input Map*.

## Ideas to extend

- Multiple ball speeds / power-ups (wider paddle, multiball, laser).
- Indestructible bricks, moving bricks, or levels loaded from data files.
- Sound effects and particles using `AudioStreamPlayer` and `GPUParticles2D`.
- High-score persistence with `FileAccess` / `user://` storage.
