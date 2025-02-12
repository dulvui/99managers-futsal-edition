# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SaveStateEntry
extends VBoxContainer

@export var hide_buttons: bool = false

var save_state: SaveState

@onready var delete_dialog: DefaultConfirmDialog = %DeleteDialog
@onready var team: Label = %Team
@onready var create_date: Label = %CreateDate
@onready var manager: Label = %Manager
@onready var placement: Label = %Placement
@onready var game_date: Label = %GameDate
@onready var last_save_date: Label = %LastSaveDate
@onready var delete_button: Button = %Delete
@onready var load_button: Button = %Load


func setup(p_save_state: SaveState) -> void:
	save_state = p_save_state

	if save_state == null or save_state.meta_is_temp:
		hide()
		return

	team.text = save_state.meta_team_name
	manager.text = save_state.meta_manager_name
	placement.text = save_state.meta_team_position
	create_date.text = FormatUtil.format_date(save_state.meta_create_date)
	game_date.text = FormatUtil.format_date(save_state.meta_game_date)
	last_save_date.text = FormatUtil.format_date(save_state.meta_last_save)

	delete_button.visible = not hide_buttons
	load_button.visible = not hide_buttons


func _on_load_pressed() -> void:
	print("load save state with id ", save_state.id)
	Global.save_states.active_id = save_state.id
	Global.load_save_state()
	LoadingUtil.start(tr("Loading game"), LoadingUtil.Type.LOAD_GAME)
	Main.show_loading_screen(Const.SCREEN_DASHBOARD)


func _on_delete_pressed() -> void:
	delete_dialog.popup()


func _on_delete_dialog_confirmed() -> void:
	Global.save_states.delete(save_state)
	Global.save_config()
	ResUtil.save_save_states()
	if Global.save_states.id_list.size() == 0:
		Main.change_scene(Const.SCREEN_MENU)
	else:
		Main.change_scene(Const.SCREEN_SAVE_STATES)

