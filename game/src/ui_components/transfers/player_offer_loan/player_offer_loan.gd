# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerOfferLoan
extends VBoxContainer

signal confirm

var team: Team
var player: Player

var numbers_regex: RegEx = RegEx.new()
var oldtext: String = ""

var amount: int = 0

@onready var amount_label: LineEdit = %Amount


func _ready() -> void:
	team = Global.team
	numbers_regex.compile("^[0-9]*$")
	amount_label.text = str(amount)


func set_player(new_player: Player) -> void:
	player = new_player

	if player.value <= Global.team.finances.balance[-1]:
		amount = player.value
	else:
		amount = Global.team.finances.balance[-1]

	amount_label.text = str(amount)


func _on_more_pressed() -> void:
	if amount < team.finances.balance[-1]:
		amount += 1000
		amount_label.text = FormatUtil.currency(amount)


func _on_less_pressed() -> void:
	if amount > 0:
		amount -= 1000
		amount_label.text = FormatUtil.currency(amount)


func _on_amount_text_changed(new_text: String) -> void:
	if numbers_regex.search(new_text):
		oldtext = amount_label.text
	else:
		amount_label.text = oldtext

	amount = int(amount_label.text)
	if amount > team.finances.balance[-1]:
		amount = team.finances.balance[-1]
		amount_label.text = str(amount)


func _on_confirm_pressed() -> void:
	var transfer: Transfer = Transfer.new()
	transfer.type = Transfer.Type.LOAN
	transfer.player_id = player.id
	transfer.cost = amount
	transfer.delay_days = (randi() % 5) + 1
	transfer.state = Transfer.State.OFFER
	transfer.offer_team = Global.team
	transfer.team = Global.world.get_team_by_id(player.team_id, player.league_id)

	TransferUtil.make_offer(transfer)
	confirm.emit()

