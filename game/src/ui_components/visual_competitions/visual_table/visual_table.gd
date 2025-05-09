# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualTable
extends GridContainer

const ColorLabelScene: PackedScene = preload(Const.SCENE_COLOR_LABEL)


var dynamic_content: Array[Control]


func _ready() -> void:
	Tests.setup_mock_world(true)

	dynamic_content = []


func setup(
	table: Table,
	direct_promotion: int = 0,
	playoff_teams: int = 0,
	direct_relegation: int = 0,
	playout_teams: int = 0,
) -> void:
	# clear grid
	for label: Label in dynamic_content:
		label.queue_free()

	# transform table dictionary to array
	var table_array: Array[TableValues] = table.to_sorted_array()

	var pos: int = 1
	for team: TableValues in table_array:
		var pos_label: ColorLabel = ColorLabelScene.instantiate()
		# _style_label(team.team.id, pos_label)
		pos_label.text = str(pos)

		# colorize promotions/relegations and playoffs/playouts
		if pos <= direct_promotion:
			pos_label.high()
			pos_label.tooltip_text = tr("Direct promotion")
		elif pos <= direct_promotion + playoff_teams:
			pos_label.mid()
			pos_label.tooltip_text = tr("Playoffs")
		elif pos > table_array.size() - direct_relegation:
			pos_label.low()
			pos_label.tooltip_text = tr("Direct relegation")
		elif pos > table_array.size() - playout_teams - direct_relegation:
			pos_label.mid()
			pos_label.tooltip_text = tr("Playouts")

		dynamic_content.append(pos_label)
		pos += 1

		var name_label: Label = Label.new()
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		name_label.text = team.team.name
		dynamic_content.append(name_label)
		if team.team.id == Global.team.id:
			ThemeUtil.bold(name_label)

		var games_played_label: Label = Label.new()
		_style_label(team.team.id, games_played_label)
		games_played_label.text = str(team.wins + team.draws + team.lost)
		dynamic_content.append(games_played_label)

		var wins_label: Label = Label.new()
		_style_label(team.team.id, wins_label)
		wins_label.text = str(team.wins)
		dynamic_content.append(wins_label)

		var draws_label: Label = Label.new()
		_style_label(team.team.id, draws_label)
		draws_label.text = str(team.draws)
		dynamic_content.append(draws_label)

		var lost_label: Label = Label.new()
		_style_label(team.team.id, lost_label)
		lost_label.text = str(team.lost)
		dynamic_content.append(lost_label)

		var goals_difference: Label = Label.new()
		_style_label(team.team.id, goals_difference)
		var difference: int = team.goals_made - team.goals_conceded
		if difference >= 0:
			goals_difference.text = "+%d" % difference
		else:
			goals_difference.text = "%d" % difference
		dynamic_content.append(goals_difference)

		var goals_made_label: Label = Label.new()
		_style_label(team.team.id, goals_made_label)
		goals_made_label.text = "%d:%d" % [team.goals_made, team.goals_conceded]
		dynamic_content.append(goals_made_label)

		# form
		dynamic_content.append(_form_row(team.team.id, team.form))

		var points_label: Label = Label.new()
		_style_label(team.team.id, points_label)
		points_label.text = str(team.points)
		dynamic_content.append(points_label)

	# add to grid
	for content: Control in dynamic_content:
		add_child(content)


func _style_label(team_id: int, label: Label) -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(40, 0)
	if team_id == Global.team.id:
		ThemeUtil.bold(label)


func _form_row(team_id: int, forms: Array[TableValues.Form]) -> HBoxContainer:
	var box: HBoxContainer = HBoxContainer.new()

	# iterate over last 5 form values
	for i: int in range(max(forms.size() - 5, 0), forms.size()):
		var form: TableValues.Form = forms[i]
		var label: Label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_PASS

		if team_id == Global.team.id:
			ThemeUtil.bold(label)

		if form == TableValues.Form.WIN:
			label.text = tr("Victory").substr(0, 1)
			label.tooltip_text = tr("Victory")
			label.label_settings = ThemeUtil.label_settings_high
		elif form == TableValues.Form.DRAW:
			label.text = tr("Draw").substr(0, 1)
			label.tooltip_text = tr("Draw")
			label.label_settings = ThemeUtil.label_settings_mid
		else:
			label.text = tr("Defeat").substr(0, 1)
			label.tooltip_text = tr("Defeat")
			label.label_settings = ThemeUtil.label_settings_low

		box.add_child(label)

	# fill if not at least 5 forms exist
	if forms.size() < 5:
		for i: int in 5 - forms.size():
			var label: Label = Label.new()
			if team_id == Global.team.id:
				ThemeUtil.bold(label)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.mouse_filter = Control.MOUSE_FILTER_PASS
			label.text = "?" # NO_TRANSLATE
			label.tooltip_text = tr("To be played")
			box.add_child(label)

	return box
