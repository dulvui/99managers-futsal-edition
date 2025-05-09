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


func fade_in(duration: float = DURATION) -> void:
	# hide scene fade immediatly, if scenefade settings is disabled
	if not Global.config.scene_fade:
		hide()
		return

	# already visible
	if visible:
		return

	show()
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, duration)
	await tween.finished

	await get_tree().create_timer(DELAY).timeout


func fade_out(duration: float = DURATION) -> void:
	# hide scene fade immediatly, if scenefade settings is disabled
	if not Global.config.scene_fade:
		hide()
		return

	# already hidden
	if not visible:
		return

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, duration)
	await tween.finished

	await get_tree().create_timer(DELAY).timeout

	hide()

