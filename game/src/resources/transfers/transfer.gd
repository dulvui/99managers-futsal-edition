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
@export var player_id: int
@export var player_name: String
@export var team: TeamBasic
@export var offer_team: TeamBasic
@export var state: State
@export var type: Type
@export var cost: int
@export var contract: Contract
@export var delay_days: int
# not used for now for simplicity, might be re-introduced later
@export var exchange_players: Array[int]
@export var date: Dictionary


func _init(
	p_id: int = -1,
	p_player_id: int = -1,
	p_player_name: String = "",
	p_team: TeamBasic = TeamBasic.new(),
	p_offer_team: TeamBasic = TeamBasic.new(),
	p_state: State = State.OFFER,
	p_type: Type = Type.BUY,
	p_contract: Contract = Contract.new(),
	p_cost: int = 0,
	p_delay_days: int = 0,
	p_exchange_players: Array[int] = [],
	p_date: Dictionary = {},
) -> void:
	id = p_id
	player_id = p_player_id
	player_name = p_player_name
	team = p_team
	offer_team = p_offer_team
	state = p_state
	type = p_type
	contract = p_contract
	cost = p_cost
	delay_days = p_delay_days
	exchange_players = p_exchange_players
	date = p_date


func set_id() -> void:
	id = IdUtil.next_id(IdUtil.Types.TRANSFER)


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

