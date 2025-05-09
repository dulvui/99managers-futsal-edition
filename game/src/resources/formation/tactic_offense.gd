# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TacticOffense
extends JSONResource

enum Tactics {
	ROTATION,
	CUT_INSIDE,
}

@export var tactic: Tactics
# between 0.0 - 1.0
@export var intensity: float

func _init(
	p_tactic: Tactics = Tactics.ROTATION,
	p_intensity: float = 1.0,
) -> void:
	tactic = p_tactic
	intensity = p_intensity
