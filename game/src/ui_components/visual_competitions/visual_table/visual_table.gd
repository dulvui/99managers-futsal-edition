# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualTable
extends GridContainer

var dynamic_labels: Array[Label]


func _ready() -> void:
	Tests.setup_mock_world(true)

	dynamic_labels = []


func setup(table: Table) -> void:
	# clear grid
	for label: Label in dynamic_labels:
		label.queue_free()

	# transform table dictionary to array
	var table_array: Array[TableValues] = table.to_sorted_array()

	var pos: int = 1
	for team: TableValues in table_array:
		var pos_label: Label = Label.new()
		pos_label.text = str(pos)
		dynamic_labels.append(pos_label)
		pos += 1

		var name_label: Label = Label.new()
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		name_label.text = team.team_name
		dynamic_labels.append(name_label)

		var games_played_label: Label = Label.new()
		_style_label(games_played_label)
		games_played_label.text = str(team.wins + team.draws + team.lost)
		dynamic_labels.append(games_played_label)

		var wins_label: Label = Label.new()
		_style_label(wins_label)
		wins_label.text = str(team.wins)
		dynamic_labels.append(wins_label)

		var draws_label: Label = Label.new()
		_style_label(draws_label)
		draws_label.text = str(team.draws)
		dynamic_labels.append(draws_label)

		var lost_label: Label = Label.new()
		_style_label(lost_label)
		lost_label.text = str(team.lost)
		dynamic_labels.append(lost_label)

		var goals_made_label: Label = Label.new()
		_style_label(goals_made_label)
		goals_made_label.text = "%d:%d" % [team.goals_made, team.goals_conceded]
		dynamic_labels.append(goals_made_label)

		var points_label: Label = Label.new()
		_style_label(points_label)
		points_label.text = str(team.points)
		dynamic_labels.append(points_label)

		if team.team_name == Global.team.name:
			ThemeUtil.bold(pos_label)
			ThemeUtil.bold(name_label)
			ThemeUtil.bold(games_played_label)
			ThemeUtil.bold(wins_label)
			ThemeUtil.bold(draws_label)
			ThemeUtil.bold(lost_label)
			ThemeUtil.bold(goals_made_label)
			ThemeUtil.bold(points_label)

	for label: Label in dynamic_labels:
		add_child(label)


func _style_label(label: Label) -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(40, 0)


