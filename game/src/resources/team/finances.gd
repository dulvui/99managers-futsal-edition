# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Finances
extends JSONResource

# weekly values, [-1] is latest
@export var balance: Array[int]
@export var income: Array[int]
@export var expenses: Array[int]
@export var income_tax: int

# complete histories by season
@export var balance_history: Array[Array]
@export var income_history: Array[Array]
@export var expenses_history: Array[Array]
@export var income_tax_history: Array[int]

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
		expenses[-1] += int(player.contract.income / 52.0)

	balance[-1] -= expenses[-1]

	# caclulate income
	# TODO iterate over matches and get REAL capacity and REAL matches
	income[-1] += team.stadium.ticket_price + team.stadium.capacity

	balance[-1] += income[-1]


func update_season(team: Team) -> void:
	var league: League = Global.world.get_league_by_id(team.league_id)
	# do nothing if team not playing in a league
	# should not happen
	if league == null:
		push_error("team with no league found \"%s\" while updating season finances" % team.name)
		return

	var total_income: int = 0
	for i: int in income:
		total_income += i

	var total_expenses: int = 0
	for i: int in expenses:
		total_expenses += i

	var total_profit: int = total_income - total_expenses

	# calculate taxes, base on profits, and can't be less than 0
	income_tax = max(0, total_profit / 100.0 * 28)

	# save to history
	balance_history.append(balance)
	income_history.append(income)
	expenses_history.append(expenses)
	income_tax_history.append(income_tax)

	# reset values
	balance = [-income_tax]
	income = [0]
	expenses = [0]

	# calculate expenses
	expenses[-1] += team.stadium.maintenance_cost
	balance[-1] -= expenses[-1]

	# TODO pick from sponsors pool
	# calculate income
	income[-1] += sponsor.budget

	# TODO only get price money for team
	# TODO also cups
	income[-1] += league.price_money

	balance[-1] += income[-1]


func get_salary_budget() -> int:
	return balance[-1] + income[-1]


func get_remaining_salary_budget() -> int:
	return balance[-1] + income[-1] - expenses[-1]
