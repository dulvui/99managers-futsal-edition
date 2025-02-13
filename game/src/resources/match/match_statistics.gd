# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

# TODO add and save to match??
# maybe also with key events? goals etc
class_name MatchStatistics

var goals: int = 0
var possession: int = 50
var shots: int = 0
var shots_on_target: int = 0
var shots_hit_post: int = 0
var passes: int = 0
var passes_success: int = 0
var kick_ins: int = 0
var free_kicks: int = 0
var penalties: int = 0
var penalties_10m: int = 0  # from 10 meters, after 6 fouls
var fouls: int = 0
var tackles: int = 0
var tackles_success: int = 0
var corners: int = 0
var yellow_cards: int = 0
var red_cards: int = 0
var penalty_shootout_shots: int = 0
var penalty_shootout_goals: int = 0


func duplicate() -> MatchStatistics:
	var copy: MatchStatistics = MatchStatistics.new()
	copy.goals = goals
	copy.possession = possession
	copy.shots = shots
	copy.shots_on_target = shots_on_target
	copy.shots_hit_post = shots_hit_post
	copy.passes = passes
	copy.passes_success = passes_success
	copy.kick_ins = kick_ins
	copy.free_kicks = free_kicks
	copy.penalties = penalties
	copy.penalties_10m = penalties_10m
	copy.fouls = fouls
	copy.tackles = tackles
	copy.tackles_success = tackles_success
	copy.corners = corners
	copy.yellow_cards = yellow_cards
	copy.red_cards = red_cards
	copy.penalty_shootout_shots = penalty_shootout_shots
	copy.penalty_shootout_goals = penalty_shootout_goals
	return copy


