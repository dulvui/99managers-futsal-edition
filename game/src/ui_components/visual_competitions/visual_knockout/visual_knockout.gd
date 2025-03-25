# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualKnockout
extends VBoxContainer

const MatchInfoScene: PackedScene = preload(Const.SCENE_MATCH_INFO)

@onready var title_label: Label = %Title
@onready var group_a_label: Label = %GroupALabel
@onready var group_b_label: Label = %GroupBLabel
@onready var group_a: HBoxContainer = %GroupA
@onready var group_b: HBoxContainer = %GroupB
@onready var final: MatchInfo = %Final


func _ready() -> void:
	Tests.setup_mock_world(true)


func setup(knockout: Knockout, title: String = "") -> void:
	if not title.is_empty():
		title_label.text = title
	
	# group a
	if knockout.rounds_a.size() == 0:
		group_a_label.hide()
	for roundz: KnockoutRound in knockout.rounds_a:
		var box: VBoxContainer = VBoxContainer.new()
		box.alignment = ALIGNMENT_CENTER
		group_a.add_child(box)
		for matchz: Match in roundz.matches:
			var match_info: MatchInfo = MatchInfoScene.instantiate()
			box.add_child(match_info)
			match_info.setup(matchz, true)
	# group b
	if knockout.rounds_b.size() == 0:
		group_b_label.hide()
	for roundz: KnockoutRound in knockout.rounds_b:
		var box: VBoxContainer = VBoxContainer.new()
		box.alignment = ALIGNMENT_CENTER
		group_b.add_child(box)
		for matchz: Match in roundz.matches:
			var match_info: MatchInfo = MatchInfoScene.instantiate()
			box.add_child(match_info)
			match_info.setup(matchz, true)

	if not knockout.final.is_empty():
		final.setup(knockout.final[-1], true)
