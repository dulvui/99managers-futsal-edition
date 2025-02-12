# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualEmailMessage
extends Control

signal email_action(message: EmailMessage)

var message: EmailMessage

@onready var subject: Label = %Subject
@onready var sender: Label = %Sender
@onready var receiver: Label = %Receiver
@onready var date: Label = %Date
@onready var text: RichTextLabel = %Message
@onready var action_button: Button = %Action


func show_message(p_message: EmailMessage) -> void:
	if p_message == null:
		return
	message = p_message
	message.read = true
	subject.text = message.subject
	sender.text = message.sender
	receiver.set_text(message.receiver)
	date.text = message.date
	text.text = message.text

	if message.type == EmailMessage.Type.CONTRACT_OFFER:
		action_button.show()
		action_button.text = "Offer contract"
	else:
		action_button.hide()


func _on_action_pressed() -> void:
	email_action.emit(message)


func _on_message_meta_clicked(meta: Variant) -> void:
	print(meta)
	var meta_string: String = str(meta)
	# assume that players are insted as p + id; example p456546
	if "p" in meta_string:
		var player_id: String = meta_string.substr(1)
		print(player_id)
		# var player: Player = Global.world.find
		# LinkUtil.player_link.emit(player_id)
		SoundUtil.play_button_sfx()
		return
	# and teams as t + id
	if "t" in meta_string:
		var team_id: int = int(meta_string.substr(1))
		LinkUtil.link_team_id(team_id)
		return

