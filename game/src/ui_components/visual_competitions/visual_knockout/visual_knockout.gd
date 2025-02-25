# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualKnockout
extends VBoxContainer

const MatchInfoScene: PackedScene = preload(
	"res://src/ui_components/visual_calendar/match_list/match_info/match_info.tscn"
)

@onready var group_a: HBoxContainer = %GroupA
@onready var group_b: HBoxContainer = %GroupB
@onready var final: Label = %Final


func _ready() -> void:
	Tests.setup_mock_world(true)


func setup(knockout: Knockout) -> void:
	# group a
	for rounds: Array in knockout.matches_by_round_a:
		var box: VBoxContainer = VBoxContainer.new()
		box.alignment = ALIGNMENT_CENTER
		group_a.add_child(box)
		for matchz: Match in rounds:
			var match_row: MatchInfo = MatchInfoScene.instantiate()
			box.add_child(match_row)
			match_row.setup(matchz)
	# group b
	for rounds: Array in knockout.matches_by_round_b:
		var box: VBoxContainer = VBoxContainer.new()
		box.alignment = ALIGNMENT_CENTER
		group_b.add_child(box)
		for matchz: Match in rounds:
			var match_row: MatchInfo = MatchInfoScene.instantiate()
			box.add_child(match_row)
			match_row.setup(matchz)

	if knockout.final != null:
		final.text = knockout.final.get_result()
