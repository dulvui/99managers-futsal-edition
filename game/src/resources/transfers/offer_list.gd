# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name OfferList
extends Resource

# lists of active offers
var buy_list: Array[BuyOffer]
var loan_list: Array[LoanOffer]
var contract_list: Array[ContractOffer]

# lists of players that are available for transfer or loan
var player_buy_list: Array[int]
var player_loan_list: Array[int]


func _init(
	p_buy_list: Array[BuyOffer] = [],
	p_loan_list: Array[LoanOffer] = [],
	p_contract_list: Array[ContractOffer] = [],
	p_player_buy_list: Array[int] = [],
	p_player_loan_list: Array[int] = [],
) -> void:
	buy_list = p_buy_list
	loan_list = p_loan_list
	contract_list = p_contract_list
	player_buy_list	= p_player_buy_list
	player_loan_list	= p_player_loan_list


func get_offer_by_player_id(player_id: int) -> Offer:
	for offer: Offer in buy_list + loan_list + contract_list:
		if offer.player_id == player_id:
			return offer
	return null


func update_day() -> void:
	# check with calendar if transfer market is open, then send start/stop mail
	for buy_offer: BuyOffer in buy_list:
		buy_offer.update()

	for contract_offer: ContractOffer in contract_list:
		contract_offer.update()

	for loan_offer: LoanOffer in loan_list:
		loan_offer.update()

	# cancel all remaining buy offers, that should have happened during this transfer window
	# send market closed email
	return


func new_buy_offer(offer: BuyOffer) -> void:
	offer.set_id()
	buy_list.append(offer)
	# Global.inbox.offer_message(offer)


func new_loan_offer(offer: LoanOffer) -> void:
	offer.set_id()
	loan_list.append(offer)
	# Global.inbox.offer_message(offer)


func new_contract_offer(offer: ContractOffer) -> void:
	offer.set_id()
	contract_list.append(offer)
	# Global.inbox.offer_message(offer)


# func make_transfer(offer: Buy) -> void:
# 	var old_team: Team = Global.world.get_team_by_id(transfer.team.id, transfer.team.league_id)
# 	var new_team: Team = Global.world.get_team_by_id(transfer.offer_team.id, transfer.offer_team.league_id)
# 	var player: Player = old_team.get_player_by_id(transfer.player_id)
#
# 	old_team.remove_player(player)
# 	new_team.players.append(player)
# 	player.team = new_team.name
# 	player.league_id = new_team.league_id


func analyze_team_needs(_team: Team = Global.team) -> void:
	# team gets analized an results in following factors
	# depending on the factors the team decides on how to use the budget
	# var young_factor: int = 0
	# var goalkeeper_factor: int = 0
	# var defense_factor: int = 0
	# var center_factor: int = 0
	# var attack_factor: int = 0

	pass


