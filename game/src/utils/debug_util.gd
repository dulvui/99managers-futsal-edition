# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node


# set flags to control debug logs and visuals
var visual_state_machine: bool
var match_engine: bool
var penalties_test: bool


func _ready() -> void:
	visual_state_machine = true
	match_engine = true
	penalties_test = false
	
	# always reset flags, if not open in editor
	if not OS.has_feature("editor"):
		visual_state_machine = false
		match_engine = false
