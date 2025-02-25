# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateEnterField
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateEnterField")


func enter() -> void:
	# start from center bottom
	var start_position: Vector2 = owner.field.center
	# move down
	start_position.y += owner.field.size.y / 2 + 50
	start_position.y += (owner.team.players.find(owner.player) + 1) * 20

	# move left/right
	if owner.team.left_half:
		start_position.x -= 30
	else:
		start_position.x += 30

	# move to center, but slightly shifted
	var destination: Vector2 = owner.field.center
	if owner.team.left_half:
		destination.x -= (owner.team.players.find(owner.player) + 1) * 30
	else:
		destination.x += (owner.team.players.find(owner.player) + 1) * 30

	# add some noise
	start_position.x += owner.rng.randi_range(-5, 5)
	start_position.y += owner.rng.randi_range(-5, 5)
	destination.x += owner.rng.randi_range(-5, 5)
	destination.y += owner.rng.randi_range(-5, 5)

	owner.player.set_pos(start_position)
	owner.player.set_destination(destination)
	owner.player.look_towards_destination()


func execute() -> void:
	if not owner.player.destination_reached():
		return

	# look towards bottom
	owner.player.head_look += Vector2(0, 100)
