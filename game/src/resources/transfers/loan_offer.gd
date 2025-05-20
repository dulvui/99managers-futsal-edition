# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name LoanOffer
extends Offer

# loan offer made to a team
# no further contract offer needed
# player can still decline transfer, if not interested

enum Duration {
	FULL_SEASON,
	NEXT_WINDOW,
}

var current_team: TeamBasic
var duration: Duration


func _init(
	p_current_team: TeamBasic = TeamBasic.new(),
	p_duration: Duration = Duration.NEXT_WINDOW,
) -> void:
	current_team = p_current_team
	duration = p_duration

