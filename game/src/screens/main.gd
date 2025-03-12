# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control

@onready var version: Label = %Version
@onready var content: Control = %Content
@onready var scene_fade: SceneFade = %SceneFade
@onready var loading_screen: LoadingScreen = $LoadingScreen

var previous_scenes: Array[String]
var scene_name_on_load: String


func _ready() -> void:
	theme = ThemeUtil.get_active_theme()
	loading_screen.hide()

	previous_scenes = []
	scene_name_on_load = ""
	version.text = "v" + Global.version

	scene_fade.fade_in()


func change_scene(scene_path: String) -> void:
	await scene_fade.fade_out()

	for child: Node in content.get_children():
		content.remove_child(child)
		child.queue_free()

	_append_scene_to_buffer(scene_path)

	var scene: PackedScene = load(scene_path)
	content.add_child(scene.instantiate())
	scene_fade.fade_in()


func previous_scene() -> void:
	if previous_scenes.size() > 1:
		change_scene(previous_scenes[-2])
	else:
		print("not valid previous scene found")


func show_loading_screen(p_scene_name_on_load: String = "") -> void:
	scene_name_on_load = p_scene_name_on_load
	scene_fade.fade_in()
	loading_screen.show()


func hide_loading_screen() -> void:
	scene_fade.fade_in()
	loading_screen.hide()


func check_layout_direction() -> void:
	if Global.config.language == "apc":
		layout_direction = LAYOUT_DIRECTION_RTL
	else:
		layout_direction = LAYOUT_DIRECTION_INHERITED


func _append_scene_to_buffer(scene_path: String) -> void:
	previous_scenes.append(scene_path)
	if previous_scenes.size() > 5:
		previous_scenes.remove_at(0)


func _on_loading_screen_loaded() -> void:
	if not scene_name_on_load.is_empty():
		change_scene(scene_name_on_load)
		scene_name_on_load = ""
	else:
		scene_fade.fade_out()
	loading_screen.hide()
