# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerList
extends VBoxContainer

signal select_player(player: Player)

enum Views {
	GENERAL,
	GOALKEEPER,
	PHYSICAL,
	TECHNICAL,
	MENTAL,
	CONTRACT,
	STATS,
}

# views
const ViewSceneGeneral: PackedScene = preload(Const.SCENE_PLAYER_LIST_VIEW_GENERAL)
const ViewSceneGoalkeeper: PackedScene = preload(Const.SCENE_PLAYER_LIST_VIEW_GOALKEEPER)
# rows
const RowSceneGeneral: PackedScene = preload(Const.SCENE_PLAYER_LIST_ROW_GENERAL)
const RowSceneGoalkeeper: PackedScene = preload(Const.SCENE_PLAYER_LIST_ROW_GOALKEEPER)

# depending on scale
const PAGE_SIZE_1: int = 36
const PAGE_SIZE_2: int = 22
const PAGE_SIZE_3: int = 12

var views_text: Array[String] = [
	tr("General"),
	tr("Goalkeeper"),
	tr("Physical"),
	tr("Technical"),
	tr("Mental"),
	tr("Contract"),
	tr("Stats"),
]

var active_view: Views

var active_team_id: int

var sorting: Dictionary = {}
var filters: Dictionary = {}

var all_players: Array[Player] = []
var players: Array[Player] = []
var visible_players: Array[Player] = []

var page: int
var page_max: int
var page_size: int

# filters
@onready var search_line_edit: SearchLineEdit = %NameSearch
@onready var active_view_option_button: SwitchOptionButton = %ActiveView
@onready var team_select: OptionButton = %TeamSelect
@onready var league_select: OptionButton = %LeagueSelect
@onready var pos_select: OptionButton = %PositionSelect
# view
@onready var players_view: MarginContainer = %PlayersView
# footer
@onready var footer: HBoxContainer = %Footer
@onready var page_indicator: Label = %PageIndicator
@onready var last: Button = %Last


func _ready() -> void:
	Tests.setup_mock_world()

	# filter and view buttons
	team_select.add_item(tr("All Teams"))
	for league: League in Global.world.get_all_leagues():
		for team: Team in league.teams:
			if team == null or Global.team == null or team.name != Global.team.name:
				team_select.add_item(team.name)

	pos_select.add_item(tr("All positions"))
	for pos: String in Position.Type.keys():
		pos_select.add_item(pos)

	league_select.add_item(tr("All Leagues"))
	for league: League in Global.world.get_all_leagues():
		league_select.add_item(league.name)

	active_view_option_button.setup(views_text)
	active_view = Views.GENERAL
	
	# page size scale
	match Global.config.theme_scale:
		Const.SCALE_1:
			page_size = PAGE_SIZE_1
		Const.SCALE_2:
			page_size = PAGE_SIZE_2
		Const.SCALE_3:
			page_size = PAGE_SIZE_3
	
	# setup automatically, if run in editor and is run by 'Run current scene'
	if Tests.is_run_as_current_scene(self):
		setup()


func setup(p_active_team_id: int = -1) -> void:
	active_team_id = p_active_team_id

	if active_team_id != -1:
		team_select.hide()
		league_select.hide()

	_setup_players()
	_show_active_view()


func update_team(p_active_team_id: int) -> void:
	active_team_id = p_active_team_id
	_setup_players()
	_show_active_view()


func _setup_players(p_reset_options: bool = true) -> void:
	if p_reset_options:
		_reset_options()

	all_players = []

	# uncomment to stresstest
	#for i in range(10):
	if active_team_id == -1:
		all_players.append_array(Global.world.get_all_players())
	else:
		for player: Player in Global.world.get_team_by_id(active_team_id).players:
			all_players.append(player)

	players = all_players


func _reset_options() -> void:
	league_select.selected = 0
	pos_select.selected = 0
	team_select.selected = 0


func _on_player_profile_select(player: Player) -> void:
	select_player.emit(player)

#
# views
#
func _on_active_view_item_selected(index: int) -> void:
	active_view = index as Views
	_show_active_view()


