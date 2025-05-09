# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerUtil
extends Node

const NOISE: int = 20
const AGE_PHYSICAL_DEGARDE: int = 30

var rng_util: RngUtil


func _init() -> void:
	rng_util = RngUtil.new()


func check_injuries() -> void:
	pass


func check_retiring_players() -> void:
	pass


func add_new_players() -> void:
	# for every retired player, add new players
	pass


func check_contracts_terminated() -> void:
	# check contracts of players and act for terminating contracts
	# check if team wants to renew: compare prestiges and consider age and value
	# let player go if contract doesn't get renewed => add to free agents
	var terminated_players: Array[Player]

	for team: Team in Global.world.get_all_teams():
		terminated_players = []
		for player: Player in team.players:
			if Global.calendar.days_difference(player.contract.end_date) < 0:
				terminated_players.append(player)

		# remove players with no contract and add to free agents
		for player: Player in terminated_players:
			team.remove_player(player)
			Global.world.free_agents.append(player)


func players_progress_season() -> void:
	for c: Continent in Global.world.continents:
		for n: Nation in c.nations:
			for league: League in n.leagues:
				for team: Team in league.teams:
					for player: Player in team.players:
						_player_season_progress(player)


func _player_season_progress(player: Player) -> void:
	# add random noise
	var prestige_factor: int = player.prestige + rng_util.randi_range(-NOISE, NOISE)
	# age factor only affects fisical attributes neagtively
	# high prestige player has smaller age factor, that means his physical attributes
	# dergade less and later
	var age: int = Global.start_date.year - player.birth_date.year

	# -1/+1 depending on player age and prestige
	var age_factor: int = AGE_PHYSICAL_DEGARDE - age + int(player.prestige / 12.0)
	if age_factor < 0:
		age_factor = -1
	else:
		age_factor = 1

	# check bounds prestige_factor
	if prestige_factor < 1:
		prestige_factor = 1
	if prestige_factor > Const.MAX_PRESTIGE:
		prestige_factor = Const.MAX_PRESTIGE

	# increment all atrtibutes from 0 to 3

	# mental
	for attribute: Dictionary in player.attributes.mental.get_property_list():
		if attribute.usage == Const.CUSTOM_PROPERTY_EXPORT:  # custom properties
			# random value from 0 to 300
			var value: int = (
				rng_util.randi_range(1, Const.MAX_PRESTIGE)
				+ rng_util.randi_range(1, prestige_factor)
				+ prestige_factor
			)
			value /= 100
			player.attributes.mental[attribute.name] = min(
				player.attributes.mental[attribute.name] + value, 20
			)

	# physical
	for attribute: Dictionary in player.attributes.physical.get_property_list():
		if attribute.usage == Const.CUSTOM_PROPERTY_EXPORT:  # custom properties
			var value: int = (
				rng_util.randi_range(1, Const.MAX_PRESTIGE)
				+ rng_util.randi_range(1, prestige_factor)
				+ prestige_factor
			)
			value /= 100 * age_factor
			player.attributes.physical[attribute.name] = min(
				player.attributes.physical[attribute.name] + value, 20
			)

	# technical
	for attribute: Dictionary in player.attributes.technical.get_property_list():
		if attribute.usage == Const.CUSTOM_PROPERTY_EXPORT:  # custom properties
			var value: int = (
				rng_util.randi_range(1, Const.MAX_PRESTIGE)
				+ rng_util.randi_range(1, prestige_factor)
				+ prestige_factor
			)
			value /= 100
			player.attributes.technical[attribute.name] = min(
				player.attributes.technical[attribute.name] + value, 20
			)

	#goalkeeper
	for attribute: Dictionary in player.attributes.goalkeeper.get_property_list():
		if attribute.usage == Const.CUSTOM_PROPERTY_EXPORT:  # custom properties
			var value: int = (
				rng_util.randi_range(1, Const.MAX_PRESTIGE)
				+ rng_util.randi_range(1, prestige_factor)
				+ prestige_factor
			)
			value /= 100 * age_factor
			player.attributes.goalkeeper[attribute.name] = min(
				player.attributes.goalkeeper[attribute.name] + value, 20
			)

