# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Knockout
extends JSONResource

# single or two-legged matches
enum Legs {
	SINGLE,
	DOUBLE,
}

# side a and side b of knockout graph
# final is last remaining of teams_a vs teams_b
@export var teams_a: Array[TeamBasic]
@export var teams_b: Array[TeamBasic]
# defines if the play once or twice against each other
@export var legs_semi_finals: Legs
@export var legs_final: Legs
# saves all matches in every round, for easier visualization
@export var rounds: int
@export var rounds_a: Array[KnockoutRound]
@export var rounds_b: Array[KnockoutRound]
@export var final: Match


func _init(
	p_teams_a: Array[TeamBasic] = [],
	p_teams_b: Array[TeamBasic] = [],
	p_legs_semi_finals: Legs = Legs.DOUBLE,
	p_legs_final: Legs = Legs.SINGLE,
	p_rounds: int = 1,
	p_rounds_a: Array[KnockoutRound] = [],
	p_rounds_b: Array[KnockoutRound] = [],
	p_final: Match = null,
) -> void:
	teams_a = p_teams_a
	teams_b = p_teams_b
	legs_semi_finals = p_legs_semi_finals
	legs_final = p_legs_final
	rounds = p_rounds
	rounds_a = p_rounds_a
	rounds_b = p_rounds_b
	final = p_final


func setup(
	p_teams: Array[Team],
	p_legs_semi_finals: Legs = Legs.DOUBLE,
	p_legs_final: Legs = Legs.SINGLE,
) -> void:
	legs_semi_finals = p_legs_semi_finals
	legs_final = p_legs_final
	# sort teams by presitge
	p_teams.sort_custom(func(a: Team, b: Team) -> bool: return a.get_prestige() > b.get_prestige())

	# adjust teams size, to fit knockout format, sicne can only be 32,16,8,4,2
	if p_teams.size() >= 32:
		p_teams = p_teams.slice(0, 32)
		rounds = 4
	elif p_teams.size() >= 16:
		p_teams = p_teams.slice(0, 16)
		rounds = 3
	elif p_teams.size() >= 8:
		p_teams = p_teams.slice(0, 8)
		rounds = 2
	elif p_teams.size() >= 4:
		p_teams = p_teams.slice(0, 4)
		rounds = 1
	elif p_teams.size() >= 2:
		p_teams = p_teams.slice(0, 2)
		rounds = 0
	else:
		print("error while setting up knockout, not enouh teams")
		return

	# add teams alterning to part a/b
	for i: int in p_teams.size():
		if i % 2 == 0:
			teams_a.append(p_teams[i].get_basic())
		else:
			teams_b.append(p_teams[i].get_basic())


func get_matches(cup: Cup) -> Array[Array]:
	var matches: Array[Array] = []
	# semifinals
	if teams_a.size() > 1:
		var match_day: Array[Match] = []
		var round_a: KnockoutRound = KnockoutRound.new()
		var round_b: KnockoutRound = KnockoutRound.new()
		
		# group a
		for i: int in teams_a.size() / 2:
			# assign first vs last, first + 1 vs last - 1 etc...
			var matchz: Match = Match.new()
			matchz.setup(teams_a[i], teams_a[-(i + 1)], cup.id, cup.name)
			match_day.append(matchz)
			# save also in matches by round
			round_a.matches.append(matchz)
		rounds_a.append(round_a)

		# group b
		for i: int in teams_b.size() / 2:
			# assign first vs last, first + 1 vs last - 1 etc...
			var matchz: Match = Match.new()
			matchz.setup(teams_b[i], teams_b[-(i + 1)], cup.id, cup.name)
			match_day.append(matchz)
			# save also in matches by round
			round_b.matches.append(matchz)
		rounds_b.append(round_b)

		matches.append(match_day)

		# second leg
		if legs_semi_finals == Knockout.Legs.DOUBLE:
			# second leg
			var match_day_2: Array[Match] = []
			var round_a_2: KnockoutRound = KnockoutRound.new()
			var round_b_2: KnockoutRound = KnockoutRound.new()

			# iterate over all matches of match day 1 and invert home/away
			# group a
			for matchz_1: Match in rounds_a[-1].matches:
				var matchz: Match = matchz_1.inverted(true)
				matchz.no_draw = true
				match_day_2.append(matchz)
				# save also in matches by round
				round_a_2.matches.append(matchz)
			rounds_a.append(round_a_2)

			# group b
			for matchz_1: Match in rounds_b[-1].matches:
				var matchz: Match = matchz_1.inverted(true)
				matchz.no_draw = true
				match_day_2.append(matchz)
				# save also in matches by round
				round_b_2.matches.append(matchz)
			rounds_b.append(round_b_2)

			matches.append(match_day_2)

	elif teams_a.size() == 1 and teams_b.size() == 1:
		# final match
		var matchz: Match = Match.new()
		matchz.setup(teams_a[0], teams_b[0], cup.id, cup.name)
		var final_match_day: Array[Match] = [matchz]
		matches.append(final_match_day)

		# second leg
		if legs_final == Legs.DOUBLE:
			var matchz_2: Match = matchz.inverted(true)
			matchz_2.no_draw = true
			matches.append_array([matchz_2])

	return matches


func prepare_next_round() -> bool:
	if rounds_a.size() * rounds_b.size() == 0:
		print("error during preparing next round of knockout, no matches found")
		return false

	var a_ready: bool = _prepare_next_round(rounds_a[-1], teams_a)
	var b_ready: bool = _prepare_next_round(rounds_b[-1], teams_b)

	if a_ready != b_ready:
		print("error during preparing next round of knockout, group a and b are both ready")
		return false

	return a_ready and b_ready


func _prepare_next_round(p_round: KnockoutRound, teams: Array[TeamBasic]) -> bool:
	for matchz: Match in p_round.matches:
		if not matchz.over:
			return false

	# eliminate teams
	for matchz: Match in p_round.matches:
		if legs_semi_finals == Legs.SINGLE:
			if matchz.home_goals > matchz.away_goals:
				teams.erase(matchz.away)
			else:
				teams.erase(matchz.home)
		else:
			# search for matches with fist leg reference
			if matchz.first_leg != null:
				var first_leg: Match = matchz.first_leg

				var team_1_goal_sum: int = first_leg.home_goals + matchz.away_goals
				var team_2_goal_sum: int = first_leg.away_goals + matchz.home_goals

				if team_1_goal_sum > team_2_goal_sum:
					teams.erase(first_leg.home)
				else:
					teams.erase(first_leg.away)
	return true
