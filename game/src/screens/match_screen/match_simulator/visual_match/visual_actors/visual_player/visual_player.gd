# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualPlayer
extends VisualActor

var player_info: String
var head_look: Vector2
var ball: VisualBall

@onready var sprites: Node2D = %Sprites
@onready var name_label: Label = %NameLabel

@onready var body: Sprite2D = %Body
@onready var arm_right: Sprite2D = %ArmLeft
@onready var arm_left: Sprite2D = %ArmRight
@onready var leg_right: Sprite2D = %LegLeft
@onready var leg_left: Sprite2D = %LegRight

@onready var head: Sprite2D = %Head
@onready var hair: Sprite2D = %Hair
@onready var eyes: Sprite2D = %Eyes

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	name_label.text = player_info

	# walking speed
	var speed: float = last_pos.distance_squared_to(pos)
	speed /= 10
	animation_player.speed_scale = speed

	if not Global.match_paused:
		if last_pos != pos:
			animation_player.play("run")
			if head_look != Vector2.ZERO:
				sprites.look_at(head_look)
			else:
				# look towards walking direction
				sprites.look_at(pos + (last_pos.direction_to(pos) * 2))
		else:
			# not walking
			animation_player.stop()
			sprites.look_at(ball.position)
	else:
		animation_player.pause()


# draw simple circle
# func _draw() -> void:
# 	draw_circle(Vector2.ZERO, 18, body.modulate)


func setup(
	p_pos: Vector2,
	p_player_info: String = "",
	skintone: String = "000000",
	haircolor: String = "000000",
	eyecolor: String = "000000",
	shirt_color: String = "000000",
	p_ball: VisualBall = null,
) -> void:
	super(p_pos)
	player_info = p_player_info
	ball = p_ball

	# set colors
	body.modulate = Color(shirt_color, 1.0)
	# arms could have secondary color
	# arm_right.modulate = Color(shirt_color, 1.0)
	# arm_left.modulate = Color(shirt_color, 1.0)
	head.modulate = Color(skintone, 1.0)
	leg_right.modulate = Color(skintone, 1.0)
	leg_left.modulate = Color(skintone, 1.0)
	hair.modulate = Color(haircolor, 1.0)
	eyes.modulate = Color(eyecolor, 1.0)


func update(
	p_pos: Vector2,
	p_head_look: Vector2 = Vector2.ZERO,
	p_player_info: String = "",
	skintone: String = "000000",
	haircolor: String = "000000",
	eyecolor: String = "000000",
) -> void:
	super(p_pos)
	head_look = p_head_look

	player_info = p_player_info

	# set colors
	head.modulate = Color(skintone)
	hair.modulate = Color(haircolor)
	eyes.modulate = Color(eyecolor)

