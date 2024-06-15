# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerList
extends VBoxContainer

signal select_player(player: Player)

const PlayerListColumnScene = preload("res://src/ui_components/player_list/player_list_column/player_list_column.tscn")

@onready var filter_container: HBoxContainer = $Filters
@onready var team_select: OptionButton = $Filters/TeamSelect
@onready var league_select: OptionButton = $Filters/LeagueSelect
@onready var pos_select: OptionButton = $Filters/PositionSelect
@onready var footer: HBoxContainer = $Footer
@onready var page_indicator: Label = $Footer/PageIndicator
@onready var active_view_option_button: SwitchOptionButton = $Filters/ActiveView

@onready var views_container: HBoxContainer = $Views

const views:Array[String] = ["general", "mental", "physical", "technical", "goalkeeper"]
var active_view: String = views[0]

var views_list: Dictionary = {}

var active_team_id: int

var sorting: Dictionary = {}
var filters: Dictionary = {}

var all_players: Array[Player] = []
var players: Array[Player] = []
var visible_players: Array[Player] = []

var page:int
var page_max:int
var page_size:int = 16


func _ready() -> void:
	team_select.add_item("NO_TEAM")
	for league: League in Config.leagues.list:
		for team: Team in league.teams:
			if team == null or Config.team == null or team.name != Config.team.name:
				team_select.add_item(team.name)

	pos_select.add_item("NO_POS")
	for pos: String in Player.Position.keys():
		pos_select.add_item(pos)

	league_select.add_item("ALL_LEAGUES")
	for league: League in Config.leagues.list:
		league_select.add_item(league.name)
	
	active_view_option_button.set_up(views)
	
	# setup automatically, if run in editor and is run by 'Run current scene'
	if OS.has_feature("editor") and get_parent() == get_tree().root:
		set_up()

func set_up(p_active_team_id:int = -1) -> void:
	active_team_id = p_active_team_id
	
	if active_team_id != -1:
		team_select.hide()
		league_select.hide()
	
	_set_up_players()
	
	page_max = players.size() / page_size

	_set_up_columns()
	_update_page_indicator()
	_show_active_column()


func _set_up_columns() -> void:
	for child in views_container.get_children():
		child.queue_free()
	
	visible_players = players.slice(page * page_size, (page + 1) * page_size)

	# names
	var name_col: PlayerListColumn = PlayerListColumnScene.instantiate()
	views_container.add_child(name_col)
	var names: Array = visible_players.map(func(p: Player) -> String: return p.surname)
	name_col.set_up("NAME", names)
	name_col.custom_minimum_size.x = 200
	name_col.sort.connect(_sort_players.bind("surname"))
	views_list["name"] = name_col
	
	# separator
	views_container.add_child(VSeparator.new())
	

	# general
	var nat_col: PlayerListColumn = PlayerListColumnScene.instantiate()
	views_container.add_child(nat_col)
	var nationalities: Array = visible_players.map(func(p: Player) -> String: return Const.Nations.keys()[p.nation])
	nat_col.set_up("NATION", nationalities, "general")
	nat_col.sort.connect(_sort_players.bind("nation"))
	views_list["nation"] = nat_col
	
	var pos_col: PlayerListColumn = PlayerListColumnScene.instantiate()
	views_container.add_child(pos_col)
	var positions: Array = visible_players.map(func(p: Player) -> String: return Player.Position.keys()[p.position])
	pos_col.set_up("POSITION", positions, "general")
	pos_col.sort.connect(_sort_players.bind("position"))
	views_list["position"] = pos_col
	
	var price_col: PlayerListColumn = PlayerListColumnScene.instantiate()
	views_container.add_child(price_col)
	var prices: Array = visible_players.map(func(p: Player) -> String: return CurrencyUtil.get_sign(p.price))
	price_col.set_up("PRICE", prices, "general")
	price_col.sort.connect(_sort_players.bind("price"))
	views_list["price"] = price_col
	
	var birth_date_col: PlayerListColumn = PlayerListColumnScene.instantiate()
	views_container.add_child(birth_date_col)
	var birth_dates: Array = visible_players.map(func(p: Player) -> String: return Config.calendar().format_date(p.birth_date))
	birth_date_col.set_up("BIRTH DATE", birth_dates, "general")
	birth_date_col.sort.connect(_sort_players.bind("birth_date"))
	views_list["birth_date"] = birth_date_col
	
	# connect player select signal
	for i: int in visible_players.size():
		name_col.color_labels[i].enable_button()
		name_col.color_labels[i].button.pressed.connect(func() -> void: select_player.emit(visible_players[i]))
	
	# attributes
	for key: String in Const.ATTRIBUTES.keys():
		for value: String in Const.ATTRIBUTES[key]:
			var col:PlayerListColumn = PlayerListColumnScene.instantiate()
			views_container.add_child(col)
			var values: Array = visible_players.map(func(p: Player) -> int: return p.get_value(key, value))
			col.set_up(value, values, key)
			col.sort.connect(_sort_players.bind(key, value))
			views_list[value] = col


