# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ContractView
extends VBoxContainer

@onready var income: Label = %Income
@onready var start_date: Label = %StartDate
@onready var end_date: Label = %EndDate
@onready var buy_clause: Label = %BuyClause

func setup(player: Player) -> void:
	income.text = FormatUtil.currency(player.contract.income)
	buy_clause.text = FormatUtil.currency(player.contract.buy_clause)
	start_date.text = FormatUtil.day(player.contract.start_date)
	end_date.text = FormatUtil.day(player.contract.end_date)

