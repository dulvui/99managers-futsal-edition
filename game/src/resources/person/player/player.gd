# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Player
extends Person

@export var value: int
@export var nr: int  # shirt number
@export var loyality: int
@export var injury_factor: int
@export var stamina: float
# for easier filtering
@export var league: String
@export var league_id: int
@export var team: String
@export var team_id: int
@export var form: Enum.Form
@export var morality: Enum.Morality
@export var statistics: Statistics
@export var history: Array[History]
@export var foot: Enum.Foot
@export var position: Position
@export var alt_positions: Array[Position]
@export var attributes: Attributes
@export var agent: Agent


func _init(
	p_value: int = 0,
	p_nr: int = 0,
	p_loyality: int = 0,
	p_prestige: int = 0,
	p_injury_factor: int = 0,
	p_stamina: float = 1,
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
	p_foot: Enum.Foot = Enum.Foot.RIGHT,
	p_position: Position = Position.new(),
	p_alt_positions: Array[Position] = [],
	p_contract: Contract = Contract.new(),
	p_attributes: Attributes = Attributes.new(),
	p_agent: Agent = Agent.new(),
) -> void:
	super(Person.Role.PLAYER)
	value = p_value
	nr = p_nr
	loyality = p_loyality
	prestige = p_prestige
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
	foot = p_foot
	position = p_position
	alt_positions = p_alt_positions
	contract = p_contract
	attributes = p_attributes
	agent = p_agent


func get_goalkeeper_attributes() -> int:
	return attributes.goalkeeper.sum()


func get_overall() -> float:
	if position.type == Position.Type.G:
		return attributes.goal_keeper_average()
	return attributes.field_player_average()


func get_prestige_stars() -> String:
	var relation: float = Const.MAX_PRESTIGE / 4.0
	var star_factor: float = Const.MAX_PRESTIGE / relation
	var stars: int = max(1, prestige / star_factor)
	var spaces: int = 5 - stars
	# creates right padding ex: "***  "
	return "*".repeat(stars) + "  ".repeat(spaces)


func recover_stamina(factor: int = 1) -> void:
	stamina = minf(1, stamina + (Const.STAMINA_FACTOR * factor))


func consume_stamina(speed: float) -> void:
	# consume stamina with  calc 21 - [20,1]
	# best case Const.MAX_PRESTIGE * 1
	# worst case Const.MAX_PRESTIGE * 20
	var consumation: float = (
		Const.STAMINA_FACTOR * (Const.MAX_PRESTIGE + 1 - attributes.physical.stamina) * speed
	)
	# print("stamina: %d consumtion: %f"%[attributes.physical.stamina, consumation])
	stamina = maxf(0, stamina - consumation)


func position_match_factor(p_position: Position) -> float:
	var factor: float = position.match_factor(p_position)
	for alt_position: Position in alt_positions:
		var alt_factor: float = alt_position.match_factor(p_position)
		factor = max(factor, alt_factor)
	return factor


# @export var form: Enum.Form
# @export var morality: Enum.Morality
# @export var statistics: Statistics
# @export var foot: Enum.Foot

# @export var position: Position
# @export var alt_positions: Array[Position]

# @export var attributes: Attributes
# @export var contract: Contract

func sort(key: String) -> Variant:
	match key:
		"position":
			return position.type
		"birth_date":
			return Time.get_unix_time_from_datetime_dict(birth_date)

		# goalkeeper
		"reflexes":
			return attributes.goalkeeper.reflexes
		"positioning":
			return attributes.goalkeeper.positioning
		"save_feet":
			return attributes.goalkeeper.save_feet
		"save_hands":
			return attributes.goalkeeper.save_hands
		"diving":
			return attributes.goalkeeper.diving

		# mental
		"aggression":
			return attributes.mental.aggression
		"anticipation":
			return attributes.mental.anticipation
		"decisions":
			return attributes.mental.decisions
		"concentration":
			return attributes.mental.concentration
		"vision":
			return attributes.mental.vision
		"workrate":
			return attributes.mental.workrate
		"offensive_movement":
			return attributes.mental.offensive_movement
		"marking":
			return attributes.mental.marking

		# physical
		"pace":
			return attributes.physical.pace
		"acceleration":
			return attributes.physical.acceleration
		"stamina":
			return attributes.physical.stamina
		"strength":
			return attributes.physical.strength
		"agility":
			return attributes.physical.agility
		"jump":
			return attributes.physical.jump

		# technical
		"crossing":
			return attributes.technical.crossing
		"passing":
			return attributes.technical.passing
		"long_passing":
			return attributes.technical.long_passing
		"tackling":
			return attributes.technical.tackling
		"heading":
			return attributes.technical.heading
		"interception":
			return attributes.technical.interception
		"shooting":
			return attributes.technical.shooting
		"long_shooting":
			return attributes.technical.long_shooting
		"free_kick":
			return attributes.technical.free_kick
		"penalty":
			return attributes.technical.penalty
		"finishing":
			return attributes.technical.finishing
		"dribbling":
			return attributes.technical.dribbling
		"blocking":
			return attributes.technical.blocking
		_:
			var property: Variant = get(key)
			if property == null or property is Object:
				print("error while sorting player, key %s not found" % key)
				return -1
			return property
