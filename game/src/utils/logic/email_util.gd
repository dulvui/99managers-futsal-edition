# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal refresh_inbox

# TODO check performance for whole season and see if limit is needed
# const MAX_MESSAGES: int = 50


func latest() -> EmailMessage:
	if Global.inbox.list.size() == 0:
		return null
	return Global.inbox.list[-1]


func count_unread_messages() -> int:
	var counter: int = 0
	for message: EmailMessage in Global.inbox.list:
		if not message["read"]:
			counter += 1
	return counter


func next_match(p_match: Match) -> void:
	var team_name: String = p_match.home.name
	if team_name == Global.team.name:
		team_name = p_match.away.name

	var message: EmailMessage = EmailMessage.new()
	message.subject = tr("NEXT_MATCH") + " against " + team_name
	message.text = "The next match is against " + team_name + ".\nThe quotes are: "
	message.sender = _get_team_email_address()
	message.receiver = _get_manager_email_address()
	message.date = Global.world.calendar.format_date()
	_add_message(message)


func transfer_message(transfer: Transfer) -> void:
	var message: EmailMessage = EmailMessage.new()
	message.date = Global.world.calendar.format_date()
	message.receiver = _get_manager_email_address()

	# assign rid of transfer, so it can be used for toher purposes
	message.foreign_id = transfer.id

	if transfer.buy_team.name == Global.team.name:
		message.sender = "info@" + transfer.sell_team.name.to_lower() + ".com"
	else:
		message.sender = "info@" + transfer.buy_team.name.to_lower() + ".com"

	match transfer.state:
		Transfer.State.OFFER:
			message.subject = "OFFER: " + transfer.player.get_full_name()
			message.text = (
				"You made an "
				+ str(transfer.cost)
				+ " offer for "
				+ transfer.player.get_full_name()
			)
		Transfer.State.SUCCESS:
			message.subject = "TRANSFER SUCCESS: " + transfer.player.get_full_name()
			message.text = (
				"You bought for" + str(transfer.cost) + " " + transfer.player.get_full_name()
			)
		Transfer.State.OFFER_DECLINED:
			message.subject = "OFFER_DECLINED"
			message.text = (
				"The team "
				+ transfer.sell_team.name
				+ " definitly declined your offer for "
				+ transfer.player.get_full_name()
			)
		Transfer.State.CONTRACT:
			message.subject = "OFFER_ACCEPTED"
			message.text = (
				"The team "
				+ transfer.sell_team.name
				+ " agreed to your offer for "
				+ transfer.player.get_full_name()
			)
			message.text += "OFFER_ACCEPTED_TEXT"
			message.type = EmailMessage.Type.CONTRACT_OFFER
		Transfer.State.CONTRACT_PENDING:
			message.subject = "CONTRACT OFFER MADE"
			message.text = "You made an contract offer for " + transfer.player.get_full_name()
			message.text = "The income is " + str(transfer.contract.income)
		Transfer.State.SUCCESS:
			message.subject = "CONTRACT_SIGNED"
			message.text = (
				"The player " + transfer.player.get_full_name() + " acceptet the contract"
			)
		Transfer.State.CONTRACT_DECLINED:
			message.subject = "CONTRACT_DECLINED"
			message.text = (
				"The player " + transfer.player.get_full_name() + " acceptet the contract"
			)
		_:
			message.subject = "ERROR"
			message.text = "Error in code " + transfer.player.get_full_name()

	_add_message(message)


func welcome_manager() -> void:
	var message: EmailMessage = EmailMessage.new()
	message.subject = tr("WELCOME")
	message.text = "The team " + Global.team.name + " welcomes you as the new Manager!"
	message.sender = _get_team_email_address()
	message.receiver = _get_manager_email_address()
	message.date = Global.world.calendar.format_date()
	_add_message(message)

	#Type.NEXT_SEASON:
	#message["message"] = "The new season begins."
	#message["title"] = "SEASON " + str(Global.date.year) + " STARTS"
	#Type.MARKET_START:
	#message["message"] = "The market begins today."
	#message["title"] = "MARKET STARTS"
	#Type.MARKET_END:
	#message["message"] = "The market ends today."
	#message["title"] = "MARKET ENDS"
	#Type.MARKET_OFFER:
	#message["message"] = "Another team is interested in your player"
	#message["title"] = "MARKET OFFER"


func _add_message(message: EmailMessage) -> void:
	Global.inbox.list.append(message)
	# if Global.inbox.list.size() > MAX_MESSAGES:
	# 	Global.inbox.list.pop_front()
	refresh_inbox.emit()


func _get_manager_email_address(team: Team = Global.team) -> String:
	var email: String = team.staff.manager.name
	email += "." + team.staff.manager.surname
	email += "@" + team.name.replace(" ", "") + ".com"
	email = email.to_lower()
	return email


func _get_team_email_address(team: Team = Global.team) -> String:
	var email: String = "info"
	email += "@" + team.name.replace(" ", "") + ".com"
	email = email.to_lower()
	return email
