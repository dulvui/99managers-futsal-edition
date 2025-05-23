# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Menu
extends Control

@onready var save_state: SaveStateEntry = %SaveState
@onready var load_game: Button = %LoadGame
@onready var continue_game: Button = %ContinueGame
@onready var new_game: Button = %NewGame
@onready var exit: Button = %Exit
@onready var exit_confirm_dialog: DefaultConfirmDialog = %ExitConfirmDialog


func _ready() -> void:
	InputUtil.start_focus(self)
	# hide exit button for iOS
	exit.visible = OS.get_name() != "iOS"

	if not Global.save_states or Global.save_states.id_list.size() == 0:
		load_game.hide()
		continue_game.hide()
		InputUtil.start_focus(new_game)
		new_game.theme_type_variation = ThemeUtil.BUTTON_IMPORTANT
	else:
		InputUtil.start_focus(continue_game)

	save_state.setup(Global.save_states.get_active())

	Main.check_layout_direction()

	DataUtil.loading_failed.connect(_on_loading_failed)
	ThreadUtil.loading_done.connect(_on_loading_done)

	# always reset data in menu, to clear memory
	Global.reset_data()


func _on_new_game_pressed() -> void:
	Main.change_scene(Const.SCREEN_SETUP_WORLD)


func _on_continue_game_pressed() -> void:
	Main.show_loading_screen(tr("Loading game"))
	Global.load_save_state()


func _on_settings_pressed() -> void:
	Main.change_scene(Const.SCREEN_SETTINGS)


func _on_about_pressed() -> void:
	Main.change_scene(Const.SCREEN_ABOUT)


func _on_load_game_pressed() -> void:
	Main.change_scene(Const.SCREEN_SAVE_STATES)


func _on_loading_done() -> void:
	Main.change_scene(Const.SCREEN_DASHBOARD)


func _on_loading_failed() -> void:
	Main.change_scene(Const.SCREEN_SAVE_STATES)


func _on_exit_pressed() -> void:
	exit_confirm_dialog.popup_centered()


func _on_default_confirm_dialog_confirmed() -> void:
	get_tree().quit()

