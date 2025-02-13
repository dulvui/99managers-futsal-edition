# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SaveStateScreen
extends Control

const SaveStateEntryScene: PackedScene = preload(Const.SCENE_SAVE_STATE_ENTRY)

@onready var entry_list: VBoxContainer = %EntryList
@onready var active_save_state_entry: SaveStateEntry = %ActiveSaveState


func _ready() -> void:
	var active_save_state: SaveState = Global.save_states.get_active()
	active_save_state_entry.setup(active_save_state)

	InputUtil.start_focus(active_save_state_entry.load_button)

	for save_state_id: String in Global.save_states.id_list:
		if save_state_id != active_save_state.id:
			var save_state: SaveState = Global.save_states.load_state(save_state_id)
			var entry: SaveStateEntry = SaveStateEntryScene.instantiate()
			entry_list.add_child(entry)
			entry.setup(save_state)

	ResUtil.loading_failed.connect(_on_res_util_loading_failed)


func _on_menu_pressed() -> void:
	Main.change_scene(Const.SCREEN_MENU)


func _on_res_util_loading_failed() -> void:
	Main.hide_loading_screen()
	print("loading failed...")



