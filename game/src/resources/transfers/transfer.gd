# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Transfer
extends JSONResource

enum Type {
	BUY,
	LOAN,
}

enum State {
	OFFER,
	OFFER_DECLINED,
	CONTRACT,
	CONTRACT_PENDING,
	SUCCESS,
	CONTRACT_DECLINED,
}


@export var id: int
@export var player: Player
@export var state: State
@export var type: Type
@export var buy_team: Team
@export var sell_team: Team
@export var cost: int
@export var contract: Contract
@export var delay_days: int
@export var exchange_players: Array[Player]
@export var date: Dictionary


func _init(
	p_id: int = IdUtil.next_id(IdUtil.Types.TRANSFER),
	p_player: Player = Player.new(),
	p_state: State = State.OFFER,
	p_type: Type = Type.BUY,
	p_buy_team: Team = Team.new(),
	p_sell_team: Team = Team.new(),
	p_contract: Contract = Contract.new(),
	p_cost: int = 0,
	p_delay_days: int = 0,
	p_exchange_players: Array[Player] = [],
	p_date: Dictionary = {},
) -> void:
	id = p_id
	player = p_player
	state = p_state
	type = p_type
	buy_team = p_buy_team
	sell_team = p_sell_team
	contract = p_contract
	cost = p_cost
	delay_days = p_delay_days
	exchange_players = p_exchange_players
	date = p_date


func update() -> bool:
	# wait for user to make offer/contract
	if state == State.CONTRACT:
		return false
	# reduce delay
	delay_days -= 1
	if delay_days == 0:
		delay_days = randi_range(1, 7)
		_update_state()
		return true
	return false


func accept_offer() -> void:
	state = State.CONTRACT


func _update_state() -> void:
	match state:
		State.OFFER:
			# TODO use real values like prestige etc...
			var success: bool = randi() % 2 == 0
			if success:
				state = State.CONTRACT
			else:
				var fail: bool = randi() % 2 == 0
				if fail:
					state = State.OFFER_DECLINED
				else:
					state = State.OFFER
		State.CONTRACT_PENDING:
			var success: bool = randi() % 2 == 0
			if success:
				state = State.SUCCESS
			else:
				var fail: bool = randi() % 2 == 0
				if fail:
					state = State.CONTRACT_DECLINED
				else:
					state = State.CONTRACT


