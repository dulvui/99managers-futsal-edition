# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestMatchCombination
extends Test

const TEAMS: int = 10


func test() -> void:
	print("test: match combination...")
	var league: League = Tests.create_mock_league(TEAMS)
	test_combinations(league)
	print("test: match combination done.")


func test_combinations(league: League) -> void:
	print("test: combinations...")
	var match_days: Array[Array] = MatchCombinationUtil.create_combinations(league, league.teams)

	# match amount
	var reference_match_count: int = (TEAMS - 1) * 2 * (TEAMS / 2)
	var match_count: int = 0
	for match_day: Array in match_days:
		match_count += match_day.size()
	assert(reference_match_count == match_count)

	# every team plays against each other team 2 times
	# one at home and one away
	for team: Team in league.teams:
		# [team_id] = 1
		var home_counter: Dictionary = {}
		var away_counter: Dictionary = {}
		
		for match_day: Array in match_days:
			for match: Match in match_day:
				# plays at home
				if match.home_id == team.id:
					if not home_counter.has(match.away_id):
						home_counter[match.away_id] = 0
					home_counter[match.away_id] += 1
				# plays away
				if match.away_id == team.id:
					if not away_counter.has(match.home_id):
						away_counter[match.home_id] = 0
					away_counter[match.home_id] += 1
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


