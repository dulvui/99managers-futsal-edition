# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Contract
extends JSONResource

@export var income: int
@export var income_week: int
@export var bonus_goal: int
@export var bonus_clean_sheet: int
@export var bonus_assist: int
@export var bonus_league_title: int
@export var bonus_nat_cup_title: int
@export var bonus_inter_cup_title: int
@export var buy_clause: int
@export var start_date: Dictionary  # unixtimestamp
@export var end_date: Dictionary
@export var is_on_loan: bool


func _init(
	p_income: int = 0,
	p_income_week: int = 0,
	p_bonus_goal: int = 0,
	p_bonus_clean_sheet: int = 0,
	p_bonus_assist: int = 0,
	p_bonus_league_title: int = 0,
	p_bonus_nat_cup_title: int = 0,
	p_bonus_inter_cup_title: int = 0,
	p_buy_clause: int = 0,
	p_start_date: Dictionary = Time.get_date_dict_from_system(),
	p_end_date: Dictionary = Time.get_date_dict_from_system(),
	p_is_on_loan: bool = false,
) -> void:
	income = p_income
	income_week = p_income_week
	start_date = p_start_date
	end_date = p_end_date
	bonus_goal = p_bonus_goal
	bonus_clean_sheet = p_bonus_clean_sheet
	bonus_assist = p_bonus_assist
	bonus_league_title = p_bonus_league_title
	bonus_nat_cup_title = p_bonus_nat_cup_title
	bonus_inter_cup_title = p_bonus_inter_cup_title
	buy_clause = p_buy_clause
	is_on_loan = p_is_on_loan
