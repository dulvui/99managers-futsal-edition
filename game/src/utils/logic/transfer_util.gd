# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node


func update_day() -> void:
	#check with calendar if treansfer market is open, then send start/stop mail
	if Global.world.calendar.is_market_active():

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


func make_transfer(transfer: Transfer) -> void:
	var old_team: Team = Global.world.get_team_by_id(transfer.team.id, transfer.team.league_id)
	var new_team: Team = Global.world.get_team_by_id(transfer.offer_team.id, transfer.offer_team.league_id)
	var player: Player = old_team.get_player_by_id(transfer.player_id)

	old_team.remove_player(player)
	new_team.players.append(player)
	player.team = new_team.name
	player.league_id = new_team.league_id


func check_contracts(_team: Team = Global.team) -> void:
	# check contracts of players and act for terminating contracts
	# check if team wants to renew: compare prestiges and consider age and value
	# let player go if contract doesn't get renewed => add to free agents
	pass


func analyze_team_needs(_team: Team = Global.team) -> void:
	# team gets analized an results in following factors
	# depending on the factors the team decides on how to use the budget
	# var young_factor: int = 0
	# var goalkeeper_factor: int = 0
	# var defense_factor: int = 0
	# var center_factor: int = 0
	# var attack_factor: int = 0

	pass


