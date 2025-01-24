# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerProgress
extends Node

const NOISE: int = 20
const AGE_PHYSICAL_DEGARDE: int = 30


static func players_progress_season() -> void:
	for c: Continent in Global.world.continents:
		for n: Nation in c.nations:
			for league: League in n.leagues:
				for team: Team in league.teams:
					for player: Player in team.players:
						_player_season_progress(player)


static func _player_season_progress(player: Player) -> void:
	# add random noise
	var prestige_factor: int = player.prestige + RngUtil.rng.randi_range(-NOISE, NOISE)
	# age factor only affects fisical attributes neagtively
	# high prestige player has smaller age factor, that means his physical attributes
	# dergade less and later
	var age: int = Global.start_date.year - player.birth_date.year

	# -1/+1 depending on player age and prestige
	var age_factor: int = AGE_PHYSICAL_DEGARDE - age + (player.prestige / 12)
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
				RngUtil.rng.randi_range(1, Const.MAX_PRESTIGE)
				+ RngUtil.rng.randi_range(1, prestige_factor)
				+ prestige_factor
			)
			value /= 100
			player.attributes.mental[attribute.name] = min(
				player.attributes.mental[attribute.name] + value, 20
			)

	# physical
	for attribute: Dictionary in player.attributes.physical.get_property_list():
		if attribute.usage == Const.CUSTOM_PROPERTY_EXPORT:  # custoom properties
			var value: int = (
				RngUtil.rng.randi_range(1, Const.MAX_PRESTIGE)
				+ RngUtil.rng.randi_range(1, prestige_factor)
				+ prestige_factor
			)
			value /= 100 * age_factor
			player.attributes.physical[attribute.name] = min(
				player.attributes.physical[attribute.name] + value, 20
			)

	# technical
	for attribute: Dictionary in player.attributes.technical.get_property_list():
		if attribute.usage == Const.CUSTOM_PROPERTY_EXPORT:  # custoom properties
			var value: int = (
				RngUtil.rng.randi_range(1, Const.MAX_PRESTIGE)
				+ RngUtil.rng.randi_range(1, prestige_factor)
				+ prestige_factor
			)
			value /= 100
			player.attributes.technical[attribute.name] = min(
				player.attributes.technical[attribute.name] + value, 20
			)

	#goalkeeper
	for attribute: Dictionary in player.attributes.goalkeeper.get_property_list():
		if attribute.usage == Const.CUSTOM_PROPERTY_EXPORT:  # custoom properties
			var value: int = (
				RngUtil.rng.randi_range(1, Const.MAX_PRESTIGE)
				+ RngUtil.rng.randi_range(1, prestige_factor)
				+ prestige_factor
			)
			value /= 100 * age_factor
			player.attributes.goalkeeper[attribute.name] = min(
				player.attributes.goalkeeper[attribute.name] + value, 20
			)
