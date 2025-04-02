# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name InfoView
extends GridContainer

var team_id: int

@onready var player_name: Label = %Name
@onready var pos: Label = %Position
@onready var alt_pos: Label = %AltPosition
@onready var age: Label = %Age
@onready var foot: Label = %Foot
@onready var nationality: Label = %Nationality
@onready var team_link: LinkButton = %TeamLink
@onready var nr: Label = %Nr
@onready var attributes_average: Label = %AttributesAverage
@onready var prestige: Label = %Prestige
@onready var value: Label = %Value


func setup(player: Player) -> void:
	player_name.text = player.get_full_name()
	pos.text = str(Position.Type.keys()[player.position.type])
	alt_pos.text = str(
		", ".join(player.alt_positions.map(func(p: Position) -> String: return Position.Type.keys()[p.type]))
	)
	age.text = (
		"%d - %s"
		% [player.get_age(Global.world.calendar.date), FormatUtil.day(player.birth_date)]
	)
	foot.text = "%s %d/20 - %s %d/20" % [tr("Left"), player.foot_left, tr("Right"), player.foot_right]
	nationality.text = tr(player.nation)
	team_link.text = player.team
	prestige.text = str(player.prestige)
	nr.text = str(player.nr)
	attributes_average.text = str(player.get_overall())
	value.text = FormatUtil.currency(player.value)

	team_id = player.team_id


func _on_team_link_pressed() -> void:
	LinkUtil.link_team_id(team_id)
