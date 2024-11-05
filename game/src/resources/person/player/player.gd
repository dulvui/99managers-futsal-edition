# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Player
extends Person

enum Foot { L, R }
enum Morality { HORRIBLE, BAD, GOOD, EXCELLENT }
enum Form { INJURED, RECOVER, GOOD, EXCELLENT }

@export var price: int
@export var nr: int  # shirt number
@export var loyality: int
@export var injury_factor: int
@export var stamina: float
@export var team: String  # team name for easier filtering etc...
@export var team_id: int  # team name for easier filtering etc...
@export var form: Form
@export var morality: Morality
@export var statistics: Statistics
@export var history: Array[History]
@export var foot: Foot
@export var position: Position
@export var alt_positions: Array[Position]
@export var attributes: Attributes
@export var agent: Agent


func _init(
	p_price: int = 0,
	p_nr: int = 0,
	p_loyality: int = 0,
	p_prestige: int = 0,
	p_injury_factor: int = 0,
	p_stamina: float = 1,
	p_name: String = "",
	p_team: String = "",
	p_team_id: int = 0,
	p_surname: String = "",
	p_nation: String = "",
	p_birth_date: Dictionary = Time.get_datetime_dict_from_system(),
	p_form: Form = Form.GOOD,
	p_morality: Morality = Morality.GOOD,
	p_statistics: Statistics = Statistics.new(),
	p_history: Array[History] = [],
	p_foot: Foot = Foot.R,
	p_position: Position = Position.new(),
	p_alt_positions: Array[Position] = [],
	p_contract: Contract = Contract.new(),
	p_attributes: Attributes = Attributes.new(),
	p_agent: Agent = Agent.new(),
) -> void:
	super(Person.Role.PLAYER)
	price = p_price
	nr = p_nr
	loyality = p_loyality
	prestige = p_prestige
	injury_factor = p_injury_factor
	stamina = p_stamina
	name = p_name
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


func get_attack_attributes(attack: Action.Attack) -> int:
	match attack:
		Action.Attack.SHOOT:
			# check sector and pick long_shoot
			return attributes.technical.shooting
		Action.Attack.PASS:
			return attributes.technical.passing
#		Action.Attack.CROSS:
#			return attributes.technical.crossing
		Action.Attack.DRIBBLE:
			return attributes.technical.dribbling
#		Action.Attack.HEADER:
#			return attributes.technical.heading"]
		Action.Attack.RUN:
			var attacker_attributes: int = attributes.physical.pace
			attacker_attributes += attributes.physical.acceleration
			return attacker_attributes
	# should never happen
	return -1


func get_defense_attributes(attack: Action.Attack) -> int:
	match attack:
		Action.Attack.SHOOT:
			# check sector and pick long_shoot
			return attributes.technical.blocking
		Action.Attack.PASS:
			return attributes.technical.interception
#		Action.Attack.CROSS:
#			return attributes.technical.interception"]
		Action.Attack.DRIBBLE:
			return attributes.technical.tackling
#		Action.Attack.HEADER:
#			return attributes.technical.heading"]
		# use player preferences/attirbutes and team tactics pressing or wait
		Action.Attack.RUN:
			var defender_attributes: int
			if randi() % 2 == 0:
#					return Defense.RUN
				defender_attributes = attributes.physical.pace
				defender_attributes += attributes.physical.acceleration
			else:
#					return Defense.TACKLE
				defender_attributes = attributes.technical.tackling
				defender_attributes += attributes.physical.pace

			return defender_attributes
	# should never happen
	return -1


func get_goalkeeper_attributes() -> int:
	return attributes.goalkeeper.sum()


func get_overall() -> int:
	if position.type == Position.Type.G:
		return attributes.goal_keeper_average()
	return attributes.field_player_average()


func get_res_value(keys: Array[String], p_res: Resource = null) -> Variant:
	# iterate recursivly over properties and attributes
	# to get dynamically nested resource values
	if keys.size() == 1:
		if p_res == null:
			return get(keys[0])
		return p_res.get(keys[0])
	if p_res == null:
		return get_res_value(keys.slice(1, keys.size()), get(keys[0]))
	return get_res_value(keys.slice(1, keys.size()), p_res.get(keys[0]))


func get_prestige_stars() -> String:
	var relation: float = Const.MAX_PRESTIGE / 4.0
	var star_factor: float = Const.MAX_PRESTIGE / relation
	var stars: int = max(1, prestige / star_factor)
	var spaces: int = 5 - stars
	# creates right padding ex: "***  "
	return "*".repeat(stars) + "  ".repeat(spaces)


func recover_stamina(factor: int = 1) -> void:
	stamina = minf(1, stamina + (Const.STAMINA_FACTOR * factor))


func consume_stamina() -> void:
	# consume stamina with  calc 21 - [20,1]
	# best case Const.MAX_PRESTIGE * 1
	# worst case Const.MAX_PRESTIGE * 20
	var consumation: float = (
		Const.STAMINA_FACTOR * (Const.MAX_PRESTIGE + 1 - attributes.physical.stamina)
	)
	# print("stamina: %d consumtion: %f"%[attributes.physical.stamina, consumation])
	stamina = maxf(0, stamina - consumation)
