extends Area2D

export (String, "G", "D", "WL", "WR", "P") var pos = "G"

signal shoot
signal pass_to
signal pass_out # if he makes bad pas then ball goes out of field
signal dribble
signal wait
signal move_up
signal move_down

var sector_pos

var max_sector
var min_sector

var wait_counter = 0 # counts waits and after x  waits do action


var stats = {
	"goals" : 0,
	"shots" : 0,
	"shots_on_target" : 0,
	"passes" : 0,
	"passes_success" : 0,
	"dribblings" : 0,
	"dribblings_success" : 0,
	"tackling" : 0,
	"tackling_success" : 0,
	"meters_run" : 0,
}

var player
var surname = ""

onready var ball = get_parent().get_node("Ball")

export var shirt_number = "1"
export var shirt_color = Color.red

var ball_pos

var has_ball = false #probably detects when ball enters Ball detector

func _ready():
	ball_pos = $BallPosition.global_position

	

func update_decision(team_has_ball,has_ball):
	if team_has_ball:
		if has_ball:
			make_offensive_with_ball_decision()
		else:
			make_offensive_no_ball_decision()
	else:
		make_defensive_decision()
		
	
func set_up(new_player,field_pos):
	player = new_player
	if player["home"]:
		sector_pos = (field_pos+1) * 200
	else:
		sector_pos = 1200 -( (field_pos+1) * 200)
	
	min_sector = sector_pos - 300
	if min_sector < 0:
		min_sector = 0
	max_sector = sector_pos + 300
	if max_sector > 1200:
		max_sector = 1200
	
	
#	$Control/ShirtNumber.text = str(player["nr"])
#	$Control/ColorRect.color = color

func make_offensive_with_ball_decision():
	print(player["surname"] + " has ball")
	
	# make all checks and the make decision
	var shoot_factor = check_shoot()
	var pass_factor = check_pass()
	var move_up_factor = check_move_up()
	var move_down_factor = check_move_down()
	var wait_factor = randi()%20
	
	var sum: int = shoot_factor + pass_factor + move_up_factor + move_down_factor + wait_factor
	var decision_factor = randi()%sum
	
	if decision_factor < shoot_factor:
		print("SHOOTS")
		emit_signal("shoot",player)
	elif decision_factor < shoot_factor + pass_factor:
		print("PASS")
		emit_signal("pass_to",player)
	elif decision_factor < shoot_factor + pass_factor + move_up_factor:
		print("MOVES UP")
		move_up()
		emit_signal("move_up",player)
	elif decision_factor < shoot_factor + pass_factor + move_up_factor + move_down_factor:
		print("MOVES DOWN")
		move_down()
		emit_signal("move_down",player)
	else:
		print("WAITS")
		emit_signal("wait",player)
	
	
func make_offensive_no_ball_decision():
	print(player["surname"] + " team has ball")
	
	var move_down_factor = check_move_down()
	var move_up_factor = check_move_up()
	var wait_factor = randi()%20 # make depending on player stats and tema mentality
	
	var sum = move_up_factor + move_down_factor + wait_factor
	var decision_factor = randi()%sum
	
	if decision_factor < move_up_factor:
		print("MOVES UP")
		move_up()
		emit_signal("move_up",player)
	elif decision_factor < move_up_factor + move_down_factor:
		print("MOVES DOWN")
		move_down()
		emit_signal("move_down",player)
	else:
		print("WAITS")
		emit_signal("wait",player)
func make_defensive_decision():
	# check which sector has most opponent players and with ball and move there
	print(player["surname"] + " defends")
	
	var move_down_factor = check_move_down()
	var move_up_factor = check_move_up()
	var wait_factor = randi()%20 # make depending on player stats and tema mentality
	
	var decision_factor = randi()%(move_up_factor + move_down_factor + wait_factor)
	
	if decision_factor < move_up_factor:
		print("MOVES UP")
		emit_signal("move_up",player)
		move_down()
	elif decision_factor < move_up_factor + move_down_factor:
		print("MOVES DOWN")
		emit_signal("move_down",player)
		move_up()
	else:
		print("WAITS")
		emit_signal("wait",player)
	
func check_shoot():
	# check team mentality, if shooting from distance already shooting from far sectors
	var shoot_factor = get_sector() + 8 # +8 to make max 20
	var opponent_players_in_sector = get_parent().get_team_players_in_sector(!player["home"],sector_pos)
	shoot_factor -= opponent_players_in_sector.size() * 4
	shoot_factor = max(shoot_factor,0)
	return shoot_factor
	
	
	
func check_pass():
	#add player vision affect
	#add pass mentality
	var pass_factor = 0 
	var opponent_players_in_sector = get_parent().get_team_players_in_sector(!player["home"],sector_pos)
	var team_players_in_sector = get_parent().get_team_players_in_sector(player["home"],sector_pos)
	pass_factor -= opponent_players_in_sector.size() * 3
	pass_factor += opponent_players_in_sector.size() * 5
	pass_factor = max(pass_factor,0)
	return pass_factor
	
func check_move_up():
	# check opponentn players in next secor, if no players move up imedialtly
	var move_factor = 20
	var opponent_players_in_next_sector = []
	var team_players_in_next_sector = []
	if sector_pos < 1000:
		opponent_players_in_next_sector = get_parent().get_team_players_in_sector(!player["home"],sector_pos + 200)
		team_players_in_next_sector = get_parent().get_team_players_in_sector(player["home"],sector_pos + 200)
	move_factor -= opponent_players_in_next_sector.size() * 4
	move_factor += team_players_in_next_sector.size() * 5
	move_factor = min(move_factor,20)
	return move_factor
	
func check_move_down():
	var move_factor = 20
	var opponent_players_in_prev_sector = []
	var team_players_in_prev_sector = []
	if sector_pos > 200:
		opponent_players_in_prev_sector = get_parent().get_team_players_in_sector(!player["home"],sector_pos + 200)
		team_players_in_prev_sector = get_parent().get_team_players_in_sector(player["home"],sector_pos + 200)
	move_factor -= opponent_players_in_prev_sector.size() * 4
	move_factor += team_players_in_prev_sector.size() * 5
	move_factor = min(move_factor,20)
	return move_factor
	
func move_down():
	if player["home"]:
		sector_pos -= player["fisical"]["pace"]
	else:
		sector_pos += player["fisical"]["pace"]
	if sector_pos > max_sector:
		sector_pos = max_sector
	if sector_pos < min_sector:
		sector_pos = min_sector

# special movements: cornerns, penlaties, free kicks, kick off, rimessa
func move_up():
	if player["home"]:
		sector_pos += player["fisical"]["pace"]
	else:
		sector_pos -= player["fisical"]["pace"]
	if sector_pos > max_sector:
		sector_pos = max_sector
	if sector_pos < min_sector:
		sector_pos = min_sector
	
func get_sector():
	if player["home"]:
		return  sector_pos / 200
	else:
		return 12 - (sector_pos / 200)
	
