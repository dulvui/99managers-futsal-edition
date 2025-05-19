# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Player
extends Person

@export var value: int
@export var nr: int
@export var loyality: int
@export var injury_factor: int
# for easier filtering
@export var league: String
@export var league_id: int
@export var team: String
@export var team_id: int
@export var foot_left: int
@export var foot_right: int
@export var position: Position
@export var contract: PlayerContract
@export var attributes: Attributes

# internal data
@export var form: Enum.Form
@export var stamina: float
@export var morality: Enum.Morality
@export var statistics: Statistics
@export var agent: Agent

# history data
@export var history: Array[History]


func _init(
	p_value: int = 0,
	p_nr: int = 0,
	p_loyality: int = 0,
	p_injury_factor: int = 0,
	p_stamina: float = 0,
	p_name: String = "",
	p_league: String = "",
	p_league_id: int = 0,
	p_team: String = "",
	p_team_id: int = 0,
	p_surname: String = "",
	p_nation: String = "",
	p_birth_date: Dictionary = {},
	p_form: Enum.Form = Enum.Form.GOOD,
	p_morality: Enum.Morality = Enum.Morality.NEUTRAL,
	p_statistics: Statistics = Statistics.new(),
	p_history: Array[History] = [],
	p_foot_left: int = 0,
	p_foot_right: int = 0,
	p_position: Position = Position.new(),
	p_contract: PlayerContract = PlayerContract.new(),
	p_attributes: Attributes = Attributes.new(),
	p_agent: Agent = Agent.new(),
) -> void:
	super(Person.Role.PLAYER)
	value = p_value
	nr = p_nr
	loyality = p_loyality
	injury_factor = p_injury_factor
	stamina = p_stamina
	name = p_name
	league = p_league
	league_id = p_league_id
	team = p_team
	team_id = p_team_id
	surname = p_surname
	nation = p_nation
	birth_date = p_birth_date
	form = p_form
	morality = p_morality
	statistics = p_statistics
	history = p_history
	foot_left = p_foot_left
	foot_right = p_foot_right
	position = p_position
	contract = p_contract
	attributes = p_attributes
	agent = p_agent


func get_goalkeeper_attributes() -> int:
	return attributes.goalkeeper.sum()


func update_prestige() -> void:
	if position.main == Position.Type.G:
		prestige = attributes.goal_keeper_average()
	prestige = attributes.field_player_average()


func recover_stamina(factor: int = 1) -> void:
	stamina = minf(attributes.physical.resistance, stamina + (Const.STAMINA_FACTOR * factor))


func consume_stamina(speed: float) -> void:
	# consume stamina with calc 21 - [20,1]
	# best case Const.MAX_ATTRIBUTES * 1
	# worst case Const.MAX_ATTRIBUTES * 20
	var consumation: float = (
		Const.STAMINA_FACTOR * (Const.MAX_ATTRIBUTES + 1 - attributes.physical.resistance) * speed
	)
	# print("stamina: %d consumtion: %f"%[attributes.physical.resistance, consumation])
	stamina = maxf(0, stamina - consumation)


func position_match_factor(p_position: Position) -> float:
	return position.match_factor(p_position.main)

