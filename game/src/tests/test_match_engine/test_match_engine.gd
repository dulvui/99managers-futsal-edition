# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestMatchEngine
extends Node


func test() -> void:
	print("test: match engine...")
	test_possess_change()
	test_deterministic_simulations()
	print("test: match engine done.")


func test_deterministic_simulations() -> void:
	print("test: deterministic simulation...")
	var matches: Array[Match] = []
	
	const AMOUNT: int = 3
	
	var league: League = Tests.create_mock_league()

	# simulate matches
	for i: int in AMOUNT:
		var match_engine: MatchEngine = MatchEngine.new()
		var matchz: Match = Match.new()
		# use always same match id, since match seed is match is
		matchz.id = 1
		matches.append(matchz)
		matchz.setup(league.teams[0], league.teams[1], league.id, league.name)
		match_engine.simulate(matchz)
	
	# check results
	for i: int in AMOUNT:
		assert(matches[i].home_goals == matches[i - 1].home_goals)
		assert(matches[i].away_goals == matches[i - 1].away_goals)
	

	print("test: deterministic simulation done.")


func test_possess_change() -> void:
	print("test: possess change...")
	var match_engine: MatchEngine = MatchEngine.new()
	match_engine.setup(Tests.create_mock_team(), Tests.create_mock_team(), 1234)

	match_engine.home_team.has_ball = true
	match_engine.away_team.has_ball = false
	match_engine.away_team.interception.emit()
	assert(match_engine.away_team.has_ball == true)
	assert(match_engine.home_team.has_ball == false)
	print("test: possess change done...")
