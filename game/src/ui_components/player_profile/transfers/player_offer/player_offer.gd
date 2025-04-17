# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerOffer
extends VBoxContainer

signal confirm

var team: Team
var player: Player

var numbers_regex: RegEx = RegEx.new()
var oldtext: String

var transfer_cost: int
var type: Transfer.Type

@onready var description: Label = %Description
@onready var date: SwitchOptionButton = %TransferDate
@onready var amount_edit: LineEdit = %Amount


func _ready() -> void:
	oldtext = ""
	transfer_cost = 0
	type = Transfer.Type.BUY

	team = Global.team
	numbers_regex.compile("^[0-9]*$")

	amount_edit.text = str(transfer_cost)
	date.setup(Enum.transfer_timings)



func setup(p_player: Player) -> void:
	player = p_player

	var transfer: Transfer = Global.transfers.get_by_player_id(player.id)
	if transfer != null:
		if transfer.type == Transfer.Type.LOAN:
			hide()
		description.text = tr("Your offer was sent.")
		amount_edit.text = str(transfer.cost)
		date.disabled = true
		date.option_button.selected = transfer.timing

		return

	if player.value <= Global.team.finances.balance[-1]:
		transfer_cost = player.value
	else:
		transfer_cost = Global.team.finances.balance[-1]

	amount_edit.text = str(transfer_cost)


func _on_more_pressed() -> void:
	if transfer_cost < team.finances.balance[-1]:
		transfer_cost += 1000
		amount_edit.text = FormatUtil.currency(transfer_cost)


func _on_less_pressed() -> void:
	if transfer_cost > 0:
		transfer_cost -= 1000
		amount_edit.text = FormatUtil.currency(transfer_cost)


func _on_amount_text_changed(new_text: String) -> void:
	if numbers_regex.search(new_text):
		oldtext = amount_edit.text
	else:
		amount_edit.text = oldtext

	transfer_cost = int(amount_edit.text)
	if transfer_cost > team.finances.balance[-1]:
		transfer_cost = team.finances.balance[-1]
		amount_edit.text = str(transfer_cost)


func _on_default_tab_container_tab_changed(tab: int) -> void:
	type = tab as Transfer.Type


func _on_confirm_pressed() -> void:
	var transfer: Transfer = Transfer.new()
	transfer.type = Transfer.Type.BUY
	transfer.player_id = player.id
	transfer.cost = transfer_cost
	transfer.delay_days = (randi() % 5) + 1
	transfer.state = Transfer.State.OFFER
	transfer.offer_team = Global.team
	transfer.team = Global.world.get_team_by_id(player.team_id, player.league_id)

	TransferUtil.make_offer(transfer)
	confirm.emit()

