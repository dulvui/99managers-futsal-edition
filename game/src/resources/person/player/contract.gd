# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Contract
extends JSONResource

@export var income: int
@export var bonus_goal: int
@export var bonus_clean_sheet: int
@export var bonus_assist: int
@export var bonus_league: int
@export var bonus_national_cup: int
@export var bonus_continental_cup: int
@export var buy_clause: int
@export var start_date: Dictionary  # unixtimestamp
@export var end_date: Dictionary
@export var is_on_loan: bool


func _init(
	p_income: int = 0,
	p_bonus_goal: int = 0,
	p_bonus_clean_sheet: int = 0,
	p_bonus_assist: int = 0,
	p_bonus_league: int = 0,
	p_bonus_national_cup: int = 0,
	p_bonus_continental_cup: int = 0,
	p_buy_clause: int = 0,
	p_start_date: Dictionary = {},
	p_end_date: Dictionary = {},
	p_is_on_loan: bool = false,
) -> void:
	income = p_income
	start_date = p_start_date
	end_date = p_end_date
	bonus_goal = p_bonus_goal
	bonus_clean_sheet = p_bonus_clean_sheet
	bonus_assist = p_bonus_assist
	bonus_league = p_bonus_league
	bonus_national_cup = p_bonus_national_cup
	bonus_continental_cup = p_bonus_continental_cup
	buy_clause = p_buy_clause
	is_on_loan = p_is_on_loan


