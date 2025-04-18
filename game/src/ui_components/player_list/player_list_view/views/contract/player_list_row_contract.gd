# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListRowContract
extends PlayerListRow

@onready var income: Label = %Income
@onready var buy_clause: Label = %BuyClause
@onready var start_date: Label = %StartDate
@onready var end_date: Label = %EndDate
@onready var is_on_loan: Label = %IsOnLoan


func setup(player: Player, index: int) -> void:
	super(player, index)
	income.text = FormatUtil.currency(player.contract.income)
	buy_clause.text = FormatUtil.currency(player.contract.buy_clause)
	start_date.text = FormatUtil.day(player.contract.start_date)
	end_date.text = FormatUtil.day(player.contract.end_date)
	if player.contract.is_on_loan:
		is_on_loan.text = tr("Yes")
	else:
		is_on_loan.text = tr("No")

