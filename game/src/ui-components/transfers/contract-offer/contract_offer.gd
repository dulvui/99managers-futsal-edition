# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control

signal cancel
signal confirm

var income:int = 0
var years:int = 1
var buy_clause:int = 0

var team:Team
var player:Player
var transfer:Transfer


func _ready() -> void:
	team = Config.team
	
func set_up(new_transfer:Transfer) -> void:
	transfer = new_transfer
	player = new_transfer["player"]
	
	$Info.text = "The player " + player.name + " " +  player.surname + " had a contract..."

func _on_IncomeMore_pressed() -> void:
	if income  < team.salary_budget:
		income += 1000
	$GridContainer/Income.text = str(income)

func _on_IncomeLess_pressed() -> void:
	if income > 1000:
		income -= 1000
		$GridContainer/Income.text = str(income)


func _on_YearsLess_pressed() -> void:
	if years > 1:
		years -= 1
		$GridContainer/Years.text = str(years)


func _on_YearsMore_pressed() -> void:
	if years < 4:
		years += 1
		$GridContainer/Years.text = str(years)


func _on_BuyClauseLess_pressed() -> void:
	if buy_clause > 1000:
		buy_clause -= 1000
		$GridContainer/BuyClause.text = str(buy_clause)


func _on_BuyClauseMore_pressed() -> void:
	if buy_clause < 999999999:
		buy_clause += 1000
		$GridContainer/BuyClause.text = str(buy_clause)


func _on_Confirm_pressed() -> void:
	# add contract to pendng contracts 
	
	var def_contract:Dictionary = {
		"player" : player,
		"price" : 0,
		"money/week" : income,
		"start_date" : "01/01/2020", #today
		"end_date" : "01/01/2021", #next season end in x years
		"bonus" : {
			"goal" : 0,
			"clean_sheet" : 0,
			"assist" : 0,
			"league_title" : 0,
			"nat_cup_title" : 0,
			"inter_cup_title" : 0,
		},
		"buy_clause" : buy_clause,
		"days" : (randi()%5)+1,
		#different ui for loan and noarmal contract
		#send loan contracts with other signal or type
		"is_on_loan" : false # if player is on loan, the other squad gets copy of contract with percentage of income
	}
	for transferz:Transfer in TransferUtil.current_transfers:
		if transfer == transferz:
			transferz["contract"] = def_contract
			transferz["days"] = 3
			transferz["state"] = "CONTRACT_PENDING"
			#EmailUtil.new_message(EmailUtil.MessageTypes.CONTRACT_OFFER_MADE, transfer)
	emit_signal("confirm")
#	ContractUtil.current_contract_offers.append(def_contract)


func _on_Cancel_pressed() -> void:
	emit_signal("cancel")


