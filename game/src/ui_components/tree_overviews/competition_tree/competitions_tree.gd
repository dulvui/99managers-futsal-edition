# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CompetitionsTree
extends VBoxContainer

signal competition_selected(competition: Competition)

# [competition name][TreeItem]
var competition_name: String
var competitions: Dictionary
var items: Array[TreeItem]

@onready var search_line_edit: SearchLineEdit = %SearchLineEdit
@onready var tree: Tree = %Tree


func _ready() -> void:
	if Tests.setup_mock_world(true):
		setup()


func setup(p_competition_name: String = "") -> void:
	competition_name = p_competition_name
	_initialize_tree()


func select(p_competition_name: String) -> void:
	tree.deselect_all()
	# set selected item
	for item: TreeItem in items:
		if is_instance_valid(item):
			if item.get_text(0) == p_competition_name:
				tree.set_selected(item, 0)
				return


func _initialize_tree(search_string: String = "") -> void:
	tree.clear()
	competitions = {}
	items = []
	
	# world competitons
	var world_item: TreeItem = _create_item("WORLD")
	_create_item("WORLD CUP", world_item, Global.world.world_cup, search_string)
	var continents_item: TreeItem = _create_item("CONTINENTS", world_item)
	# continents
	for continent: Continent in Global.world.continents:
		if continent.is_competitive():
			var continent_item: TreeItem = _create_item(continent.name, continents_item)
			# nations
			for nation: Nation in continent.nations:
				# check if nation has leagues ecc..
				if nation.is_competitive():
					var nation_item: TreeItem = _create_item(nation.name, continent_item)
					# nation leagues
					for league: League in nation.leagues:
						_create_item(league.name, nation_item, league, search_string)
					# nation cups
					_create_item(nation.cup.name, nation_item, nation.cup, search_string)
			# continental cups
			_create_item(continent.cup_clubs.name, continent_item, continent.cup_clubs, search_string)
			_create_item(continent.cup_nations.name, continent_item, continent.cup_nations, search_string)
	

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
			_create_item("NO_COMPETITION_FOUND")
	
	select(competition_name)


func _create_item(
	text: String,
	parent: TreeItem = null,
	competition: Competition = null,
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

	if competition:
		competitions[competition.name] = competition

	return item


func _on_search_line_edit_text_changed(new_text: String) -> void:
	_initialize_tree(new_text.to_lower())


func _on_tree_item_mouse_selected(_mouse_position: Vector2, _mouse_button_index: int) -> void:
	_on_select()


func _on_tree_item_activated() -> void:
	_on_select()


func _on_select() -> void:
	var selected_name: String = tree.get_selected().get_text(0)
	if competitions.has(selected_name):
		competition_selected.emit(competitions[selected_name])
		SoundUtil.play_button_sfx()
