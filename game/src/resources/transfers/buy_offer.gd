# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name BuyOffer
extends Offer

var amount: int
var current_team: TeamBasic


func _init(
	p_current_team: TeamBasic = TeamBasic.new(),
	p_amount: int = 0,
) -> void:
	current_team = p_current_team
	amount = p_amount

