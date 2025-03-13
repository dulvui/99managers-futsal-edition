# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control

signal loaded

@onready var version: Label = %Version
@onready var content: Control = %Content
@onready var scene_fade: SceneFade = %SceneFade
@onready var loading_screen: LoadingScreen = $LoadingScreen

var previous_scenes: Array[String]
var scene_name_on_load: String
var manual_hide: bool


func _ready() -> void:
	theme = ThemeUtil.get_active_theme()
	loading_screen.hide()

	previous_scenes = []
	scene_name_on_load = ""
	manual_hide = false

	version.text = "v" + Global.version

	ThreadUtil.loading_done.connect(loading_done)

	scene_fade.fade_in()


func change_scene(scene_path: String) -> void:
	await scene_fade.fade_in()

	for child: Node in content.get_children():
		content.remove_child(child)
		child.queue_free()

	_append_scene_to_buffer(scene_path)

	var scene: PackedScene = load(scene_path)
	content.add_child(scene.instantiate())

	if loading_screen.visible:
		await hide_loading_screen()
	else:
		await scene_fade.fade_out()


func previous_scene() -> void:
	if previous_scenes.size() > 1:
		change_scene(previous_scenes[-2])
	else:
		print("not valid previous scene found")


func show_loading_screen(p_message: String, p_indeterminate: bool = true) -> void:
	loading_screen.start(p_message, p_indeterminate)

	await scene_fade.fade_in()
	loading_screen.show()
	await scene_fade.fade_out()


func set_scene_on_load(p_scene_name_on_load: String) -> void:
	scene_name_on_load = p_scene_name_on_load


func manual_hide_loading_screen() -> void:
	manual_hide = true


func hide_loading_screen() -> void:
	manual_hide = false

	await scene_fade.fade_in()
	loading_screen.hide()
	await scene_fade.fade_out()


func loading_done() -> void:
	loaded.emit()

	if not scene_name_on_load.is_empty():
		change_scene(scene_name_on_load)
	elif not manual_hide:
		hide_loading_screen()

	# reset values
	manual_hide = false
	scene_name_on_load = ""


func check_layout_direction() -> void:
	if Global.config.language == "apc":
		layout_direction = LAYOUT_DIRECTION_RTL
	else:
		layout_direction = LAYOUT_DIRECTION_INHERITED


func apply_theme(index: int) -> void:
	# remove all scenes, because changing theme is much faster with low amound of Nodes
	for child: Node in content.get_children():
		content.remove_child(child)
		child.queue_free()

	ThemeUtil.apply_theme(index)

	# short delay before reloading previous scene after theme change, brings big speed increase
	await get_tree().create_timer(0.05).timeout

	var scene: PackedScene = load(previous_scenes[-1])
	content.add_child(scene.instantiate())


func _append_scene_to_buffer(scene_path: String) -> void:
	previous_scenes.append(scene_path)
	if previous_scenes.size() > 5:
		previous_scenes.remove_at(0)
