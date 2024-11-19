# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later
class_name MatchScreen
extends Control

const MAX_SPEED_FACTOR: int = 20
const MAX_COMMENTS: int = 16
var last_active_view: Control

var home_team: Team
var away_team: Team

var match_started: bool = false
var first_half: bool = true

var matchz: Match

var home_stats: MatchStatistics
var away_stats: MatchStatistics

@onready var match_simulator: MatchSimulator = $MatchSimulator
@onready var stats: VisualMatchStats = %Stats
@onready var comments: VBoxContainer = %Log
@onready var events: MatchEvents = %Events
@onready var formation: VisualFormation = %Formation
@onready var time_label: Label = %Time
@onready var result_label: Label = %Result
@onready var home_color: ColorRect = %HomeColor
@onready var away_color: ColorRect = %AwayColor
@onready var home_possession: Label = %HomePossessionLabel
@onready var away_possession: Label = %AwayPossessionLabel
@onready var home_name: Label = %HomeNameLabel
@onready var away_name: Label = %AwayNameLabel
@onready var time_bar: ProgressBar = %TimeBar
@onready var possess_bar: ProgressBar = %PossessBar

@onready var pause_button: Button = %PauseButton
@onready var faster_button: Button = %FasterButton
@onready var slower_button: Button = %SlowerButton
@onready var speed_factor_label: Label = %SpeedFactor
@onready var dashboard_button: Button = %DashboardButton
@onready var events_button: Button = %EventsButton
@onready var stats_button: Button = %StatsButton
@onready var field_button: Button = %FieldButton
@onready var formation_button: Button = %FormationButton

@onready var players_bar: PlayersBar = %PlayersBar


func _ready() -> void:
	theme = ThemeUtil.get_active_theme()
	InputUtil.start_focus(self)

	if Global.world:
		matchz = Global.world.calendar.get_next_match()
	# setup automatically, if run in editor and is run by 'Run current scene'
	elif OS.has_feature("editor"):
		matchz = Match.new()
		# games needs to be started at least once with a valid save state
		matchz.home = Tests.create_mock_team()
		matchz.away = Tests.create_mock_team()
		# if running match scene, set Global team to home team
		if not Global.team:
			Global.team = matchz.home


	# duplicate teams to not change real teams references
	# player order, tactics ecc. changes live only during match
	# no deep copy, since players itself acutally should keep changes
	home_team = matchz.home.duplicate()
	away_team = matchz.away.duplicate()

	home_name.text = matchz.home.name
	away_name.text = matchz.away.name

	# set up formations with player controlled teams copy	
	if home_team.id == Global.team.id:
		formation.setup(true, home_team)
		players_bar.setup(home_team)
	else:
		formation.setup(true, away_team)
		players_bar.setup(away_team)

	match_simulator.setup(home_team, away_team, matchz.id)
	
	# set colors
	home_color.color = home_team.get_home_color()
	away_color.color = away_team.get_away_color(home_color.color)

	speed_factor_label.text = str(Global.speed_factor) + " X"

	print("match speed_factor" + str(Global.speed_factor))

	# to easier access stats
	home_stats = match_simulator.match_engine.home_team.stats
	away_stats = match_simulator.match_engine.away_team.stats
	
	last_active_view = match_simulator
	last_active_view.show()
	

func match_end() -> void:
	faster_button.hide()
	slower_button.hide()
	speed_factor_label.hide()
	pause_button.hide()
	dashboard_button.show()

	#assign result
	matchz.set_result(home_stats.goals, away_stats.goals)


func half_time() -> void:
	pause_button.text = tr("CONTINUE")
	first_half = false


func _on_field_button_pressed() -> void:
	_hide_views()
	match_simulator.show()
	last_active_view = match_simulator


func _on_commentary_button_pressed() -> void:
	_hide_views()
	comments.show()
	last_active_view = comments


func _on_stats_button_pressed() -> void:
	_hide_views()
	stats.show()
	last_active_view = stats


func _on_events_button_pressed() -> void:
	_hide_views()
	events.show()
	last_active_view = events


func _on_formation_button_pressed() -> void:
	_hide_views()
	formation.show()
	match_simulator.pause()
	pause_button.text = tr("CONTINUE")


func _hide_views() -> void:
	comments.hide()
	stats.hide()
	events.hide()
	formation.hide()
	match_simulator.hide()


func _toggle_view_buttons() -> void:
	events_button.disabled = not events_button.disabled
	stats_button.disabled = not stats_button.disabled
	field_button.disabled = not field_button.disabled
	formation_button.disabled = not formation_button.disabled


func _on_dashboard_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/screens/dashboard/dashboard.tscn")


func _on_faster_button_pressed() -> void:
	if Global.speed_factor < MAX_SPEED_FACTOR:
		Global.speed_factor += 1
		match_simulator.set_time()
	speed_factor_label.text = str(Global.speed_factor) + " X"


func _on_slower_button_pressed() -> void:
	if Global.speed_factor > 1:
		Global.speed_factor -= 1
		match_simulator.set_time()
	speed_factor_label.text = str(Global.speed_factor) + " X"


func _on_pause_button_pressed() -> void:
	var paused: bool = match_simulator.pause_toggle()
	if paused:
		pause_button.text = tr("CONTINUE")
	else:
		pause_button.text = tr("PAUSE")
		_hide_views()
		last_active_view.show()


func _on_skip_button_pressed() -> void:
	match_end()


func _on_start_timer_timeout() -> void:
	match_simulator.start_match()


func _on_match_simulator_half_time() -> void:
	half_time()


func _on_match_simulator_match_end() -> void:
	match_end()


func _on_match_simulator_action_message(message: String) -> void:
	if comments.get_child_count() > MAX_COMMENTS:
		comments.remove_child(comments.get_child(0))
	var new_line: Label = Label.new()
	new_line.text = time_label.text + " " + message
	comments.add_child(new_line)


func _on_match_simulator_update_time() -> void:
	stats.update_stats(home_stats, away_stats)
	time_label.text = "%02d:%02d" % [int(match_simulator.time) / 60, int(match_simulator.time) % 60]

	time_bar.value = match_simulator.time
	possess_bar.value = home_stats.possession

	home_possession.text = str(home_stats.possession) + " %"
	away_possession.text = str(away_stats.possession) + " %"
	result_label.text = "%d - %d" % [home_stats.goals, away_stats.goals]


func _on_formation_change_request() -> void:
	players_bar.update_players()
	match_simulator.match_engine.home_team.change_players_request()
	match_simulator.match_engine.away_team.change_players_request()


func _on_players_bar_change_request() -> void:
	formation.set_players()
	match_simulator.match_engine.home_team.change_players_request()
	match_simulator.match_engine.away_team.change_players_request()

