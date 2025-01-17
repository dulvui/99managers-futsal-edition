# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestMatchEngine
extends Test


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
	
	var match_engine: MatchEngine = MatchEngine.new()

	# simulate matches
	for i: int in AMOUNT:
		var matchz: Match = Match.new()
		# use always same match id/seed
		matchz.id = 1
		matches.append(matchz)
		matchz.setup(league.teams[0], league.teams[1], league.id, league.name)
		match_engine.simulate_match(matchz)
		print("test: match %d calculated"%int(i + 1))
	
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


func test_benchmark() -> void:
	print("test: match engine benchmark...")
	var match_engine: MatchEngine = MatchEngine.new()
	match_engine.setup(Tests.create_mock_team(), Tests.create_mock_team(), 123)
	match_engine.simulate()
	print("test: match engine benchmark done.")
