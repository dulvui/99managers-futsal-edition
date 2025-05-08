# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimBall
extends MovingActor

# left -1, right 1, no roatation 0
var rotation: float

var field: SimField


func _init() -> void:
	super(2, 0.05)


func setup(p_field: SimField) -> void:
	field = p_field
	pos = field.center
	rotation = 0


func update() -> void:
	move()

	# rotation
	if is_moving():
		if abs(rotation) > 0.1:
			if rotation > 0.1:
				rotation -= 0.05
			elif rotation < 0.1:
				rotation += 0.05
			else:
				rotation = 0
	else:
		rotation = 0


func impulse(p_direction: Vector2, p_force: float) -> void:
	super(p_direction, p_force)
	# print("pass")
	_random_rotation()


# check collision with actor, by comparing colission radius distances
# delta_squared can be used to reduce/increase colission radius
# makes check if player touches ball easier
func collides_with_player(player: SimPlayer) -> bool:
	if player == null:
		return false

	# check if player has collision disabled
	if player.collision_timer > 0:
		return false

	# if can't collide, if ball is moving and player is behind ball
	# dot product of direction and directon from actor to self
	if is_moving() and direction.dot(player.pos.direction_to(pos)) > 0.0:
		return false
	
	if collides(player):
		print("ball collides with player %d" % player.player_res.nr)
		stop()
		return true

	return false


func _random_rotation() -> void:
	rotation = randf_range(-0.8, 0.8)

