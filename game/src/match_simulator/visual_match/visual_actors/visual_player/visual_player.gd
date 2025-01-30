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
	shirt_color: Color = Color.TRANSPARENT,
	p_ball: VisualBall = null,	
) -> void:
	super(p_pos)
	update_interval = 1.0 / (float(Const.TICKS) / float(Const.TICKS_LOGIC))
	player_info = p_player_info
	body.modulate = shirt_color
	ball = p_ball

	# set colors
	# head.modulate = sim_player.player_res.skintone
	# hair.modulate = sim_player.player_res.haircolor
	# eyes.modulate = sim_player.player_res.eyecolor


func update(p_pos: Vector2, p_player_info: String = "", p_head_look: Vector2 = Vector2.ZERO) -> void:
	super(p_pos)
	player_info = p_player_info
	head_look = p_head_look
