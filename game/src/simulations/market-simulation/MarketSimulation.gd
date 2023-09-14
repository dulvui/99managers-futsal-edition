# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node


func update():
	_check_players()
	if CalendarUtil.is_market_active():
		_request_players()

# checks if players should be sold 
func _check_players() -> void:
	pass


# finds player that fits team on their needs
# can be used as buy tip of osservatore for your team
func find_player() -> void:
	pass


func _request_players() -> void:
	if randi()% 100 < Constants.REQUEST_FACTOR:
		# pick random team, that needs a player
		# depending on presitge of team, buy cheap or expensive player
		# loans also possible
		# once market offer made, request preocess starts
		# decline, accept, counter offer
		# if accepted, player needs to aggre
		# can affect players mood, if he wants to leave and you don't let him go
		# or viceversa, then he would start with bad mood at other team
		# make sure no duplicate offers are made, and once a player is sold
		# he can't be sold twice and no offers for sold playersg
		EmailUtil.new_message(EmailUtil.MessageTypes.MARKET_OFFER)


# move make transfer method from Global to here
func make_transfer() -> void:
	pass
