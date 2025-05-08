# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PenaltiesBar
extends PanelContainer

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


func setup(home_team: SimTeam, away_team: SimTeam) -> void:
	if home_team.has_ball:
		first_team = home_team
		second_team = away_team
	else:
		first_team = away_team
		second_team = home_team

	shots_index = 0
	first_goals = 0
	second_goals = 0
	first_result_index = 0
	second_result_index = 0

	# shot number indicators in first line
	number_labels = []
	for i: int in Const.PENALTY_KICKS:
		var label: Label = get_node("%ShotIndex" + str(i + 1))
		number_labels.append(label)

	# team labels
	first_label.text = first_team.res.name
	second_label.text = second_team.res.name

	# result color rects
	first_result = []
	second_result = []
	for i: int in Const.PENALTY_KICKS:
		# first team
		var first_color_rect: ColorRect = get_node("%FirstResult" + str(i + 1))
		first_color_rect.color = Color.WHITE
		first_result.append(first_color_rect)
		# second team
		var second_color_rect: ColorRect = get_node("%SecondResult" + str(i + 1))
		second_color_rect.color = Color.WHITE
		second_result.append(second_color_rect)


func update() -> void:
	# first 5 shots already taken
	# update shot index labels and shift results one left
	if shots_index % 2 == 0 and shots_index >= Const.PENALTY_KICKS * 2:
		# increment number labels
		for label: Label in number_labels:
			label.text = str(int(label.text) + 1)
		# shift colors
		for i: int in Const.PENALTY_KICKS - 2:
			# first team
			var first_color_rect: ColorRect = get_node("%FirstResult" + str(i + 1))
			var first_color_rect2: ColorRect = get_node("%FirstResult" + str(i + 2))
			first_color_rect.color = first_color_rect2.color
			# second team
			var second_color_rect: ColorRect = get_node("%SecondResult" + str(i + 1))
			var second_color_rect2: ColorRect = get_node("%SecondResult" + str(i + 2))
			second_color_rect.color = second_color_rect2.color
		# make last one white again
		var first_color_rect_last: ColorRect = get_node("%FirstResult5")
		first_color_rect_last.color = Color.WHITE
		var second_color_rect_last: ColorRect = get_node("%SecondResult5")
		second_color_rect_last.color = Color.WHITE

	if shots_index % 2 == 0:
		# first team
		if first_team.stats.penalty_shootout_goals == first_goals:
			# miss
			first_result[first_result_index].color = Color.RED
		else:
			first_goals += 1
			first_result[first_result_index].color = Color.GREEN

		# increase index
		if first_result_index < Const.PENALTY_KICKS - 1:
			first_result_index += 1
	else:
		# second team
		if second_team.stats.penalty_shootout_goals == second_goals:
			# miss
			second_result[second_result_index].color = Color.RED
		else:
			second_goals += 1
			second_result[second_result_index].color = Color.GREEN

		# increase index
		if second_result_index < Const.PENALTY_KICKS - 1:
			second_result_index += 1
		# first 5 shots already taken
		# update shot index labels and shift results one left

	shots_index += 1
