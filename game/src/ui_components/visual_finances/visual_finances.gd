# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualFinances
extends Control


@onready var balance: Label = %Balance
@onready var expenses: Label = %Expenses
@onready var income: Label = %Income


func _ready() -> void:
	# setup automatically, if run in editor and is run by 'Run current scene'
	if OS.has_feature("editor") and get_parent() == get_tree().root:
		setup(Tests.create_mock_team())


func setup(team: Team = Global.team) -> void:
	balance.text = FormatUtil.currency(team.finances.balance)
	expenses.text = FormatUtil.currency(team.finances.expenses)
	income.text = FormatUtil.currency(team.finances.income)


