# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListRowStatistics
extends PlayerListRow

@onready var games_played: Label = %GamesPlayed
@onready var goals: Label = %Goals
@onready var assists: Label = %Assists
@onready var yellow_cards: Label = %YellowCards
@onready var red_cards: Label = %RedCards
@onready var average_vote: Label = %AverageVote


func setup(player: Player, index: int) -> void:
	super(player, index)
	games_played.text = str(player.statistics.games_played)
	goals.text = str(player.statistics.goals)
	assists.text = str(player.statistics.assists)
	yellow_cards.text = str(player.statistics.yellow_cards)
	red_cards.text = str(player.statistics.red_cards)
	average_vote.text = str(player.statistics.average_vote)
