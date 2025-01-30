# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualBall
extends VisualActor

# rotation keyword already taken by Node2D
var rot: float


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not Global.match_paused:
		rotate(rot)


func setup(p_pos: Vector2) -> void:
	super(p_pos)
	update_interval = 1.0 / Const.TICKS_PER_SECOND


func update(p_pos: Vector2, p_rot: float = 0.0) -> void:
	super(p_pos)
	rot = p_rot
