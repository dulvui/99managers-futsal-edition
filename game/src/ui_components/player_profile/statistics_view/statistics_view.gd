# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StatisticsView
extends VBoxContainer

var value_labels: Array[Label]

@onready var grid: GridContainer = %GridContainer


func _ready() -> void:
	value_labels = []


func setup(player: Player) -> void:
	# clear labels first
	for label: Label in value_labels:
		label.queue_free()
	value_labels.clear()

	_add_statistics(player.statistics, player.team)
	for history: History in player.history:
		_add_statistics(history.statistics, history.team_name)


func _add_statistics(statistics: Statistics, team_name: String) -> void:
	var team: Label = Label.new()
	var games_played: Label = Label.new()
	games_played.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var goals: Label = Label.new()
	goals.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var assists: Label = Label.new()
	assists.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var yellow_cards: Label = Label.new()
	yellow_cards.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var red_cards: Label = Label.new()
	red_cards.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var average_vote: Label = Label.new()
	average_vote.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	team.text = team_name
	games_played.text = str(statistics.games_played)
	goals.text = str(statistics.goals)
	assists.text = str(statistics.assists)
	yellow_cards.text = str(statistics.yellow_cards)
	red_cards.text = str(statistics.red_cards)
	average_vote.text = "%.2f" % statistics.average_vote

	grid.add_child(team)
	grid.add_child(games_played)
	grid.add_child(goals)
	grid.add_child(assists)
	grid.add_child(yellow_cards)
	grid.add_child(red_cards)
	grid.add_child(average_vote)

	value_labels.append(team)
	value_labels.append(games_played)
	value_labels.append(goals)
	value_labels.append(assists)
	value_labels.append(yellow_cards)
	value_labels.append(red_cards)
	value_labels.append(average_vote)

