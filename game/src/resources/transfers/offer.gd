# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Offer

enum Timing {
	IMMEDIATE,
	NEXT_WINDOW,
}

enum State {
	PENDING,
	SUCCESS,
	DECLINED,
}

var id: int
var player_id: int
var player_name: String
var team: TeamBasic
var state: State
var timing: Timing

# random delay for next response
var delay_days: int


func _init(
	p_id: int = -1,
	p_player_id: int = -1,
	p_player_name: String = "",
	p_team: TeamBasic = TeamBasic.new(),
	p_state: State = State.PENDING,
	p_timing: Timing = Timing.IMMEDIATE,
	p_delay_days: int = 0,
) -> void:
	id = p_id
	player_id = p_player_id
	player_name = p_player_name
	team = p_team
	state = p_state
	timing = p_timing
	delay_days = p_delay_days


func set_id() -> void:
	id = IdUtil.next_id(IdUtil.Types.OFFER)


func update() -> void:
	if delay_days > 0:
		delay_days -= 1
		return

