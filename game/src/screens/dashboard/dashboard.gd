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
	PLAYER_OFFER,
	CONTRACT_OFFER,
	PLAYER_PROFILE,
	TEAM_PROFILE,
	FINANCES,
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
@onready var next_match_button: Button = %NextMatchButton
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
@onready var player_offer: PlayerOffer = %PlayerOffer
@onready var contract_offer: ContractOffer = %ContractOffer
@onready var player_profile: PlayerProfile = %PlayerProfile
@onready var team_profile: TeamProfile = %TeamProfile
@onready var finances: VisualFinances = %Finances

# confirm dialogs
@onready var save_confirm_dialog: DefaultConfirmDialog = %SaveConfirmDialog


func _ready() -> void:
	Tests.setup_mock_world(true)
	
	team = Global.team

	manager_label.text = Global.manager.get_full_name()
	team_label.text = Global.team.name
	date_label.text = Global.world.calendar.format_date()

	all_players_list.setup()
	player_list.setup(Global.team.id)
	formation.setup(false)
	finances.setup(Global.team)

	if Global.world.calendar.is_match_day():
		continue_button.text = tr("Start match")
		match_ready = true
		next_match_button.hide()
	else:
		continue_button.text = tr("Next day")
		match_ready = false

	if Global.world.calendar.is_season_finished():
		next_season = true
		continue_button.text = tr("Next season")

	_show_active_view()
	email_button.grab_focus()
	
	# connect player and team signals
	LinkUtil.team_link.connect(_on_teamlink)



func _process(_delta: float) -> void:
	var email_count: int = EmailUtil.count_unread_messages()
	if email_count > 0:
		email_button.text = "[" + str(EmailUtil.count_unread_messages()) + "] " + tr("Email")
	else:
		email_button.text = tr("Email")


func _on_search_action() -> void:
	match active_view:
		ContentViews.EMAIL:
			email.search_line_edit.grab_focus()
		ContentViews.PLAYERS:
			player_list.search_line_edit.grab_focus()
		ContentViews.ALL_PLAYERS:
			all_players_list.search_line_edit.grab_focus()
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


func _on_all_player_list_select_player(player: Player) -> void:
	player_profile.set_player(player)
	_show_active_view(ContentViews.PLAYER_PROFILE)


func _on_player_list_select_player(player: Player) -> void:
	player_profile.set_player(player)
	_show_active_view(ContentViews.PLAYER_PROFILE)


func _on_teamlink(p_team: Team) -> void:
	team_profile.setup(p_team)
	_show_active_view(ContentViews.TEAM_PROFILE)


func _hide_all() -> void:
	competitions.hide()
	email.hide()
	visual_calendar.hide()
	formation.hide()
	all_players_list.hide()
	player_list.hide()
	info.hide()
	player_offer.hide()
	contract_offer.hide()
	player_profile.hide()
	team_profile.hide()
	finances.hide()


func _show_active_view(p_active_view: int = -1, from_history: bool = false) -> void:
	_hide_all()
	if p_active_view > -1:
		active_view = p_active_view as ContentViews

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
		ContentViews.PLAYER_OFFER:
			player_offer.show()
		ContentViews.PLAYER_PROFILE:
			player_profile.show()
		ContentViews.TEAM_PROFILE:
			team_profile.show()
		ContentViews.CONTRACT_OFFER:
			contract_offer.show()
		ContentViews.FINANCES:
			finances.show()
		_:
			email.show()

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


func _on_continue_button_pressed() -> void:
	_next_day()
	# remove comment to test player progress
	# PlayerProgress.update_players()


func _on_next_match_button_pressed() -> void:
	next_match_button.disabled = true
	continue_button.disabled = true

	while not match_ready:
		_next_day()
		var timer: Timer = Timer.new()
		add_child(timer)
		timer.start(DASHBOARD_DAY_DELAY)
		await timer.timeout

	next_match_button.disabled = false
	continue_button.disabled = false


func _next_day() -> void:
	if match_ready:
		# thread simulation
		# ThreadUtil.random_results()
		
		# non threaded simulation
		# Global.world.random_results()
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
	if Global.world.calendar.is_season_finished():
		next_season = true
		continue_button.text = tr("Next season")
		return

	# general setup
	email.update_messages()
	date_label.text = Global.world.calendar.format_date()

	if Global.world.calendar.day().matches.size() > 0:
		# threaded simulation
		LoadingUtil.start(tr("Simulating results"), LoadingUtil.Type.MATCH_RESULTS, true)
		Main.show_loading_screen()
		ThreadUtil.random_results()
		
		# non threaded simulation
		# Global.world.random_r=esults()

	# check matches
	if Global.world.calendar.is_match_day():
		continue_button.text = tr("Start match")
		match_ready = true
		next_match_button.disabled = true
		next_match_button.hide()

	visual_calendar.setup()


func _on_email_email_action(message: EmailMessage) -> void:
	if message.type == EmailMessage.Type.CONTRACT_OFFER:
		contract_offer.setup(TransferUtil.get_transfer_id(message.foreign_id))
		_show_active_view(ContentViews.CONTRACT_OFFER)
	else:
		print("ERROR: Email action with no type. Text: " + message.text)


func _on_contract_offer_cancel() -> void:
	contract_offer.hide()
	_show_active_view(ContentViews.EMAIL)


func _on_contract_offer_confirm() -> void:
	contract_offer.hide()
	_show_active_view(ContentViews.EMAIL)


func _on_player_offer_confirm() -> void:
	email.update_messages()
	player_offer.hide()
	_show_active_view(ContentViews.ALL_PLAYERS)


func _on_player_offer_cancel() -> void:
	_show_active_view(ContentViews.PLAYER_PROFILE)


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


func _on_player_profile_offer(player: Player) -> void:
	player_offer.set_player(player)
	_show_active_view(ContentViews.PLAYER_OFFER)


func _on_settings_button_pressed() -> void:
	Main.change_scene(Const.SCREEN_SETTINGS)


func _on_menu_button_pressed() -> void:
	save_confirm_dialog.popup_centered()


func _on_save_confirm_dialog_confirmed() -> void:
	LoadingUtil.start(tr("Saving game"), LoadingUtil.Type.SAVE_GAME, true)
	Main.show_loading_screen(Const.SCREEN_MENU)
	Global.save_all_data()


func _on_save_confirm_dialog_denied() -> void:
	Main.change_scene(Const.SCREEN_MENU)



