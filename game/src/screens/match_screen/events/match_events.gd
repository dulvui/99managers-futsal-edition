# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchEvents
extends MarginContainer

@onready var list: VBoxContainer = %List


func start(home_goals: int = 0, away_goals: int = 0) -> void:
	var label: Label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = "%d : %d" % [home_goals, away_goals]
	list.add_child(label)
	list.add_child(HSeparator.new())


func event(time: int, text: String) -> void:
	var label: Label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = "%s - %s" % [time, text]
	list.add_child(label)


func event_home(time: int, text: String) -> void:
	var label: Label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.text = "%s - %s" % [time, text]
	list.add_child(label)


func event_away(time: int, text: String) -> void:
	var label: Label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.text = "%s - %s" % [text, time]
	list.add_child(label)


func halftime(home_goals: int, away_goals: int) -> void:
	var label: Label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = "%d : %d" % [home_goals, away_goals]
	list.add_child(HSeparator.new())
	list.add_child(label)
	list.add_child(HSeparator.new())
