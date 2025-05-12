# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SplashScreen
extends Control

const FADE_DURATION: float = 0.4
const ICON_DURATION: float = 1

@onready var fade: ColorRect = %Fade


func _ready() -> void:
	# start with black
	fade.color = Color.BLACK

	await fade_out()
	# set to themes background color
	fade.color = ThemeUtil.configuration.background_color
	# show icon
	await get_tree().create_timer(ICON_DURATION).timeout
	await fade_in()

	if Global.config.language:
		Main.change_scene(Const.SCREEN_MENU)
	else:
		Main.change_scene(Const.SCREEN_SETUP_INITIAL)

	queue_free()


func fade_in() -> void:
	var tween: Tween
	tween = create_tween()
	# fade to current themes background color
	tween.tween_property(fade, "modulate", Color.WHITE, FADE_DURATION)
	await tween.finished


func fade_out() -> void:
	var tween: Tween
	tween = create_tween()
	tween.tween_property(fade, "modulate", Color.TRANSPARENT, FADE_DURATION)
	await tween.finished
