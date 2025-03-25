# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualCompetitions
extends HBoxContainer

const MatchInfoScene: PackedScene = preload(Const.SCENE_MATCH_INFO)
const VisualTableScene: PackedScene = preload(
	"res://src/ui_components/visual_competitions/visual_table/visual_table.tscn"
)
const VisualKnockoutScene: PackedScene = preload(
	"res://src/ui_components/visual_competitions/visual_knockout/visual_knockout.tscn"
)

var competition: Competition
var season_index: int
var season_amount: int

var active_league: League
var active_national_cup: Cup
var active_continental_cup: Cup

@onready var active_league_button: Button = %ActiveLeagueButton
@onready var active_national_cup_button: Button = %ActiveNationalCupButton
@onready var active_continental_cup_button: Button = %ActiveContinentalCupButton

@onready var seasons_button: SwitchOptionButton = %SeasonsButton
@onready var competition_name: Label = %CompetitionName

@onready var overview: VBoxContainer = %Overview
@onready var overview_scroll: ScrollContainer = %OverviewScroll
@onready var match_list: VBoxContainer = %MatchList
@onready var match_scroll: ScrollContainer = %MatchListScroll
@onready var competitions_tree: CompetitionsTree = %CompetitionsTree


func _ready() -> void:
	Tests.setup_mock_world(true)
	
	active_league = Global.league
	active_national_cup = Global.world.get_active_nation().cup
	active_continental_cup = Global.world.get_active_continent().cup_clubs

	season_index = active_league.history_tables.size() + 1
	season_amount = active_league.history_tables.size() + 1
	
	active_league_button.text = active_league.name
	active_national_cup_button.text = active_national_cup.name
	active_continental_cup_button.text = active_continental_cup.name

	_setup_seasons()
	competition = active_league
	competitions_tree.setup(competition.name)
	_setup()


func _setup() -> void:
	# clean overview
	for child: Node in overview.get_children():
		child.queue_free()
	# clean match list
	for child: Node in match_list.get_children():
		child.queue_free()
	
	# reset scroll position
	match_scroll.scroll_horizontal = 0
	match_scroll.scroll_vertical = 0
	overview_scroll.scroll_horizontal = 0
	overview_scroll.scroll_vertical = 0
	
	# overview
	competition_name.text = competition.name
	if competition is League:
		var league: League = competition as League

		# playoffs
		if league.playoff_teams > 0:
			var playoffs: Cup = league.playoffs
			if season_index < season_amount:
				playoffs = league.history_playoffs[season_index - 1]
			if playoffs.is_started():
				var visual_playoffs: VisualKnockout = VisualKnockoutScene.instantiate()
				overview.add_child(visual_playoffs)
				visual_playoffs.setup(playoffs.knockout, tr("Playoffs"))

		# playouts
		if league.playout_teams > 0:
			var playouts: Cup = league.playouts
			if season_index < season_amount:
				playouts = league.history_playouts[season_index - 1]
			if playouts.is_started():
				var visual_playouts: VisualKnockout = VisualKnockoutScene.instantiate()
				overview.add_child(visual_playouts)
				visual_playouts.setup(playouts.knockout, tr("Playouts"))
		
		# table
		var visual_table: VisualTable = VisualTableScene.instantiate()
		var table: Table = league.table
		if season_index < season_amount:
			table = league.history_tables[season_index - 1]

		overview.add_child(visual_table)
		visual_table.setup(
			table,
			league.direct_promotion_teams,
			league.playoff_teams,
			league.direct_relegation_teams,
			league.playout_teams,
		)
	else:
		var cup: Cup = competition as Cup

		# groups
		for group: Group in cup.groups:
			# label
			var group_label: Label = Label.new()
			var index: int = cup.groups.find(group) + 1
			group_label.text = tr("Group") + " " + str(index)
			ThemeUtil.bold(group_label)
			overview.add_child(group_label)
			# table
			var table: VisualTable = VisualTableScene.instantiate()
			overview.add_child(table)
			table.setup(group.table)
			overview.add_child(HSeparator.new())

		# knockout
		var knockout: VisualKnockout = VisualKnockoutScene.instantiate()
		overview.add_child(knockout)
		knockout.setup(cup.knockout)

	# matches
	for day: Day in Global.world.calendar.get_all_matchdays_by_competition(competition.id):
		var day_label: Label = Label.new()
		day_label.text = day.to_format_string()
		ThemeUtil.bold(day_label)
		match_list.add_child(day_label)

		for matchz: Match in day.get_matches(competition.id):
			var match_info: MatchInfo = MatchInfoScene.instantiate()
			match_list.add_child(match_info)
			match_info.setup(matchz)


func _setup_seasons() -> void:
	var start_year: int = Global.world.calendar.date.year
	var end_year: int = Global.world.calendar.date.year - season_amount

	var season_years: Array[String] = []
	for year: int in range(start_year, end_year, -1):
		season_years.append(str(year))
	seasons_button.setup(season_years)


func _on_seasons_button_item_selected(index: int) -> void:
	# substract from season amount,
	# seasons are inserted inverted in options button
	season_index = season_amount - index
	_setup()


func _on_competitions_tree_competition_selected(p_competition: Competition) -> void:
	competition = p_competition
	_setup()


func _on_active_button_pressed() -> void:
	competition = active_league
	_show_competition()


func _on_active_national_cup_button_pressed() -> void:
	competition = active_national_cup
	_show_competition()


func _on_active_continental_cup_button_pressed() -> void:
	competition = active_continental_cup
	_show_competition()


func _show_competition() -> void:
	competitions_tree.select(competition.name)
	season_index = season_amount
	seasons_button.option_button.selected = 0
	_setup()
