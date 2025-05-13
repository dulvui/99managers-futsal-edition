# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamSelect
extends Control

var active_team: Team

@onready var teams_tree: TeamsTree = %TeamsTree
@onready var team_profile: TeamProfile = %TeamProfile


func _ready() -> void:
	InputUtil.start_focus(self)

	teams_tree.setup()

	var first_league: League = Global.world.get_all_leagues(true)[0]
	active_team = first_league.teams[0]
	team_profile.setup(active_team)


func show_team(team: Team) -> void:
	active_team = team
	team_profile.setup(active_team)


func _on_teams_tree_team_selected(team: Team) -> void:
	show_team(team)


func _on_select_team_pressed() -> void:
	active_team.staff.manager = Global.manager
	Global.select_team(active_team)
	Global.initialize_game()
	Main.change_scene(Const.SCREEN_DASHBOARD)


func _on_back_pressed() -> void:
	Main.clear_current_scene()
