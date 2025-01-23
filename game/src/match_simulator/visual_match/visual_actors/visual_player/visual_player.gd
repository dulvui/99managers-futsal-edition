# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualPlayer
extends VisualActor

var sim_player: SimPlayer
var ball: VisualBall

# real player
@onready var body: Sprite2D = $Sprites/Body
@onready var head: Sprite2D = $Sprites/Head
@onready var hair: Sprite2D = $Sprites/Hair
@onready var eyes: Sprite2D = $Sprites/Eyes

@onready var sprites: Node2D = $Sprites
@onready var name_label: Label = $Info/NameLabel


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not Global.match_paused:
		if sim_player.head_look == Vector2.ZERO:
			sprites.look_at(ball.position)
		else:
			sprites.look_at(sim_player.head_look)


func setup(
	p_sim_player: MovingActor,
	p_update_interval: float,
	p_ball: VisualBall = null,
	shirt_color: Color = Color.TRANSPARENT,
) -> void:
	super(p_sim_player, p_update_interval)
	sim_player = p_sim_player as SimPlayer
	ball = p_ball

	body.modulate = shirt_color
	
	name_label.text = str(sim_player.player_res.nr) + " " + (sim_player.player_res.surname)

	# set colors
	head.modulate = sim_player.player_res.skintone
	hair.modulate = sim_player.player_res.haircolor
	eyes.modulate = sim_player.player_res.eyecolor


func change_player(p_sim_player: SimPlayer) -> void:
	sim_player = p_sim_player
	name_label.text = str(sim_player.player_res.nr) + " " + (sim_player.player_res.surname)


