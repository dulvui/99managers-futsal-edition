# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Statistics
extends JSONResource

@export var games_played: int
@export var goals: int
@export var assists: int
@export var yellow_cards: int
@export var red_cards: int
@export var average_vote: float


func _init(
	p_games_played: int = 0,
	p_goals: int = 0,
	p_assists: int = 0,
	p_yellow_cards: int = 0,
	p_red_cards: int = 0,
	p_average_vote: float = 0.0,
) -> void:
	games_played = p_games_played
	goals = p_goals
	assists = p_assists
	yellow_cards = p_yellow_cards
	red_cards = p_red_cards
	average_vote = p_average_vote
