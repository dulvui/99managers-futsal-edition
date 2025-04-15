# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualPlayer
extends VisualActor

var player_info: String
var head_look: Vector2
var ball: VisualBall

@onready var sprites: Node2D = $Sprites
@onready var name_label: Label = $Info/NameLabel

@onready var body: Sprite2D = $Sprites/Body
@onready var head: Sprite2D = $Sprites/Head
@onready var hair: Sprite2D = $Sprites/Hair
@onready var eyes: Sprite2D = $Sprites/Eyes


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not Global.match_paused:
		if head_look == Vector2.ZERO:
			sprites.look_at(ball.position)
		else:
			sprites.look_at(head_look)

	name_label.text = player_info


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
	body.modulate = Color(shirt_color)
	head.modulate = Color(skintone)
	hair.modulate = Color(haircolor)
	eyes.modulate = Color(eyecolor)


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

