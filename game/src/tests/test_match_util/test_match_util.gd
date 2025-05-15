# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestMatchUtil
extends Test

const TEAMS: int = 10


func test() -> void:
	print("test: match combination...")
	Global.reset_data()
	test_combinations()
	print("test: match combination done.")


func test_combinations() -> void:
	var league: League = Tests.create_mock_league(TEAMS)
	print("test: combinations...")
	var match_util: MatchUtil = MatchUtil.new()
	var match_days: MatchDays = match_util.create_combinations(league, league.get_teams_basic())

	# match amount
	var reference_match_count: int = (TEAMS - 1) * 2 * int(TEAMS / 2.0)
	var match_count: int = 0
	for match_day: MatchDay in match_days.days:
		match_count += match_day.size()
	assert(reference_match_count == match_count)

	# every team plays against each other team 2 times
	# one at home and one away
	for team: Team in league.teams:
		# [team_id] = 1
		var home_counter: Dictionary = {}
		var away_counter: Dictionary = {}

		for match_day: MatchDay in match_days.days:
			for match: Match in match_day.matches:
				# plays at home
				if match.home.id == team.id:
					if not home_counter.has(match.away.id):
						home_counter[match.away.id] = 0
					home_counter[match.away.id] += 1
				# plays away
				if match.away.id == team.id:
					if not away_counter.has(match.home.id):
						away_counter[match.home.id] = 0
					away_counter[match.home.id] += 1
		# make sure counters are correct size
		assert(home_counter.keys().size() == TEAMS - 1)
		assert(away_counter.keys().size() == TEAMS - 1)
		# test home
		for key: int in home_counter.keys():
			assert(home_counter[key] == 1)
		# test away
		for key: int in away_counter.keys():
			assert(away_counter[key] == 1)

	print("test: combinations done...")
