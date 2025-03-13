# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SceneFade
extends Panel

const DURATION: float = 0.2


func _ready() -> void:
	modulate = Color.TRANSPARENT
	hide()


func fade_in(duration: float = DURATION) -> void:
	if not Global.config.scene_fade:
		hide()
		return

	# already visible
	if visible:
		return

	show()
	var tween: Tween
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, duration)
	await tween.finished


func fade_out(duration: float = DURATION) -> void:
	if not Global.config.scene_fade:
		hide()
		return

	# already hidden
	if not visible:
		return

	var tween: Tween
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, duration)
	await tween.finished
	hide()
