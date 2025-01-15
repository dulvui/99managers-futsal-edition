# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Finances
extends JSONResource


@export var balance: int
@export var income: int
@export var expenses: int
@export var sponsor: Sponsor


func _init(
	p_balance: int = 0,
	p_income: int = 0,
	p_expeneses: int = 0,
	p_sponsor: Sponsor = Sponsor.new(),
) -> void:
	balance = p_balance
	income = p_income
	expenses = p_expeneses
	sponsor = p_sponsor


func update_season(team: Team) -> void:
	# calculate expenses
	expenses += team.stadium.maintenance_cost
	expenses += team.staff.get_salary()

	for player: Player in team.players:
		expenses += player.contract.income

	balance -= expenses

	# caclulate income
	income += sponsor.budget
	# TODO iterate over matches and get REAL capacity
	income += team.stadium.ticket_price + team.stadium.capacity

	# TODO only get price money for team
	# TODO also cups
	income += Global.league.price_money

	balance += income


	# TODO taxes


func get_salary_budget() -> int:
	return balance + income - expenses