func _update_columns() -> void:
	visible_players = players.slice(page * page_size, (page + 1) * page_size)
	
	var name_col:PlayerListColumn = views_list["name"]
	var names: Array = visible_players.map(func(p: Player) -> String: return p.surname)
	name_col.update_values(names)
	# connect player select signal
	for i: int in visible_players.size():
		name_col.color_labels[i].enable_button()
		name_col.color_labels[i].button.pressed.connect(func() -> void: select_player.emit(visible_players[i]))

	var nat_col:PlayerListColumn = views_list["nation"]
	var nations: Array = visible_players.map(func(p: Player) -> String: return Const.Nations.keys()[p.nation])
	nat_col.update_values(nations)
	
	var pos_col:PlayerListColumn = views_list["position"]
	var positions: Array = visible_players.map(func(p: Player) -> String: return Player.Position.keys()[p.position])
	pos_col.update_values(positions)
	
	var price_col:PlayerListColumn = views_list["price"]
	var prices: Array = visible_players.map(func(p: Player) -> String: return CurrencyUtil.get_sign(p.price))
	price_col.update_values(prices)
	
	var birth_date_col:PlayerListColumn = views_list["birth_date"]
	var birth_date: Array = visible_players.map(func(p: Player) -> String: return Config.calendar().format_date(p.birth_date))
	birth_date_col.update_values(birth_date)
	
	# attributes
	for key: String in Const.ATTRIBUTES.keys():
		for value: String in Const.ATTRIBUTES[key]:
			var col:PlayerListColumn = views_list[value]
			var values: Array = visible_players.map(func(p: Player) -> int: return p.get_value(key, value))
			col.update_values(values)


func _show_active_column() -> void:
	for col: PlayerListColumn in views_list.values():
		col.visible = col.col_name == "" or col.col_name == active_view


func _set_up_players(p_reset_options: bool = true) -> void:
	if p_reset_options:
		_reset_options()

	all_players = []
	
	# uncomment to stresstest
	#for i in range(100):
	for league: League in Config.leagues.list:
		for team in league.teams:
			if active_team_id == -1 or active_team_id == team.id:
				for player in team.players:
					all_players.append(player)
	
	players = all_players


func _reset_options() -> void:
	league_select.selected = 0
	pos_select.selected = 0
	team_select.selected = 0


func _on_player_profile_select(player: Player) -> void:
	select_player.emit(player)


func _on_next_2_pressed() -> void:
	page += 5
	if page > page_max:
		page = page_max
	_update_page_indicator()
	_update_columns()


func _on_next_pressed() -> void:
	page += 1
	if page > page_max:
		page = 0
	_update_page_indicator()
	_update_columns()


