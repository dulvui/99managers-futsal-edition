# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name AttributesView
extends HBoxContainer

# goalkeeper
@onready var reflexes: ColorLabel = %Reflexes
@onready var positioning: ColorLabel = %Positioning
@onready var save_feet: ColorLabel = %SaveFeet
@onready var save_hands: ColorLabel = %SaveHands
@onready var diving: ColorLabel = %Diving
# mental
@onready var aggression: ColorLabel = %Aggression
@onready var anticipation: ColorLabel = %Anticipation
@onready var decisions: ColorLabel = %Decisions
@onready var concentration: ColorLabel = %Concentration
@onready var vision: ColorLabel = %Vision
@onready var workrate: ColorLabel = %Workrate
@onready var offensive_movement: ColorLabel = %OffensiveMovement
@onready var marking: ColorLabel = %Marking
# physical
@onready var pace: ColorLabel = %Pace
@onready var acceleration: ColorLabel = %Acceleration
@onready var stamina: ColorLabel = %Stamina
@onready var strength: ColorLabel = %Strength
@onready var agility: ColorLabel = %Agility
@onready var jump: ColorLabel = %Jump
# technical
@onready var crossing: ColorLabel = %Crossing
@onready var passing: ColorLabel = %Passing
@onready var long_passing: ColorLabel = %LongPassing
@onready var tackling: ColorLabel = %Tackling
@onready var heading: ColorLabel = %Heading
@onready var interception: ColorLabel = %Interception
@onready var shooting: ColorLabel = %Shooting
@onready var long_shooting: ColorLabel = %LongShooting
@onready var penalty: ColorLabel = %Penalty
@onready var finishing: ColorLabel = %Finishing
@onready var dribbling: ColorLabel = %Dribbling
@onready var blocking: ColorLabel = %Blocking


func setup(player: Player) -> void:
	# goalkeeper
	reflexes.setup("Reflexes")
	reflexes.set_value(player.attributes.goalkeeper.reflexes)
	positioning.setup("Positioning")
	positioning.set_value(player.attributes.goalkeeper.positioning)
	save_feet.setup("Save feet")
	save_feet.set_value(player.attributes.goalkeeper.save_feet)
	save_hands.setup("Save hands")
	save_hands.set_value(player.attributes.goalkeeper.save_hands)
	diving.setup("Diving")
	diving.set_value(player.attributes.goalkeeper.diving)
	# mental
	aggression.setup("Aggression")
	aggression.set_value(player.attributes.mental.aggression)
	anticipation.setup("Anticipation")
	anticipation.set_value(player.attributes.mental.anticipation)
	decisions.setup("Decisions")
	decisions.set_value(player.attributes.mental.decisions)
	concentration.setup("Concentration")
	concentration.set_value(player.attributes.mental.concentration)
	vision.setup("Vision")
	vision.set_value(player.attributes.mental.vision)
	workrate.setup("Workrate")
	workrate.set_value(player.attributes.mental.workrate)
	offensive_movement.setup("Offensive movement")
	offensive_movement.set_value(player.attributes.mental.offensive_movement)
	marking.setup("Marking")
	marking.set_value(player.attributes.mental.marking)
	# physical
	pace.setup("Pace")
	pace.set_value(player.attributes.physical.pace)
	acceleration.setup("Acceleration")
	acceleration.set_value(player.attributes.physical.acceleration)
	stamina.setup("Stamina")
	stamina.set_value(player.attributes.physical.stamina)
	strength.setup("Strength")
	strength.set_value(player.attributes.physical.strength)
	agility.setup("Agility")
	agility.set_value(player.attributes.physical.agility)
	jump.setup("Jump")
	jump.set_value(player.attributes.physical.jump)
	# technical
	crossing.setup("Crossing")
	crossing.set_value(player.attributes.technical.crossing)
	passing.setup("Passing")
	passing.set_value(player.attributes.technical.passing)
	long_passing.setup("Long_passing")
	long_passing.set_value(player.attributes.technical.long_passing)
	tackling.setup("Tackling")
	tackling.set_value(player.attributes.technical.tackling)
	heading.setup("Heading")
	heading.set_value(player.attributes.technical.heading)
	interception.setup("Interception")
	interception.set_value(player.attributes.technical.interception)
	shooting.setup("Shooting")
	shooting.set_value(player.attributes.technical.shooting)
	long_shooting.setup("Long_shooting")
	long_shooting.set_value(player.attributes.technical.long_shooting)
	penalty.setup("Penalty")
	penalty.set_value(player.attributes.technical.penalty)
	finishing.setup("Finishing")
	finishing.set_value(player.attributes.technical.finishing)
	dribbling.setup("Dribbling")
	dribbling.set_value(player.attributes.technical.dribbling)
	blocking.setup("Blocking")
	blocking.set_value(player.attributes.technical.blocking)
