# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SplashScreen
extends Control

const FADE_DURATION: float = 0.8
const ICON_DURATION: float = 1.2

@onready var fade: ColorRect = %Fade


func _ready() -> void:
	# start with black
	fade.color = Color.BLACK

	await fade_out()
	# set to white, so it can be faded to themes background later
	fade.color = Color.WHITE
	# show icon
	await get_tree().create_timer(ICON_DURATION).timeout
	await fade_in()

	if Global.config.language:
		Main.change_scene(Const.SCREEN_MENU)
	else:
		Main.change_scene(Const.SCREEN_SETUP_LANGUAGE)

	queue_free()


func fade_in() -> void:
	var tween: Tween
	tween = create_tween()
	# fade to current themes background color
	tween.tween_property(fade, "modulate", ThemeUtil.configuration.background_color, FADE_DURATION)
	await tween.finished


func fade_out() -> void:
	var tween: Tween
	tween = create_tween()
	tween.tween_property(fade, "modulate", Color.TRANSPARENT, FADE_DURATION)
	await tween.finished
