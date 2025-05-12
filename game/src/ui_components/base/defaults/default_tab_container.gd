# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultTabContainer
extends TabContainer


var active_tab: int
var tab_count: int


func _ready() -> void:
	tab_clicked.connect(_tab_clicked)

	var prev: Control = Control.new()
	prev.name = "<"
	add_child(prev)
	move_child(prev, 0)

	var next: Control = Control.new()
	next.name = ">"
	add_child(next)

	current_tab = 1
	active_tab = 1
	tab_count = get_tab_count()


func _tab_clicked(tab: int) -> void:
	SoundUtil.play_button_sfx()

	# prev pressed
	if tab == 0:
		active_tab -= 1
	# next pressed
	elif tab == tab_count - 1:
		active_tab += 1
	else:
		active_tab = tab

	# check bounds and wrap around
	if active_tab < 1:
		active_tab = tab_count - 2
	if active_tab > tab_count - 2:
		active_tab = 1

	current_tab = active_tab

