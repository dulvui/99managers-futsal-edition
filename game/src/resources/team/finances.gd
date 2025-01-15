# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Finances
extends JSONResource


# weekly values, [-1] is latest
@export var balance: Array[int]
@export var income: Array[int]
@export var expenses: Array[int]

# seasonal histories for current season
@export var balance_history: Array[int]
@export var income_history: Array[int]
@export var expenses_history: Array[int]

@export var sponsor: Sponsor

func _init(
	p_balance: Array[int] = [0],
	p_income: Array[int] = [0],
	p_expeneses: Array[int] = [0],
	p_sponsor: Sponsor = Sponsor.new(),
) -> void:
	balance = p_balance
	income = p_income
	expenses = p_expeneses
	sponsor = p_sponsor


func update_week(team: Team) -> void:
	# append new weekly values
	balance.append(balance[-1])
	expenses.append(0)
	income.append(0)

	# calculate expenses
	expenses[-1] += team.staff.get_salary()

	for player: Player in team.players:
		expenses[-1] += player.contract.income_week

	balance[-1] -= expenses[-1]

	# caclulate income
	# TODO iterate over matches and get REAL capacity and REAL matches
	income[-1] += team.stadium.ticket_price + team.stadium.capacity

	balance[-1] += income[-1]


func update_season(team: Team) -> void:
	# calculate expenses
	expenses[-1] += team.stadium.maintenance_cost

	balance[-1] -= expenses[-1]

	# caclulate income
	income[-1] += sponsor.budget

	# TODO only get price money for team
	# TODO also cups
	income[-1] += Global.league.price_money

	balance[-1] += income[-1]
	# TODO taxes


func get_salary_budget() -> int:
	return balance[-1] + income[-1]


func get_remaining_salary_budget() -> int:
	return balance[-1] + income[-1] - expenses[-1]
