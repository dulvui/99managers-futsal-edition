# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SaveStateScreen
extends Control

const SaveStateEntryScene: PackedScene = preload(Const.SCENE_SAVE_STATE_ENTRY)

@onready var entry_list: VBoxContainer = %EntryList
@onready var active_save_state_entry: SaveStateEntry = %ActiveSaveState
@onready var trash_notice: Label = %TrashNotice
@onready var save_states_path: LineEdit = %SaveStatesPath


func _ready() -> void:
	var active_save_state: SaveState = Global.save_states.get_active()
	active_save_state_entry.setup(active_save_state)

	InputUtil.start_focus(active_save_state_entry.load_button)

	for save_state_id: String in Global.save_states.id_list:
		if save_state_id != active_save_state.id:
			var save_state: SaveState = DataUtil.load_save_state(save_state_id)
			var entry: SaveStateEntry = SaveStateEntryScene.instantiate()
			entry_list.add_child(entry)
			entry.setup(save_state)

	DataUtil.loading_failed.connect(_on_loading_failed)
	ThreadUtil.loading_done.connect(_on_loading_done)

	save_states_path.text = ProjectSettings.globalize_path(DataUtil.SAVE_STATES_PATH)
	trash_notice.visible = not OS.get_name() in "iOS,Web"


func _on_menu_pressed() -> void:
	Main.change_scene(Const.SCREEN_MENU)


func _on_loading_failed() -> void:
	Main.hide_loading_screen()
	# reload screen to show corrupt button
	Main.change_scene(Const.SCREEN_SAVE_STATES)


func _on_loading_done() -> void:
	Main.change_scene(Const.SCREEN_DASHBOARD)


func _on_save_states_path_copy_pressed() -> void:
	DisplayServer.clipboard_set(ProjectSettings.globalize_path(DataUtil.SAVE_STATES_PATH))

