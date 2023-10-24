# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control
class_name PlayerRow

signal info(player:Player)
signal select(player:Player)

const ColorNumber = preload("res://src/ui-components/color-number/color_number.tscn")

@onready var name_label:Control = $NameLabel
@onready var attributes:HBoxContainer = $Attributes


var player:Player

func set_up(_player:Player, active_headers:Array[String]) -> void:
	for child in attributes.get_children():
		child.queue_free()
	
	player = _player
	
	name_label.set_text(player.surname)
	for key in Constants.ATTRIBUTES.keys():
		for attribute in Constants.ATTRIBUTES[key]:
			var color_number:ColorNumber = ColorNumber.instantiate()
			color_number.key = attribute
			color_number.set_up(player.attributes.get(key).get(attribute))
			color_number.visible = attribute in active_headers
			attributes.add_child(color_number)

func _on_select_pressed():
	select.emit(player)

func _on_info_pressed():
	info.emit(player)