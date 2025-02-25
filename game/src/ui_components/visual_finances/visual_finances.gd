# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualFinances
extends Control

@onready var balance: Label = %Balance
@onready var expenses: Label = %Expenses
@onready var income: Label = %Income
@onready var salary_budget: Label = %SalaryBudget
@onready var remaining_salary_budget: Label = %RemainingSalaryBudget


func _ready() -> void:
	if Tests.is_run_as_current_scene(self):
		setup(Tests.create_mock_team())


func setup(team: Team = Global.team) -> void:
	balance.text = FormatUtil.currency(team.finances.balance[-1])
	expenses.text = FormatUtil.currency(team.finances.expenses[-1])
	income.text = FormatUtil.currency(team.finances.income[-1])

	salary_budget.text = FormatUtil.currency(team.finances.get_salary_budget())
	remaining_salary_budget.text = FormatUtil.currency(team.finances.get_remaining_salary_budget())
