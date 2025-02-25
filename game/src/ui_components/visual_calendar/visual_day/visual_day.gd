# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualDay
extends MarginContainer

signal show_match_list

var date: Day

@onready var month_day_label: Label = %MonthDay
@onready var market_label: Label = %Market
@onready var competition: VBoxContainer = %Competition
@onready var competition_name: Label = %CompetitionName
@onready var team_name_label: Label = %TeamName
@onready var day_color: ColorRect = $DayColor


func setup(p_date: Day = Day.new(), matchz: Match = null) -> void:
	date = p_date

	month_day_label.text = tr(str(date.day))

	if matchz != null:
		if Global.team.id == matchz.home.id:
			competition_name.text = matchz.competition_name
			team_name_label.text = "%s - %s" % [matchz.away.name, tr("Home")]
			competition.show()
		elif Global.team.id == matchz.away.id:
			competition_name.text = matchz.competition_name
			team_name_label.text = "%s - %s" % [matchz.home.name, tr("Away")]
			competition.show()
	else:
		competition.hide()

	if date.is_same_day(Global.world.calendar.day()):
		day_color.color = ThemeUtil.configuration.style_important_color

	# check if market is active
	if date.market:
		market_label.text = tr("Transfermarket")
	else:
		market_label.text = ""


func unselect() -> void:
	ThemeUtil.remove_bold(month_day_label)


func select() -> void:
	ThemeUtil.bold(month_day_label)


func _on_button_pressed() -> void:
	show_match_list.emit()
	# unselect other days
	get_tree().call_group("visual-day", "unselect")
	select()
