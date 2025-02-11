# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal refresh_inbox

# TODO check performance for whole season and see if limit is needed
# const MAX_MESSAGES: int = 50

var subject_transfer_offer: String = tr("EMAIL_SUBJECT_TRANSFER_OFFER") # TRANSLATORS: {team_name} will be filled dynamically
var text_transfer_offer: String = tr("EMAIL_TEXT_TRANSFER_OFFER") # TRANSLATORS: {team_name} will be filled dynamically


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
	var subject: String = tr("EMAIL_SUBJECT_NEXT_MATCH") # TRANSLATORS: {team_name} gets dynamically filled
	var text: String = tr("EMAIL_TEXT_NEXT_MATCH") # TRANSLATORS: {team_name} gets dynamically filled

	var team_name: String = p_match.home.name
	var team_id: int = p_match.home.id

	if team_name == Global.team.name:
		team_name = p_match.away.name
		team_id = p_match.away.id

	subject = subject.format({"team_name": team_name})
	text = text.format({"team_name": LinkUtil.get_team_url(team_id, team_name)})

	new_message(subject, text)


func welcome_manager() -> void:
	var subject: String = tr("EMAIL_SUBJECT_WELCOME") # TRANSLATORS: {manager_name} gets dynamically filled
	var text: String = tr("EMAIL_TEXT_WELCOME") # TRANSLATORS: {team_name} will be filled dynamically
	
	subject = subject.format({"manager_name": Global.manager.get_full_name()})
	text = text.format({"team_name": Global.team.name})

	new_message(subject, text)


func transfer_message(transfer: Transfer) -> void:
	var subject: String
	var text: String
	var sender_team: Team

	if transfer.buy_team == Global.team:
		sender_team = transfer.sell_team
	else:
		sender_team = transfer.buy_team

	match transfer.state:
		Transfer.State.OFFER:
			# TRANSLATORS: {player_name} gets dynamically filled
			subject = tr("EMAIL_SUBJECT_TRANSER_OFFER")
			# TRANSLATORS: {cost}, {player_name}, {team_name} get dynamically filled
			text = tr("EMAIL_TEXT_TRANSER_OFFER")

			subject = subject.format({"player_name": transfer.player.get_full_name()})
			text = text.format(
				{
					"cost": transfer.cost,
					"player_name": transfer.player.get_full_name(),
					"team_name": sender_team.name,
				}
			)
		Transfer.State.OFFER_DECLINED:
			# TRANSLATORS: {player_name} gets dynamically filled
			subject = tr("EMAIL_SUBJECT_TRANSER_OFFER_DECLINED")
			# TRANSLATORS: {player_name}, {team_name} get dynamically filled
			text = tr("EMAIL_TEXT_TRANSER_OFFER_DECLINED")

			subject = subject.format({"player_name": transfer.player.get_full_name()})
			text = text.format(
				{
					"player_name": transfer.player.get_full_name(),
					"team_name": sender_team.name,
				}
			)
		Transfer.State.CONTRACT:
			# TRANSLATORS: {player_name} gets dynamically filled
			subject = tr("EMAIL_SUBJECT_TRANSER_CONTRACT")
			# TRANSLATORS: {player_name}, {team_name} get dynamically filled
			text = tr("EMAIL_TEXT_TRANSER_CONTRACT")

			subject = subject.format({"player_name": transfer.player.get_full_name()})
			text = text.format(
				{
					"player_name": transfer.player.get_full_name(),
					"team_name": sender_team.name,
				}
			)
		Transfer.State.CONTRACT_PENDING:
			# TRANSLATORS: {player_name} gets dynamically filled
			subject = tr("EMAIL_SUBJECT_TRANSER_CONTRACT_PENDING")
			# TRANSLATORS: {player_name}, {team_name}, {income} get dynamically filled
			text = tr("EMAIL_TEXT_TRANSER_CONTRACT_PENDING")

			subject = subject.format({"player_name": transfer.player.get_full_name()})
			text = text.format(
				{
					"player_name": transfer.player.get_full_name(),
					"team_name": sender_team.name,
					"income": transfer.contract.income,
				}
			)
		Transfer.State.CONTRACT_DECLINED:
			subject = "CONTRACT_DECLINED"
			text = (
				"The player " + transfer.player.get_full_name() + " acceptet the contract"
			)
		Transfer.State.SUCCESS:
			# TRANSLATORS: {player_name} gets dynamically filled
			subject = tr("EMAIL_SUBJECT_TRANSER_SUCCESS")
			# TRANSLATORS: {cost}, {player_name}, {team_name} get dynamically filled
			text = tr("EMAIL_TEXT_TRANSER_SUCCESS")

			subject = subject.format({"player_name": transfer.player.get_full_name()})
			text = text.format(
				{
					"cost": transfer.cost,
					"player_name": transfer.player.get_full_name(),
					"team_name": sender_team.name,
				}
			)

	new_message(subject, text, sender_team)


func new_message(subject: String, text: String, sender_team: Team = Global.team) -> void:
	var message: EmailMessage = EmailMessage.new()
	message.subject = subject
	message.text = text
	message.sender = _get_team_email_address(sender_team)
	message.receiver = _get_manager_email_address()
	message.date = Global.world.calendar.format_date()
	_add_message(message)


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
