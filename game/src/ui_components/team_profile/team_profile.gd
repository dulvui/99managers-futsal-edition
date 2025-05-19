# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamProfile
extends MarginContainer

@onready var custom_tab_container: CustomTabContainer = %CustomTabContainer
@onready var player_list: PlayerList = %Players

@onready var name_label: Label = %Name
@onready var prestige_label: Label = %PrestigeStars
@onready var budget_label: Label = %Budget
@onready var salary_budget_label: Label = %SalaryBudget
@onready var stadium_name_label: Label = %StadiumName
@onready var stadium_capacity_label: Label = %StadiumCapacity
@onready var stadium_year_label: Label = %StadiumYearBuilt


func _ready() -> void:
	if Tests.is_run_as_current_scene(self):
		Tests.setup_mock_world()
		setup(Global.team)

	custom_tab_container.setup([tr("Info"), tr("Players")])


func setup(team: Team) -> void:
	player_list.setup(team.id)
	_set_labels(team)


func _set_labels(team: Team) -> void:
	name_label.text = team.name
	prestige_label.text = FormatUtil.stars(team.prestige)
	budget_label.text = tr("Budget") + " " + FormatUtil.currency(team.finances.balance[-1])
	salary_budget_label.text = (
		tr("Salary budget") + " " + FormatUtil.currency(team.finances.get_salary_budget())
	)
	stadium_name_label.text = team.stadium.name
	stadium_capacity_label.text = str(team.stadium.capacity) + " " + tr("Persons")
	stadium_year_label.text = tr("Year") + " " + str(team.stadium.year_built)

