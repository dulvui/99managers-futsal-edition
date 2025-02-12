# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SplashScreen
extends Control


func _ready() -> void:
	var generator: Generator = Generator.new()
	Global.world = generator.generate_world()

	if Global.language:
		Main.change_scene(Const.SCREEN_MENU)
	else:
		Main.change_scene(Const.SCREEN_SETUP_LANGUAGE)
	
	queue_free()
