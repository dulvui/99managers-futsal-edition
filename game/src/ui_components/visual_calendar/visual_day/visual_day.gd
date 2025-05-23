# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualDay
extends MarginContainer

signal show_match_list

var date: Day

@onready var competition: VBoxContainer = %Competition
@onready var month_day_label: Label = %MonthDay
@onready var market_label: Label = %Market
@onready var competition_name: Label = %CompetitionName
@onready var team_name_label: Label = %TeamName
@onready var button: Button = $Button


func setup(p_date: Day = Day.new(), matchz: Match = null) -> void:
	date = p_date

	month_day_label.text = tr(str(date.day))

	if matchz != null:
		if Global.team.id == matchz.home.id:
			competition_name.text = matchz.competition_name
			competition_name.tooltip_text = matchz.competition_name
			team_name_label.text = "%s - %s" % [matchz.away.name, tr("Home")]
			team_name_label.tooltip_text = "%s - %s" % [matchz.away.name, tr("Home")]
			competition.show()
		elif Global.team.id == matchz.away.id:
			competition_name.text = matchz.competition_name
			competition_name.tooltip_text = matchz.competition_name
			team_name_label.text = "%s - %s" % [matchz.home.name, tr("Away")]
			team_name_label.tooltip_text = "%s - %s" % [matchz.home.name, tr("Away")]
			competition.show()
	else:
		competition.hide()

	if date.is_same_day(Global.calendar.day()):
		button.theme_type_variation = ThemeUtil.BUTTON_IMPORTANT

	# check if market is active
	if date.market:
		market_label.text = tr("Transfermarket")
		market_label.tooltip_text = tr("Transfermarket")


func unselect() -> void:
	ThemeUtil.remove_bold(month_day_label)
	ThemeUtil.remove_bold(team_name_label)
	ThemeUtil.remove_bold(competition_name)
	ThemeUtil.remove_bold(market_label)


func select() -> void:
	ThemeUtil.bold(month_day_label)
	ThemeUtil.bold(team_name_label)
	ThemeUtil.bold(competition_name)
	ThemeUtil.bold(market_label)


func _on_button_pressed() -> void:
	show_match_list.emit()
	# unselect other days
	get_tree().call_group("visual-day", "unselect")
	select()
