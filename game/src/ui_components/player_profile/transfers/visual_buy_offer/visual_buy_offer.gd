# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualBuyOffer
extends VBoxContainer

signal confirm

var team: Team
var player: Player

# buy
@onready var buy_description: Label = %BuyDescription
@onready var buy_date: SwitchOptionButton = %BuyDate
@onready var buy_money: MoneyEdit = %BuyMoney

# loan
@onready var loan_description: Label = %LoanDescription
@onready var loan_duration: SwitchOptionButton = %LoanDuration
@onready var loan_money: MoneyEdit = %LoanMoney


func _ready() -> void:

	team = Global.team

	buy_date.setup(Enum.offer_timings)

	# loan_date.setup()


func setup(p_player: Player) -> void:
	player = p_player

	# var transfer: Offer = Global.offer_list.get_by_player_id(player.id)
	# if transfer != null:
	# 	if transfer.type == Transfer.Type.LOAN:
	# 		hide()
	# 	buy_money.setup(transfer.cost, 0, team.finances.balance[-1])
	# 	buy_description.text = tr("Your offer was sent.")
	# 	buy_date.disabled = true
	# 	buy_date.option_button.selected = transfer.timing
	#
	# 	return
	#
	buy_money.setup(player.value, 0, team.finances.balance[-1])


func _on_default_tab_container_tab_changed(tab: int) -> void:
	print(tab)


func _on_confirm_pressed() -> void:
	# var transfer: Transfer = Transfer.new()
	# transfer.type = Transfer.Type.BUY
	# transfer.player_id = player.id
	# transfer.cost = buy_money.amount
	# transfer.delay_days = (randi() % 5) + 1
	# transfer.state = Transfer.State.OFFER
	# transfer.offer_team = Global.team
	# transfer.team = Global.world.get_team_by_id(player.team_id, player.league_id)
	#
	# TransferUtil.make_offer(transfer)
	confirm.emit()

