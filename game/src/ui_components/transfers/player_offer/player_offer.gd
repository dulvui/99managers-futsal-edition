# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerOffer
extends PanelContainer

signal confirm
signal cancel

var team: Team
var player: Player

var regex: RegEx = RegEx.new()
var oldtext: String = ""

var total: int = 0
var amount: int = 0

var exchange_players: Array[Player] = []
var selected_players: Array[Player] = []

@onready var types: OptionButton = $VBoxContainer/Details/Types
@onready var amount_label: LineEdit = $VBoxContainer/Details/Money/Amount
@onready var total_label: Label = $VBoxContainer/Total
@onready var exchange_players_button: OptionButton = $VBoxContainer/Details/ExchangePlayers
@onready var selected_players_box: VBoxContainer = $VBoxContainer/ScrollContainer/SelectedPlayers


func _ready() -> void:
	regex.compile("^[0-9]*$")
	types.add_item("Transfer")
	types.add_item("Loan")

	amount_label.text = str(amount)

	team = Global.team
	for t_player: Player in team.players:
		exchange_players_button.add_item(t_player.name + " " + str(int(t_player.value / 1000.0)) + "K")
		exchange_players.append(t_player)


func _process(_delta: float) -> void:
	total_label.text = str(total)


func set_player(new_player: Player) -> void:
	player = new_player

	if player.value <= Global.team.finances.balance[-1]:
		amount = player.value
	else:
		amount = Global.team.finances.balance[-1]

	total = amount
	amount_label.text = str(amount)


func _on_more_pressed() -> void:
	if amount < team.finances.balance[-1]:
		amount += 1000
		amount_label.text = str(amount)

	_calc_total()


func _on_less_pressed() -> void:
	if amount > 0:
		amount -= 1000
		amount_label.text = str(amount)

	_calc_total()


func _on_exchange_players_item_selected(index: int) -> void:
	var exchange_player: Player = exchange_players[index]
	exchange_players.remove_at(index)

	selected_players.append(player)

	var remove_button: Button = DefaultButton.new()
	remove_button.text = exchange_player.name + " " + str(int(exchange_player.value / 1000.0)) + "K"
	remove_button.pressed.connect(remove_from_list.bind(exchange_player))
	selected_players_box.add_child(remove_button)

	exchange_players_button.remove_item(index)

	_calc_total()


func remove_from_list(p_player: Player) -> void:
	for child: Node in selected_players_box.get_children():
		child.queue_free()
	selected_players.erase(p_player)
	exchange_players.append(p_player)

	# might be corrupt after Godot 4 upgrade, check _player and selected player
	# before only _player existed
	for selected_player: Player in selected_players:
		var remove_button: Button = DefaultButton.new()
		remove_button.text = selected_player.name + " " + str(int(selected_player.value / 1000.0)) + "K"
		remove_button.pressed.connect(remove_from_list.bind(selected_player))
		selected_players_box.add_child(remove_button)

	exchange_players_button.add_item(player.name)
	_calc_total()


func _calc_total() -> void:
	total = amount
	for selected_player: Player in selected_players:
		# use other calculated value to estimate importance for new team
		total += selected_player.value


func _on_amount_text_changed(new_text: String) -> void:
	if regex.search(new_text):
		oldtext = amount_label.text
	else:
		amount_label.text = oldtext

	amount = int(amount_label.text)
	if amount > team.finances.balance[-1]:
		amount = team.finances.balance[-1]
		amount_label.text = str(amount)

	_calc_total()


func _on_cancel_pressed() -> void:
	cancel.emit()


func _on_confirm_pressed() -> void:
	var transfer: Transfer = Transfer.new()
	transfer.player = player
	transfer.cost = amount
	transfer.exchange_players = selected_players
	transfer.delay_days = (randi() % 5) + 1
	transfer.state = Transfer.State.OFFER
	transfer.buy_team = Global.team
	transfer.sell_team = Global.world.get_team_by_id(player.team_id)

	TransferUtil.make_offer(transfer)
	confirm.emit()
