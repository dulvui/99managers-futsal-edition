# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualInfo
extends VBoxContainer

@onready var generation_seed: Label = $GenerationSeed/GenerationSeed
@onready var start_date: Label = $StartDate/StartDate


func _ready() -> void:
	generation_seed.text = Global.generation_seed
	start_date.text = FormatUtil.day(Global.start_date)


func _on_copy_seed_pressed() -> void:
	DisplayServer.clipboard_set(Global.generation_seed)
