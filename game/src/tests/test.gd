# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Test
extends Node


func _ready() -> void:
	if get_tree().get_root() == get_parent():
		print("Start test suite")
		test()
		print("Stop test suite")
		get_tree().quit()


func test() -> void:
	pass

