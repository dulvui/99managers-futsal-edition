# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualContractOffer
extends Control

signal cancel
signal confirm

const MAX_BUY_CLAUSE: int = 999999999

var income: int = 0
var years: int = 1
var buy_clause: int = 0

var team: Team
var player: Player

@onready var income_label: LineEdit = %Income
@onready var years_label: Label = %Years
@onready var buy_clause_label: LineEdit = %BuyClause


func _ready() -> void:
	team = Global.team


func setup(p_player: Player) -> void:
	player = p_player
	
	if player.contract != null:
		income = player.contract.income
		income_label.text = FormatUtil.currency(income)


func _on_income_more_pressed() -> void:
	if income < team.finances.get_salary_budget():
		income += 1000
	income_label.text = FormatUtil.currency(income)


func _on_income_less_pressed() -> void:
	if income > 1000:
		income -= 1000
		income_label.text = FormatUtil.currency(income)


func _on_years_less_pressed() -> void:
	if years > 1:
		years -= 1
		years_label.text = str(years)


func _on_years_more_pressed() -> void:
	if years < 4:
		years += 1
		years_label.text = str(years)


func _on_buy_clause_less_pressed() -> void:
	if buy_clause > 1000:
		buy_clause -= 1000
		buy_clause_label.text = FormatUtil.currency(buy_clause)


func _on_buy_clause_more_pressed() -> void:
	if buy_clause < MAX_BUY_CLAUSE:
		buy_clause += 1000
		buy_clause_label.text = FormatUtil.currency(buy_clause)


func _on_confirm_pressed() -> void:
	# add contract to pendng contracts

	var contract: PlayerContract = PlayerContract.new()
	contract.buy_clause = buy_clause
	contract.income = income

	# Global.inbox.offer_message(transfer)
	confirm.emit()


func _on_cancel_pressed() -> void:
	cancel.emit()

