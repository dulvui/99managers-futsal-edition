# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Menu
extends Control

@onready var save_state: SaveStateEntry = %SaveState
@onready var save_separator: HSeparator = %SaveSeparator
@onready var load_game: Button = %LoadGame
@onready var continue_game: Button = %ContinueGame
@onready var new_game: Button = %NewGame
@onready var exit: Button = %Exit
@onready var exit_confirm_dialog: DefaultConfirmDialog = %DefaultConfirmDialog


func _ready() -> void:
	InputUtil.start_focus(self)
	# hide exit button for iOS
	exit.visible = OS.get_name() != "iOS"

	if not Global.save_states or Global.save_states.id_list.size() == 0:
		load_game.hide()
		continue_game.hide() 
		save_separator.hide()
		InputUtil.start_focus(new_game)
	else:
		InputUtil.start_focus(continue_game)


	save_state.setup(Global.save_states.get_active())


func _on_new_game_pressed() -> void:
	Main.change_scene(Const.SCREEN_SETUP_WORLD)


func _on_continue_game_pressed() -> void:
	Global.load_save_state()
	LoadingUtil.start("LOADING_GAME", LoadingUtil.Type.LOAD_GAME)
	Main.show_loading_screen(Const.SCREEN_SETTINGS)


func _on_settings_pressed() -> void:
	Main.change_scene(Const.SCREEN_SETTINGS)


func _on_load_game_pressed() -> void:
	Main.change_scene(Const.SCREEN_SAVE_STATES)


func _on_exit_pressed() -> void:
	exit_confirm_dialog.popup_centered()


func _on_default_confirm_dialog_confirmed() -> void:
	get_tree().quit()

