# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultTabContainer
extends TabContainer


func _ready() -> void:
	tab_clicked.connect(_tab_clicked)


func _tab_clicked(_tab: int) -> void:
	SoundUtil.play_button_sfx()
