# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

# set flags to control debug logs and visuals
extends Node


var visual_state_machine: bool
var match_engine: bool


func _ready() -> void:
	visual_state_machine = true
	match_engine = true
	
	if not OS.has_feature("editor"):
		visual_state_machine = false
		match_engine = false
