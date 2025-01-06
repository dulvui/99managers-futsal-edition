# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

# meta-default: true
extends _BASE_


func _ready() -> void:
	Tests.setup_mock_world(true)


func _process(delta: float) -> void:
	pass
