# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SceneFade
extends Panel

const DURATION: float = 0.15
# use tiny delay to make sure fade is complete
const DELAY: float = 0.05


func _ready() -> void:
	modulate = Color.TRANSPARENT
	hide()


func fade_in(factor: float = 1.0) -> void:
	# hide scene fade immediate, if scenefade settings is disabled
	if not Global.config.scene_fade:
		hide()
		return

	# already visible
	if visible and modulate == Color.WHITE:
		return

	show()
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, DURATION * factor)
	await tween.finished

	await get_tree().create_timer(DELAY).timeout


func fade_out(factor: float = 1.0) -> void:
	# hide scene fade immediate, if scenefade settings is disabled
	if not Global.config.scene_fade:
		hide()
		return

	# already hidden
	if not visible and modulate == Color.TRANSPARENT:
		return

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, DURATION * factor)
	await tween.finished

	hide()

	await get_tree().create_timer(DELAY).timeout

