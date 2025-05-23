# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Dashboard
extends Control

enum ContentViews {
	EMAIL,
	CALENDAR,
	COMPETITIONS,
	PLAYERS,
	ALL_PLAYERS,
	FORMATION,
	INFO,
	PLAYER_PROFILE,
	TEAM_PROFILE,
	FINANCES,
	STADIUM,
}

const DASHBOARD_DAY_DELAY: float = 0.5

var match_ready: bool = false
var next_season: bool = false

var view_history: Array[ContentViews]
var view_history_index: int = 0
var active_view: ContentViews = ContentViews.EMAIL

@onready var team: Team

# top bar
@onready var continue_button: Button = %ContinueButton
@onready var date_label: Label = %Date
@onready var manager_label: Label = %ManagerName
@onready var team_label: Label = %TeamName

# buttons
@onready var email_button: Button = %EmailButton
@onready var formation_button: Button = %FormationButton
@onready var search_player_button: Button = %SearchPlayerButton

# content views
@onready var email: VisualEmail = %Email
@onready var competitions: VisualCompetitions = %Competitions
@onready var visual_calendar: VisualCalendar = %Calendar
@onready var info: VisualInfo = %Info
@onready var formation: VisualFormation = %Formation
@onready var player_list: PlayerList = %PlayerList
@onready var all_players_list: PlayerList = %AllPlayerList
@onready var player_profile: PlayerProfile = %PlayerProfile
@onready var team_profile: TeamProfile = %TeamProfile
@onready var finances: VisualFinances = %Finances
@onready var stadium: VisualStadium = %Stadium

# confirm dialogs
@onready var save_confirm_dialog: DefaultConfirmDialog = %SaveConfirmDialog


func _ready() -> void:
	if Tests.is_run_as_current_scene(self):
		Tests.setup_mock_world(true)

	var start_time: int = Time.get_ticks_msec()

	team = Global.team

	manager_label.text = Global.manager.get_full_name()
	team_label.text = Global.team.name
	date_label.text = FormatUtil.day(Global.calendar.date)

	all_players_list.setup()
	player_list.setup(Global.team.id)
	formation.setup(false)
	finances.setup(Global.team)
	stadium.setup(Global.team.stadium)

	# update formation stadium colors on change in stadium
	stadium.color_change.connect(
		func(colors: StadiumColors) -> void:
			formation.field.set_colors(colors)
			formation.goals.set_colors(colors)
	)

	if Global.match_list.is_match_day():
		continue_button.text = tr("Start match")
		match_ready = true
	else:
		continue_button.text = tr("Next day")
		match_ready = false

	if Global.calendar.is_season_finished():
		next_season = true
		continue_button.text = tr("Next season")

	_show_active_view()
	email_button.grab_focus()
	_update_email_button()

	# connect player and team signals
	LinkUtil.team_link.connect(_on_team_link)
	LinkUtil.player_link.connect(_on_player_link)

	# connect inbox refresh sinal
	Global.inbox.refresh.connect(_update_email_button)

	ThreadUtil.loading_done.connect(_on_saving_done)

	var end_time: int = Time.get_ticks_msec()
	print("dashboard took %d ms to load" % (end_time - start_time))


func _on_search_action() -> void:
	match active_view:
		ContentViews.EMAIL:
			email.search_line_edit.grab_focus()
		ContentViews.PLAYERS:
			player_list.search_line_edit.grab_focus()
		ContentViews.ALL_PLAYERS:
			all_players_list.search_line_edit.grab_focus()
		ContentViews.COMPETITIONS:
			competitions.competitions_tree.search_line_edit.grab_focus()
		_:
			return


func _on_search_player_button_pressed() -> void:
	_show_active_view(ContentViews.ALL_PLAYERS)


func _on_info_button_pressed() -> void:
	_show_active_view(ContentViews.INFO)


func _on_formation_button_pressed() -> void:
	_show_active_view(ContentViews.FORMATION)


func _on_email_button_pressed() -> void:
	_show_active_view(ContentViews.EMAIL)


func _on_competitions_button_pressed() -> void:
	_show_active_view(ContentViews.COMPETITIONS)


func _on_calendar_button_pressed() -> void:
	_show_active_view(ContentViews.CALENDAR)


func _on_players_button_pressed() -> void:
	_show_active_view(ContentViews.PLAYERS)


func _on_finances_button_pressed() -> void:
	_show_active_view(ContentViews.FINANCES)


func _on_stadium_button_pressed() -> void:
	_show_active_view(ContentViews.STADIUM)


func _on_all_player_list_select_player(player: Player) -> void:
	player_profile.set_player(player)
	_show_active_view(ContentViews.PLAYER_PROFILE)


func _on_player_list_select_player(player: Player) -> void:
	player_profile.set_player(player)
	_show_active_view(ContentViews.PLAYER_PROFILE)


