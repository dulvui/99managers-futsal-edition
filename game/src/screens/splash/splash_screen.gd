# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SplashScreen
extends Control


@onready var scene_fade: SceneFade = %SceneFade


func _ready() -> void:
	await get_tree().create_timer(1).timeout

	await scene_fade.fade_in()

	if Global.config.language:
		Main.change_scene(Const.SCREEN_MENU)
	else:
		Main.change_scene(Const.SCREEN_SETUP_LANGUAGE)

	queue_free()
