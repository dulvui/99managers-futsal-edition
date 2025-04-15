# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

const REQUEST_FACTOR: int = 20


func update_day() -> void:
	#check with calendar if treansfer market is open, then send start/stop mail
	if Global.world.calendar.is_market_active():
		_request_players()

		# do transfers
		for transfer: Transfer in Global.transfers.list:
			if transfer.update():
				# TODO once other teams can make trades between themselfes, only send email
				# for transfers affectiing own team
				# otehrwhise send a news id if important, or simply add to market history
				EmailUtil.transfer_message(transfer)

				if transfer.state == Transfer.State.SUCCESS:
					make_transfer(transfer)
	else:
		print("TODO cancel all remaining transfers and send market clossed email")


func make_offer(transfer: Transfer) -> void:
	transfer.set_id()
	EmailUtil.transfer_message(transfer)
	Global.transfers.list.append(transfer)


func get_transfer_id(id: int) -> Transfer:
	for transfer: Transfer in Global.transfers.list:
		if transfer.id == id:
			return transfer
	push_error("error transfer not found with id: " + str(id))
	return null


func _request_players() -> void:
	if randi_range(1, REQUEST_FACTOR) == REQUEST_FACTOR:
		# TODO
		# pick random team, that needs a player
		# depending on presige of team, buy cheap or expensive player
		# loans also possible
		# once market offer made, request preocess starts
		# decline, accept, counter offer
		# if accepted, player needs to aggre
		# can affect players mood, if he wants to leave and you don't let him go
		# or viceversa, then he would start with bad mood at other team
		# make sure no duplicate offers are made, and once a player is sold
		# he can't be sold twice and no offers for sold playersg
		#EmailUtil.transfer_message()
		print("TODO create random player requests")


func make_transfer(transfer: Transfer) -> void:
	var old_team: Team = Global.world.get_team_by_id(transfer.team.id, transfer.team.league_id)
	var new_team: Team = Global.world.get_team_by_id(transfer.offer_team.id, transfer.offer_team.league_id)
	var player: Player = old_team.get_player_by_id(transfer.player_id)

	old_team.remove_player(player)
	new_team.players.append(player)
	player.team = new_team.name
	player.league_id = new_team.league_id

