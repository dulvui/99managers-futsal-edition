# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualEmailMessageList
extends VBoxContainer

signal show_message(message: EmailMessage)

const MessageRowScene: PackedScene = preload(
	"res://src/ui_components/email/list/message_row/message_row.tscn"
)

var search_text: String
var only_starred: bool
var only_unread: bool

@onready var list: VBoxContainer = %List


func _ready() -> void:
	search_text = ""
	only_starred = false
	only_unread = false


func update() -> void:
	for child in list.get_children():
		child.queue_free()

	var inbox_list: Array[EmailMessage] = Global.inbox.list

	if only_starred:
		inbox_list = inbox_list.filter(func(m: EmailMessage) -> bool: return m.starred)
	if only_unread:
		inbox_list = inbox_list.filter(func(m: EmailMessage) -> bool: return not m.read)
	if not search_text.is_empty():
		inbox_list = inbox_list.filter(
			func(m: EmailMessage) -> bool: return (
				(m.text.to_lower() + m.subject.to_lower() + m.sender.to_lower())
				. contains(search_text.to_lower())
			)
		)

	if inbox_list.is_empty():
		var label: Label = Label.new()
		label.text = tr("No message found")
		list.add_child(label)
	else:
		# to test perfomrance of email view
		#for j in range(1000):
		for i in range(inbox_list.size() - 1, -1, -1):  # reverse list
			var message: EmailMessage = inbox_list[i]
			var row: MessageRow = MessageRowScene.instantiate()
			list.add_child(row)
			row.read_button.pressed.connect(_on_row_pressed.bind(message))
			row.setup(message, i)


func starred(p_only_starred: bool) -> void:
	only_starred = p_only_starred
	update()


func unread(p_only_unread: bool) -> void:
	only_unread = p_only_unread
	update()


func search(text: String) -> void:
	search_text = text
	update()


func _on_row_pressed(message: EmailMessage) -> void:
	show_message.emit(message)
