# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ContractOffer
extends Offer

@export var contract: PlayerContract


func _init(
	p_contract: PlayerContract = PlayerContract.new(),
) -> void:
	contract = p_contract

