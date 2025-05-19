# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control

var previous_scenes: Array[String]

@onready var version: Label = %Version
@onready var content: Control = %Content
@onready var scene_fade: SceneFade = %SceneFade
@onready var loading_screen: LoadingScreen = $LoadingScreen


func _ready() -> void:
	previous_scenes = []
	version.text = "v" + Global.version

	loading_screen.hide()
	scene_fade.fade_in()


func change_scene(scene_path: String, keep_current_scene: bool = false) -> void:
	_append_scene_to_buffer(scene_path)

	# load and instantiate scene before showing screen fade
	# for smoother transition
	var scene: PackedScene = load(scene_path)
	var instance: Node = scene.instantiate()

	await scene_fade.fade_in()

	# keep current scene in stack, for easier back button
	# like in world setup to preserve settings
	if not keep_current_scene:
		_clear_content()

	content.add_child(instance)

	if loading_screen.visible:
		await hide_loading_screen()
	else:
		await scene_fade.fade_out()


func previous_scene() -> void:
	if previous_scenes.size() > 1:
		change_scene(previous_scenes[-2])
	else:
		print("not valid previous scene found")


# useful if change scene was used with keep_current_scene
func clear_current_scene() -> void:
	await scene_fade.fade_in()

	var child: Node = content.get_children().pop_back()
	if child != null:
		content.remove_child(child)
		child.queue_free()

	await scene_fade.fade_out()


func update_loading_progress(progress: float) -> void:
	loading_screen.update(progress)


func show_loading_screen(p_message: String) -> void:
	_toggle_input(false)

	loading_screen.start(p_message)

	await scene_fade.fade_in(2.0)
	loading_screen.show()
	await scene_fade.fade_out()


func hide_loading_screen() -> void:
	await scene_fade.fade_in()
	loading_screen.hide()
	await scene_fade.fade_out()

	_toggle_input(true)


func check_layout_direction() -> void:
	if Global.config.language == "apc":
		layout_direction = LAYOUT_DIRECTION_RTL
	else:
		layout_direction = LAYOUT_DIRECTION_INHERITED


func apply_theme(index: int) -> void:
	# remove all scenes, because changing theme is much faster with low amount of Nodes
	for child: Node in content.get_children():
		content.remove_child(child)
		child.queue_free()

	ThemeUtil.apply_theme(index)

	# short delay before reloading previous scene after theme change, brings big speed increase
	# no idea why...
	await get_tree().create_timer(0.05).timeout

	if not previous_scenes.is_empty():
		var scene: PackedScene = load(previous_scenes[-1])
		content.add_child(scene.instantiate())


func _append_scene_to_buffer(scene_path: String) -> void:
	previous_scenes.append(scene_path)
	if previous_scenes.size() > 5:
		previous_scenes.remove_at(0)


func _clear_content() -> void:
	for child: Node in content.get_children():
		content.remove_child(child)
		child.queue_free()


# prevents children from processing input while loading screen is visible
func _toggle_input(toggle: bool) -> void:
	var children_process_mode: Node.ProcessMode

	if toggle:
		children_process_mode = Node.PROCESS_MODE_INHERIT
	else:
		children_process_mode = Node.PROCESS_MODE_DISABLED

	for child: Node in content.get_children():
		child.process_mode = children_process_mode

