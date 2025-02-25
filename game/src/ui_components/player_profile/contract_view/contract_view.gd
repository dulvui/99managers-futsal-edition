# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ContractView
extends VBoxContainer

@onready var income: Label = %Income
@onready var start_date: Label = %StartDate
@onready var end_date: Label = %EndDate
@onready var buy_clause: Label = %BuyClause

@onready var bonus_goal: Label = %Goal
@onready var bonus_assist: Label = %Assist
@onready var bonus_clean_sheet: Label = %CleanSheet
@onready var bonus_league: Label = %League
@onready var bonus_national_cup: Label = %NationalCup
@onready var bonus_continental_cup: Label = %ContinentalCup

@onready var offer_button: Button = %Offer


func setup(player: Player) -> void:
	# show offer button, only for players that are not in your team
	if Global.team:
		offer_button.visible = not Global.team.players.has(player)
	
	income.text = FormatUtil.currency(player.contract.income)
	buy_clause.text = FormatUtil.currency(player.contract.buy_clause)
	start_date.text = FormatUtil.format_date(player.contract.start_date)
	end_date.text = FormatUtil.format_date(player.contract.end_date)

	bonus_goal.text = FormatUtil.currency(player.contract.bonus_goal)
	bonus_assist.text = FormatUtil.currency(player.contract.bonus_assist)
	bonus_clean_sheet.text = FormatUtil.currency(player.contract.bonus_clean_sheet)
	bonus_league.text = FormatUtil.currency(player.contract.bonus_league)
	bonus_national_cup.text = FormatUtil.currency(player.contract.bonus_national_cup)
	bonus_continental_cup.text = FormatUtil.currency(player.contract.bonus_continental_cup)


