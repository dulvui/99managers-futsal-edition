# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ContractOffer
extends Offer

# buy offer made to a player
# can happen after team accepts a buy offer
# or if player has expiring contract
# or if player has no contract and is a free agent

const MIN_DURATION: int = 1
const MAX_DURATION: int = 5

var contract: PlayerContract
var sign_bonus: int
var duration: int


func _init(
	p_contract: PlayerContract = PlayerContract.new(),
	p_sign_bouns: int = 0,
	p_duration: int = 0,
) -> void:
	contract = p_contract
	sign_bonus = p_sign_bouns
	duration = p_duration

