# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualPlayer
extends VisualActor

var player_info: String
var head_look: Vector2

@onready var sprites: Node2D = $Sprites
@onready var name_label: Label = $Info/NameLabel

@onready var body: Sprite2D = $Sprites/Body
@onready var head: Sprite2D = $Sprites/Head
@onready var hair: Sprite2D = $Sprites/Hair
@onready var eyes: Sprite2D = $Sprites/Eyes


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not Global.match_paused:
		sprites.look_at(head_look)

	name_label.text = player_info
	print(factor)


func setup(
	p_pos: Vector2,
	p_player_info: String = "",
	shirt_color: Color = Color.TRANSPARENT,
) -> void:
	super(p_pos)
	update_interval = 1.0 / Const.STATE_UPDATE_TICKS

	player_info = p_player_info
	body.modulate = shirt_color

	# set colors
	# head.modulate = sim_player.player_res.skintone
	# hair.modulate = sim_player.player_res.haircolor
	# eyes.modulate = sim_player.player_res.eyecolor


func update(p_pos: Vector2, p_player_info: String = "", p_head_look: Vector2 = Vector2.ZERO) -> void:
	super(p_pos)
	player_info = p_player_info
	head_look = p_head_look
