# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamSelect
extends Control

var active_league: League
var active_team: Team

@onready var nations_container: HBoxContainer = $MarginContainer/VBoxContainer/NationSelect
@onready var team_list: VBoxContainer = $MarginContainer/VBoxContainer/Main/ScrollContainer/TeamList
@onready var team_profile: TeamProfile = $MarginContainer/VBoxContainer/Main/TeamProfile


func _ready() -> void:
	theme = ThemeUtil.get_active_theme()

	for continent: Continent in Global.world.continents:
		var continent_label: Label = Label.new()
		continent_label.text = continent.name
		nations_container.add_child(continent_label)
		for nation: Nation in continent.nations:
			var button: Button = Button.new()
			button.text = nation.name
			nations_container.add_child(button)
			button.pressed.connect(_on_nation_select.bind(nation))

	set_teams()
	var first_league: League = Global.world.get_all_leagues()[0]
	active_league = first_league
	active_team = first_league.teams[0]
	team_profile.set_up(active_team)


func show_team(league: League, team: Team) -> void:
	active_league = league
	active_team = team
	team_profile.set_team(active_team)


func set_teams(p_nation: Nation = Global.world.get_all_nations()[0]) -> void:
	for child: Node in team_list.get_children():
		child.queue_free()

	for league: League in p_nation.leagues:
		var league_label: Label = Label.new()
		league_label.text = league.name
		team_list.add_child(league_label)
		ThemeUtil.bold(league_label)
		for team: Team in league.teams:
			var team_button: Button = Button.new()
			team_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			team_button.text = team.get_prestige_stars() + "  " + team.name
			team_button.pressed.connect(show_team.bind(league, team))
			team_list.add_child(team_button)


func _on_nation_select(nation: Nation) -> void:
	set_teams(nation)
	var first_league: League = nation.leagues[0]
	show_team(first_league, first_league.teams[0])


func _on_select_team_pressed() -> void:
	active_team.staff.manager = Global.manager
	Global.select_team(active_league, active_team)
	get_tree().change_scene_to_file("res://src/screens/dashboard/dashboard.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://src/screens/setup/setup_manager/setup_manager.tscn")
