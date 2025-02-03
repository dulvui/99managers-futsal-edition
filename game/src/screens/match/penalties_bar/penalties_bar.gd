# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PenaltiesBar
extends GridContainer

var shots_index: int

var first_team: SimTeam
var second_team: SimTeam

var first_goals: int
var second_goals: int
var first_result_index: int
var second_result_index: int

var number_labels: Array[Label]
var first_result: Array[ColorRect]
var second_result: Array[ColorRect]

@onready var first_label: Label = %FirstTeam
@onready var second_label: Label = %SecondTeam


func setup(engine: MatchEngine) -> void:
	first_team = engine.home_team
	second_team = engine.away_team

	shots_index = 0
	first_goals = 0
	second_goals = 0
	first_result_index = 0
	second_result_index = 0

	# shot number indicators in first line
	number_labels =	[]
	for i: int in Const.PENALTY_KICKS:
		var label: Label = Label.new()
		label.text = str(i + 1)
		add_child(label)
		number_labels.append(label)

	# team labels
	first_label.text = first_team.team_res.name
	second_label.text = second_team.team_res.name

	# result color rects
	first_result = []
	second_result = []
	for i: int in Const.PENALTY_KICKS:
		# first team
		var first_color_rect: ColorRect = get_node("FirstResult" + str(i + 1))
		first_color_rect.color = Color.WHITE
		first_result.append(first_color_rect)
		# second team
		var second_color_rect: ColorRect = get_node("SecondResult" + str(i + 1))
		second_color_rect.color = Color.WHITE
		second_result.append(second_color_rect)


func update() -> void:
	if shots_index % 2 == 0:
		# first team
		if first_team.stats.penalty_shootout_goals == first_goals:
			# miss
			first_result[first_result_index].color = Color.RED
		else:
			first_goals += 1
			first_result[first_result_index].color = Color.GREEN

		# increase index
		if first_result_index < Const.PENALTY_KICKS:
			first_result_index += 1
		# first 5 shots already taken
		# update shot index labels and shift results one left


	shots_index += 1
