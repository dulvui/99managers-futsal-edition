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
	var subject: String = tr("Next match: {team_name}")  # TRANSLATORS: {team_name} gets dynamically filled
	var text: String = tr("The next match is against {team_name}.")  # TRANSLATORS: {team_name} gets dynamically filled

	var team_id: int = p_match.home.id

	if team_id == Global.team.id:
		team_id = p_match.away.id

	var team: Team = Global.world.get_team_by_id(team_id, p_match.competition_id)
	if team == null:
		print("no team with found with id " + str(team_id))
		return

	var team_name: String = team.name

	subject = subject.format({"team_name": team_name})
	text = text.format({"team_name": LinkUtil.get_team_url(team_id, team_name)})

	new_message(subject, text)


func welcome_manager() -> void:
	var subject: String = tr("Welcome {manager_name}")
	var text: String = tr("{team_name} welcomes you to a new journey.")  # TRANSLATORS: {team_name} gets dynamically filled

	subject = subject.format({"manager_name": Global.manager.get_full_name()})
	text = text.format({"team_name": Global.team.name})

	new_message(subject, text)


func transfer_message(transfer: Transfer) -> void:
	var subject: String
	var text: String
	var sender_team: TeamBasic

	if transfer.offer_team.id == Global.team.id:
		sender_team = transfer.team
	else:
		sender_team = transfer.offer_team

	match transfer.state:
		Transfer.State.OFFER:
			# TRANSLATORS: {player_name} gets dynamically filled
			subject = tr("Offer for {player_name}")
			# TRANSLATORS: {cost}, {player_name}, {team_name} get dynamically filled
			text = tr(
				"You made an offer for {player_name} from {team_name} at {cost}.\n
				{team_name} will consider the offer and respond within a few days."
			)

			subject = subject.format({"player_name": transfer.player_name})

			var player_link: String = LinkUtil.get_player_url(
				transfer.player_id, transfer.player_name, transfer.team.id
			)
			text = (
				text
				. format(
					{
						"cost": FormatUtil.currency(transfer.cost),
						"player_name": player_link,
						"team_name": sender_team.name,
					}
				)
			)
		Transfer.State.OFFER_DECLINED:
			# TRANSLATORS: {player_name} gets dynamically filled
			subject = tr("Offer for {player_name} declined")
			# TRANSLATORS: {player_name}, {team_name} get dynamically filled
			text = tr(
				"Your offer for {player_name} from {team_name} at {cost} has been declined.\nIncreasing the transfer value could make them reconsider."
			)

			subject = subject.format({"player_name": transfer.player_name})
			var player_link: String = LinkUtil.get_player_url(
				transfer.player_id, transfer.player_name, transfer.team.id
			)

			text = (
				text
				. format(
					{
						"player_name": player_link,
						"team_name": sender_team.name,
						"cost": FormatUtil.currency(transfer.cost),
					}
				)
			)
		Transfer.State.CONTRACT:
			# TRANSLATORS: {player_name} gets dynamically filled
			subject = tr("Offer for {player_name} accepted")
			# TRANSLATORS: {player_name}, {team_name} get dynamically filled
			text = tr(
				"Your offer for {player_name} from {team_name} at {cost} has been accepted.\nYou can now find a contractual aggreement with {player_name}."
			)

			subject = subject.format({"player_name": transfer.player_name})

			var player_link: String = LinkUtil.get_player_url(
				transfer.player_id, transfer.player_name, transfer.team.id
			)
			text = (
				text
				. format(
					{
						"player_name": player_link,
						"team_name": sender_team.name,
					}
				)
			)
		# Transfer.State.CONTRACT_PENDING:
		# 	# TRANSLATORS: {player_name} gets dynamically filled
		# 	subject = tr("EMAIL_SUBJECT_TRANSER_CONTRACT_PENDING")
		# 	# TRANSLATORS: {player_name}, {team_name}, {income} get dynamically filled
		# 	text = tr("EMAIL_TEXT_TRANSER_CONTRACT_PENDING")
		#
		# 	subject = subject.format({"player_name": transfer.player.get_full_name()})
		# 	text = text.format(
		# 		{
		# 			"player_name": transfer.player.get_full_name(),
		# 			"team_name": sender_team.name,
		# 			"income": transfer.contract.income,
		# 		}
		# 	)
		# Transfer.State.CONTRACT_DECLINED:
		# 	subject = "CONTRACT_DECLINED"
		# 	text = (
		# 		"The player " + transfer.player.get_full_name() + " acceptet the contract"
		# 	)
		# Transfer.State.SUCCESS:
		# 	# TRANSLATORS: {player_name} gets dynamically filled
		# 	subject = tr("EMAIL_SUBJECT_TRANSER_SUCCESS")
		# 	# TRANSLATORS: {cost}, {player_name}, {team_name} get dynamically filled
		# 	text = tr("EMAIL_TEXT_TRANSER_SUCCESS")
		#
		# 	subject = subject.format({"player_name": transfer.player.get_full_name()})
		# 	text = text.format(
		# 		{
		# 			"cost": transfer.cost,
		# 			"player_name": transfer.player.get_full_name(),
		# 			"team_name": sender_team.name,
		# 		}
		# 	)
		_:
			subject = "ERROR"
			text = "Error in code " + transfer.player_name

	new_message(subject, text, sender_team)


func new_message(subject: String, text: String, sender_team: TeamBasic = Global.team) -> void:
	var message: EmailMessage = EmailMessage.new()
	message.set_id()
	message.subject = subject
	message.text = text
	message.sender = _get_team_email_address(sender_team)
	message.receiver = _get_manager_email_address()
	message.date = Global.world.calendar.date
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


func _get_team_email_address(team: TeamBasic = Global.team) -> String:
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
