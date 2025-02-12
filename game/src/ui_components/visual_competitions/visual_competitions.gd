# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualCompetitions
extends HBoxContainer

const VisualTableScene: PackedScene = preload("res://src/ui_components/visual_competitions/visual_table/visual_table.tscn")
const VisualKnockoutScene: PackedScene = preload("res://src/ui_components/visual_competitions/visual_knockout/visual_knockout.tscn")

var competition: Competition
var season_index: int
var season_amount: int

@onready var main: VBoxContainer = %Main
@onready var active_button: Button = %ActiveButton
@onready var seasons_button: SwitchOptionButton = %SeasonsButton
@onready var competitions_tree: CompetitionsTree = %CompetitionsTree


func _ready() -> void:
	Tests.setup_mock_world(true)

	# start from last entry
	season_index = Global.league.tables.size() - 1
	season_amount = Global.league.tables.size()

	active_button.text = Global.league.name

	_setup_seasons()
	competition = Global.league
	competitions_tree.setup(competition.name)
	_setup()


func _setup() -> void:
	# clean scroll container
	for child: Node in main.get_children():
		child.queue_free()
	
	if competition is League:
		var league: League = (competition as League)
		var table: VisualTable = VisualTableScene.instantiate()
		main.add_child(table)
		table.setup(league.tables[season_index])
	else:
		var cup: Cup = (competition as Cup)

		# groups
		for group: Group in cup.groups:
			# label
			var group_label: Label = Label.new()
			var index: int = cup.groups.find(group) + 1
			group_label.text = tr("Group") + " " + str(index)
			ThemeUtil.bold(group_label)
			main.add_child(group_label)
			# table
			var table: VisualTable = VisualTableScene.instantiate()
			main.add_child(table)
			table.setup(group.table)
			main.add_child(HSeparator.new())

		# knockout
		var knockout: VisualKnockout = VisualKnockoutScene.instantiate()
		main.add_child(knockout)
		knockout.setup(cup.knockout)


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
	# -1, because arrays start from 0
	season_index = season_amount - 1 - index
	_setup()


func _on_competitions_tree_competition_selected(p_competition: Competition) -> void:
	competition = p_competition
	_setup()


func _on_active_button_pressed() -> void:
	competition = Global.league
	competitions_tree.select(competition.name)
	season_index = season_amount - 1
	seasons_button.option_button.selected = 0
	_setup()

