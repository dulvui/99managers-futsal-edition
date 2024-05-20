# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualEmailMessageList
extends Control

signal show_message(message:EmailMessage)

const MessageRowScene: PackedScene = preload("res://src/ui_components/email/list/message_row/message_row.tscn")

@onready var list: VBoxContainer = $ScrollContainer/List

func update() -> void:
	for child in list.get_children():
		child.queue_free()
	
	for i in range(Config.inbox.list.size()-1,-1,-1): # reverse list
		var row:MessageRow = MessageRowScene.instantiate()
		list.add_child(row)
		row.click.connect(_on_row_click.bind(Config.inbox.list[i]))
		row.set_up(Config.inbox.list[i])
		
		if i > 0:
			list.add_child(HSeparator.new())

func _on_row_click(message:EmailMessage) -> void:
	show_message.emit(message)