func _show_active_view(sort_key: String = "") -> void:
	_filter()
	_sort_players(sort_key)

	visible_players = players.slice(page * page_size, (page + 1) * page_size)

	match active_view:
		# Views.MENTAL:
		# 	_show_mental()
		# Views.PHYSICAL:
		# 	_show_physical()
		# Views.TECHNICAL:
		# 	_show_technical()
		Views.GOALKEEPER:
			_show_view(ViewSceneGoalkeeper, RowSceneGoalkeeper)
		# Views.CONTRACT:
		# 	_show_contract()
		# Views.STATS:
		# 	_show_statistics()
		_:
			_show_view(ViewSceneGeneral, RowSceneGeneral)

	# update page indicator
	page_max = players.size() / page_size
	page_indicator.text = "%d / %d" % [page + 1, page_max + 1]
	last.text = str(page_max + 1)



func _show_view(view_scene: PackedScene, row_scene: PackedScene) -> void:
	# TODO update instead of destroying
	for child: Node in players_view.get_children():
		child.queue_free()

	var view: PlayerListView = view_scene.instantiate()
	players_view.add_child(view)
	view.setup(visible_players, row_scene)
	view.sort.connect(_show_active_view)


#
# sorting
#
func _sort_players(sort_key: String) -> void:
	if sort_key.is_empty():
		return

	_set_sorting(sort_key)
	players.sort_custom(
		func(a: Player, b: Player) -> bool:
			if sorting[sort_key]:
				return a.sort(sort_key) > b.sort(sort_key)
			else:
				return a.sort(sort_key) < b.sort(sort_key)
	)


func _set_sorting(sort_key: String) -> void:
	if sort_key in sorting:
		sorting[sort_key] = not sorting[sort_key]
	else:
		sorting[sort_key] = true

#
# filters
#
func _filter() -> void:
	if filters.size() == 0:
		players = all_players
		return

	var filtered_players: Array[Player] = []
	var filter_counter: int = 0
	var value: String
	var key: String

	for player: Player in all_players:
		filter_counter = 0
		for i: int in filters.keys().size():
			key = filters.keys()[i]
			filter_counter += 1
			value = str(filters[key])

			if key == Const.POSITION:
				if not str(player.position.type) == value:
					filter_counter += 1
			elif not str(player[key.to_lower()]).to_lower().contains(value.to_lower()):
				filter_counter += 1

		if filter_counter == filters.size():
			filtered_players.append(player)
	players = filtered_players


func _on_name_search_text_changed(new_text: String) -> void:
	if new_text.length() > 0:
		if not Const.SURNAME in filters:
			filters[Const.SURNAME] = new_text
		elif new_text.length() > (filters[Const.SURNAME] as String).length():
			filters[Const.SURNAME] = new_text
		else:
			filters[Const.SURNAME] = new_text
	else:
		filters.erase(Const.SURNAME)
	_show_active_view()


func _on_position_select_item_selected(index: int) -> void:
	if index > 0:
		filters[Const.POSITION] = Position.Type.values()[index - 1]
	else:
		filters.erase(Const.POSITION)
	
	_show_active_view()


func _on_league_select_item_selected(index: int) -> void:
	if index > 0:
		filters["league"] = league_select.get_item_text(index)
	else:
		filters.erase("league")

	# clean team selector
	filters.erase("team")
	team_select.clear()
	team_select.add_item("All Teams")

	# adjust team picker according to selected league
	for league: League in Global.world.get_all_leagues():
		if not "league" in filters or filters["league"] == league.name:
			for team: Team in league.teams:
				if team == null or team.name != Global.team.name:
					team_select.add_item(team.name)
	
	_show_active_view()


func _on_team_select_item_selected(index: int) -> void:
	if index > 0:
		filters["team"] = team_select.get_item_text(index)
	else:
		filters.erase("team")

	_show_active_view()


#
# paginator footer
#
func _on_next_2_pressed() -> void:
	page += 5
	if page > page_max:
		page = page_max
	_show_active_view()


func _on_next_pressed() -> void:
	page += 1
	if page > page_max:
		page = 0
	_show_active_view()


func _on_prev_pressed() -> void:
	page -= 1
	if page < 0:
		page = page_max
	_show_active_view()


func _on_prev_2_pressed() -> void:
	page -= 5
	if page < 0:
		page = 0
	_show_active_view()


func _on_last_pressed() -> void:
	page = page_max
	_show_active_view()


func _on_first_pressed() -> void:
	page = 0
	_show_active_view()