func _on_prev_pressed() -> void:
	page -= 1
	if page < 0:
		page = page_max
	_update_page_indicator()
	_update_columns()


func _on_prev_2_pressed() -> void:
	page -= 5
	if page < 0:
		page = 0
	_update_page_indicator()
	_update_columns()


func _update_page_indicator() -> void:
	page_max = players.size() / page_size
	page_indicator.text = "%d / %d" % [page + 1, page_max + 1]


func _sort_players(key: String, value: String = "") -> void:
	var sort_key: String = key + value
	if sort_key in sorting:
		sorting[sort_key] = not sorting[sort_key]
	else:
		sorting[sort_key] = true
	
	if value != "":
		# attributes
		all_players.sort_custom(
			func(a:Player, b:Player) -> bool:
				if sorting[sort_key]:
					return a.get_value(key, value) > b.get_value(key, value)
				else:
					return a.get_value(key, value) < b.get_value(key, value)
		)
	elif "date" in key:
		# dates
		all_players.sort_custom(
			func(a:Player, b:Player) -> bool:
				var a_unix: int = Time.get_unix_time_from_datetime_dict(a.get(key))
				var b_unix: int = Time.get_unix_time_from_datetime_dict(b.get(key))
				if sorting[sort_key]:
					return a_unix > b_unix
				else:
					return a_unix < b_unix
		)
	else:
		# normal properties
		all_players.sort_custom(
			func(a:Player, b:Player) -> bool:
				if sorting[sort_key]:
					return a.get(key) > b.get(key)
				else:
					return a.get(key) < b.get(key)
		)
	
	# after sorting, apply filters
	# so if filters a removed, sort order is kept
	_filter_players(all_players)


func _filter() -> void:
	_filter_players(players)


func _unfilter() -> void:
	_filter_players(all_players)


func _filter_players(player_base: Array[Player]) -> void:
	page = 0
	
	if filters.size() > 0:
		var filtered_players: Array[Player] = []
		var filter_counter: int = 0
		var value: String
		var key: String
		
		for player in player_base:
			filter_counter = 0
			for i:int in filters.keys().size():
				key = filters.keys()[i]
				filter_counter += 1
				value = str(filters[key])
				value = value.to_upper()
				if not str(player[key]).to_upper().contains(value):
					filter_counter += 1
			if filter_counter == filters.size():
				filtered_players.append(player)
		players = filtered_players
	else:
		players = all_players

	_update_columns()
	_update_page_indicator()


func _on_name_search_text_changed(new_text: String) -> void:
	if new_text.length() > 0:
		if not "surname" in filters:
			filters["surname"] = new_text
			_filter()
		elif new_text.length() > (filters["surname"] as String).length():
			filters["surname"] = new_text
			_filter()
		else:
			filters["surname"] = new_text
			_unfilter()
	else:
		filters.erase("surname")
		_unfilter()


func _on_position_select_item_selected(index: int) -> void:
	if index > 0:
		filters["position"] = Player.Position.values()[index - 1]
		_filter()
	else:
		filters.erase("position")
		_unfilter()


func _on_league_select_item_selected(index: int) -> void:
	if index > 0:
		filters["league"] = league_select.get_item_text(index)
		_filter()
	else:
		filters.erase("league")
		_unfilter()

	# clean team selector
	team_select.clear()
	team_select.add_item("NO_TEAM")

	# adjust team picker according to selected league
	for league: League in Config.leagues.list:
		if not "league" in filters or filters["league"] == league.name:
			for team: Team in league.teams:
				if team == null or team.name != Config.team.name:
					team_select.add_item(team.name)


func _on_team_select_item_selected(index: int) -> void:
	if index > 0:
		filters["team"] = team_select.get_item_text(index)
		_filter()
	else:
		filters.erase("team")
		_unfilter()


func _on_active_view_item_selected(index: int) -> void:
	active_view = views[index]
	_show_active_column()
