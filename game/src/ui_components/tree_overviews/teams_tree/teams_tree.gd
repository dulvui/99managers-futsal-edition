# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamsTree
extends VBoxContainer

signal team_selected(team: Team)

var teams: Dictionary
var items: Array[TreeItem]

@onready var search_line_edit: SearchLineEdit = %SearchLineEdit
@onready var tree: Tree = %Tree


func _ready() -> void:
	if Tests.setup_mock_world(true):
		setup()


func setup(_include_national_teams: bool = false) -> void:
	_initialize_tree()


func select(team_name: String) -> void:
	tree.deselect_all()
	# set selected item
	for item: TreeItem in items:
		if is_instance_valid(item):
			if item.get_text(0) == team_name:
				tree.set_selected(item, 0)
				return


func _initialize_tree(search_string: String = "") -> void:
	tree.clear()	
	teams = {}
	items = []

	# world competitons
	var continents_item: TreeItem = _create_item("CONTINENTS")
	# continents
	for continent: Continent in Global.world.continents:
		if continent.is_competitive():
			var continent_item: TreeItem = _create_item(continent.name, continents_item)
			# nations
			for nation: Nation in continent.nations:
				if nation.is_competitive():
					var nation_item: TreeItem = _create_item(nation.name, continent_item)
					# nation leagues
					for league: League in nation.leagues:
						var league_item: TreeItem = _create_item(league.name, nation_item)
						for team: Team in league.teams:
							_create_item(team.name, league_item, team, search_string)
	
	# remove empty tree items
	if not search_string.is_empty():
		# check 4 times, to remove also empty continents and world
		for i: int in 4:
			var empty_tree_items: Array[TreeItem] = []
			for tree_item: TreeItem in items:
				if not search_string in tree_item.get_text(0).to_lower() and tree_item.get_child_count() == 0:
					empty_tree_items.append(tree_item)
			for tree_item: TreeItem in empty_tree_items:
				items.erase(tree_item)
				tree_item.free()

		if items.is_empty():
			_create_item("NO_TEAM_FOUND")


func _create_item(
	text: String,
	parent: TreeItem = null,
	team: Team = null,
	search_string: String = "",
	) -> TreeItem:
	# filter by search	
	if not search_string.is_empty() and not search_string in text.to_lower():
		return null
	
	var item: TreeItem
	if parent:
		item = parent.create_child()
	else:
		item = tree.create_item()
	item.set_text(0, text)
	items.append(item)

	if team:
		teams[team.name] = team

	return item


func _on_search_line_edit_text_changed(new_text: String) -> void:
	_initialize_tree(new_text.to_lower())


func _on_tree_item_mouse_selected(_mouse_position: Vector2, _mouse_button_index: int) -> void:
	_on_select()


func _on_tree_item_activated() -> void:
	_on_select()


func _on_select() -> void:
	var selected_name: String = tree.get_selected().get_text(0)
	if teams.has(selected_name):
		team_selected.emit(teams[selected_name])
		SoundUtil.play_button_sfx()
