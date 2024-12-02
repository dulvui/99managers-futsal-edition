# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

# TODO add and save to match??
# maybe also with key events? goals etc
class_name MatchStatistics
extends JSONResource

var goals: int = 0
var possession: int = 50
var shots: int = 0
var shots_on_target: int = 0
var passes: int = 0
var passes_success: int = 0
var kick_ins: int = 0
var free_kicks: int = 0
var penalties: int = 0
var penalties10: int = 0  # from 10 meters, after 6 fouls
var fouls: int = 0
var tackles: int = 0
var tackles_success: int = 0
var corners: int = 0
var headers: int = 0
var headers_on_target: int = 0
var yellow_cards: int = 0
var red_cards: int = 0


func _init(
	p_goals: int = 0,
	p_possession: int = 50,
	p_shots: int = 0,
	p_shots_on_target: int = 0,
	p_passes: int = 0,
	p_passes_success: int = 0,
	p_kick_ins: int = 0,
	p_free_kicks: int = 0,
	p_penalties: int = 0,
	p_penalties10: int = 0,
	p_fouls: int = 0,
	p_tackles: int = 0,
	p_tackles_success: int = 0,
	p_corners: int = 0,
	p_headers: int = 0,
	p_headers_on_target: int = 0,
	p_yellow_cards: int = 0,
	p_red_cards: int = 0,
) -> void:
	goals = p_goals
	possession = p_possession
	shots = p_shots
	shots_on_target = p_shots_on_target
	passes = p_passes
	passes_success = p_passes_success
	kick_ins = p_kick_ins
	free_kicks = p_free_kicks
	penalties = p_penalties
	penalties10 = p_penalties10
	fouls = p_fouls
	tackles = p_tackles
	tackles_success = p_tackles_success
	corners = p_corners
	headers = p_headers
	headers_on_target = p_headers_on_target
	yellow_cards = p_yellow_cards
	red_cards = p_red_cards
