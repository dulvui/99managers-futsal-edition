# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamProfile
extends DefaultTabContainer

@onready var player_list: PlayerList = $Players
@onready var name_label: Label = $Info/Name
@onready var prestige_stars_label: Label = $Info/PresitgeStars
@onready var prestige_label: Label = $Info/Presitge
@onready var budget_label: Label = $Info/Budget
@onready var salary_budget_label: Label = $Info/SalaryBudget
@onready var stadium_name_label: Label = $Info/StadiumName
@onready var stadium_capacity_label: Label = $Info/StadiumCapacity
@onready var stadium_year_label: Label = $Info/StadiumYearBuilt


func setup(team: Team) -> void:
	player_list.setup(team.id)
	_set_labels(team)


func set_team(team: Team) -> void:
	player_list.update_team(team.id)
	_set_labels(team)


func _set_labels(team: Team) -> void:
	name_label.text = team.name
	prestige_stars_label.text = tr("Prestige") + " " + team.get_prestige_stars()
	prestige_label.text = str(team.get_prestige())
	budget_label.text = tr("Budget") + " " + FormatUtil.currency(team.finances.balance[-1])
	salary_budget_label.text = tr("Salary budget") + " " + FormatUtil.currency(team.finances.get_salary_budget())
	stadium_name_label.text = team.stadium.name
	stadium_capacity_label.text = str(team.stadium.capacity) + " " + tr("Persons")
	stadium_year_label.text = tr("Year") + " " + str(team.stadium.year_built)


