# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListRowContract
extends PlayerListRow

@onready var income: Label = %Income
@onready var bonus_goal: Label = %BonusGoal
@onready var bonus_clean_sheet: Label = %BonusCleanSheet
@onready var bonus_assist: Label = %BonusAssist
@onready var bonus_league: Label = %BonusLeague
@onready var bonus_national_cup: Label = %BonusNationalCup
@onready var bonus_continental_cup: Label = %BonusContinentalCup
@onready var buy_clause: Label = %BuyClause
@onready var start_date: Label = %StartDate
@onready var end_date: Label = %EndDate
@onready var is_on_loan: Label = %IsOnLoan


func setup(player: Player, index: int) -> void:
	super(player, index)
	income.text = FormatUtil.currency(player.contract.income)
	bonus_goal.text = FormatUtil.currency(player.contract.bonus_goal)
	bonus_clean_sheet.text = FormatUtil.currency(player.contract.bonus_clean_sheet)
	bonus_assist.text = FormatUtil.currency(player.contract.bonus_assist)
	bonus_league.text = FormatUtil.currency(player.contract.bonus_league)
	bonus_national_cup.text = FormatUtil.currency(player.contract.bonus_national_cup)
	bonus_continental_cup.text = FormatUtil.currency(player.contract.bonus_continental_cup)
	buy_clause.text = FormatUtil.currency(player.contract.buy_clause)
	start_date.text = FormatUtil.day(player.contract.start_date)
	end_date.text = FormatUtil.day(player.contract.end_date)
	if player.contract.is_on_loan:
		is_on_loan.text = tr("Yes")
	else:
		is_on_loan.text = tr("No")