func _on_team_link(p_team: Team) -> void:
	team_profile.setup(p_team)
	_show_active_view(ContentViews.TEAM_PROFILE)


func _on_player_link(p_player: Player) -> void:
	player_profile.set_player(p_player)
	_show_active_view(ContentViews.PLAYER_PROFILE)


func _show_active_view(p_active_view: int = -1, from_history: bool = false) -> void:
	# hide all views
	competitions.hide()
	email.hide()
	visual_calendar.hide()
	formation.hide()
	all_players_list.hide()
	player_list.hide()
	info.hide()
	player_profile.hide()
	team_profile.hide()
	finances.hide()
	stadium.hide()

	# set active view
	if p_active_view > -1:
		active_view = p_active_view as ContentViews

	# show active view
	match active_view:
		ContentViews.EMAIL:
			email.show()
		ContentViews.COMPETITIONS:
			competitions.show()
		ContentViews.CALENDAR:
			visual_calendar.show()
		ContentViews.FORMATION:
			formation.show()
		ContentViews.ALL_PLAYERS:
			all_players_list.show()
		ContentViews.PLAYERS:
			player_list.show()
		ContentViews.INFO:
			info.show()
		ContentViews.PLAYER_PROFILE:
			player_profile.show()
		ContentViews.TEAM_PROFILE:
			team_profile.show()
		ContentViews.FINANCES:
			finances.show()
		ContentViews.STADIUM:
			stadium.show()
		_:
			email.show()

	# add to history
	if not from_history:
		# overwrite history, if other view clicked, while in prevois view
		if view_history_index < view_history.size() - 1:
			view_history = view_history.slice(0, view_history_index + 1)

		# add to history
		if view_history.size() == 0 or active_view != view_history[-1]:
			view_history.append(active_view)
			if view_history.size() > 100:
				view_history.pop_front()
			# set history index to latest
			view_history_index = view_history.size() - 1


func _update_email_button() -> void:
	var email_count: int = Global.inbox.count_unread_messages()
	if email_count > 0:
		email_button.text = "[" + str(Global.inbox.count_unread_messages()) + "] " + tr("Email")
	else:
		email_button.text = tr("Email")


func _on_continue_button_pressed() -> void:
	_next_day()


func _next_day() -> void:
	if match_ready:
		# thread simulation
		# ThreadUtil.random_results()

		# non threaded simulation
		Global.match_list.random_results()
		print("TODO simulate other matches")

		Main.change_scene(Const.SCREEN_MATCH)
		return

	# next day in calendar
	Global.next_day()

	# next season check
	if next_season:
		Global.next_season()
		Main.change_scene(Const.SCREEN_DASHBOARD)
		return
	if Global.calendar.is_season_finished():
		next_season = true
		continue_button.text = tr("Next season")
		return

	# general setup
	email.update_messages()
	date_label.text = FormatUtil.day(Global.calendar.date)

	if not Global.match_list.get_matches_by_day().is_empty():
		# threaded simulation
		# Main.show_loading_screen(tr("Simulating results"))
		# ThreadUtil.random_results()

		# non threaded simulation
		Global.match_list.random_results()

	# check matches
	if Global.match_list.is_match_day():
		continue_button.text = tr("Start match")
		match_ready = true

	visual_calendar.setup()


func _on_email_email_action(_message: EmailMessage) -> void:
	# TODO show player profile of player and open contract offer tab
	pass
	# if message.type == EmailMessage.Type.CONTRACT_OFFER:
	# 	contract_offer.setup(TransferUtil.get_transfer_id(message.foreign_id))
	# 	_show_active_view(ContentViews.CONTRACT_OFFER)
	# else:
	# 	push_error("error email action with no type. text: " + message.text)


func _on_prev_view_button_pressed() -> void:
	view_history_index -= 1
	if view_history_index < 1:
		view_history_index = 0
		# TODO emit other negative click sound

	active_view = view_history[view_history_index]
	_show_active_view(active_view, true)


func _on_next_view_button_pressed() -> void:
	view_history_index += 1
	if view_history_index > view_history.size() - 1:
		view_history_index = view_history.size() - 1
		# TODO emit other negative click sound

	active_view = view_history[view_history_index]
	_show_active_view(active_view, true)


func _on_settings_button_pressed() -> void:
	Main.change_scene(Const.SCREEN_SETTINGS)


func _on_menu_button_pressed() -> void:
	save_confirm_dialog.popup_centered()


func _on_save_confirm_dialog_confirmed() -> void:
	Main.show_loading_screen(tr("Saving game"))
	ThreadUtil.save_all_data()


func _on_saving_done() -> void:
	Main.change_scene(Const.SCREEN_MENU)


func _on_save_confirm_dialog_denied() -> void:
	Main.change_scene(Const.SCREEN_MENU)

