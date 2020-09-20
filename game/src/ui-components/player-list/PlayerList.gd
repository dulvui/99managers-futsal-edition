extends Control

signal select_player

const PlayerProfile = preload("res://src/ui-components/player-profile/PlayerProfile.tscn")

var name_search = ""
var team_search = ""

func _ready():
	$LegaueSelect.add_item("ITALIA")
	
	$TeamSelect.add_item("NO_TEAM")
	for team in DataSaver.teams:
		if team["name"] != DataSaver.selected_team:
			$TeamSelect.add_item(team["name"])
func add_players():
	for child in $ScrollContainer/ItemList.get_children():
		child.queue_free()
		
	var team = DataSaver.get_selected_team()
	for player in team["players"]["active"]:
		var player_profile = PlayerProfile.instance()
		player_profile.connect("player_select",self,"select_player",[player])
		$ScrollContainer/ItemList.add_child(player_profile)
		player_profile.set_up_info(player)
	
	for player in team["players"]["subs"]:
		var player_profile = PlayerProfile.instance()
		player_profile.connect("player_select",self,"select_player",[player])
		$ScrollContainer/ItemList.add_child(player_profile)
		player_profile.set_up_info(player)
		
func add_match_players():
	var team = DataSaver.get_selected_team()
	for player in team["players"]["active"]:
		var player_profile = PlayerProfile.instance()
		player_profile.connect("player_select",self,"select_player",[player])
		$ScrollContainer/ItemList.add_child(player_profile)
		player_profile.set_up_info(player)
	
	for player in team["players"]["subs"].slice(0,9):
		var player_profile = PlayerProfile.instance()
		player_profile.connect("player_select",self,"select_player",[player])
		$ScrollContainer/ItemList.add_child(player_profile)
		player_profile.set_up_info(player)
	
		
func add_all_players():
	for child in $ScrollContainer/ItemList.get_children():
		child.queue_free()
	for team in DataSaver.teams:
		if team["name"] != DataSaver.selected_team:
			for player in team["players"]["subs"]:
				if filter_player(player):
					var player_profile = PlayerProfile.instance()
					player_profile.connect("player_select",self,"select_player",[player])
					player_profile.set_up_info(player)
					$ScrollContainer/ItemList.add_child(player_profile)
				
			for player in team["players"]["active"]:
				if filter_player(player):
					var player_profile = PlayerProfile.instance()
					player_profile.connect("player_select",self,"select_player",[player])
					player_profile.set_up_info(player)
					$ScrollContainer/ItemList.add_child(player_profile)
			
			
func select_player(player):
	print("change in lst")
	emit_signal("select_player",player)
		
func filter_player(player):
	if name_search.length() == 0 or name_search.to_upper() in player["surname"].to_upper():
		if team_search.length() == 0 or team_search == player["team"]:
			return true
		else:
			return false
	return false

func _on_NameSearch_text_changed(new_text):
	name_search = new_text
	add_all_players()


func _on_TeamSelect_item_selected(index):
	var teams = []
	for team in DataSaver.teams:
		if team["name"] != DataSaver.selected_team:
			teams.append(team)
	
	if index > 0:
		team_search = teams[index-1]["name"]
	else:
		team_search = ""
	add_all_players()
