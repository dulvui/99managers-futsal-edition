# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimPlayer

signal interception
signal short_pass
signal shoot
signal dribble
signal pass_received

enum State {
	# defense
	PRESS,
	MARK_ZONE,
	MARK_MAN,
	# attack with ball
	BALL,
	PASS,
	FORCE_PASS,
	SHOOT,
	# attack without ball
	RECEIVE,
	SUPPORT,
	STAY_BACK,
}

const deceleration = 0.01

var state:State

# resources
var player_res:Player
var ball:SimBall
var field:SimField
var left_half:bool
# positions
var start_pos:Vector2
var pos:Vector2
# movements
var direction:Vector2
var destination:Vector2
var speed:int
# fisical attributes
var stamina:float
var interception_radius:int #TODO reduce radius with low stamina

# distances, calculated by actiopn util
var distance_to_goal:float
var distance_to_own_goal:float
var distance_to_active_player:float
var distance_to_ball:float
var distance_to_enemy:float

func set_up(
	p_player_res:Player,
	p_ball:SimBall,
) -> void:
	player_res = p_player_res
	ball = p_ball
	
	# inital test values
	destination = Vector2.INF
	interception_radius = 25
	speed = 15


func update() -> void:
	# random direction
	# will be overwritten by next steps, if needed
	if state != State.RECEIVE:
		_next_random_direction()
	
	match state:
		# DEFENSE
		State.PRESS:
			# TODO move to player with ball
			# if arrived, try to tackle
			# success => change possess
			# fail => possible foul
			if is_touching_ball():
				interception.emit()
				state = State.BALL
		State.MARK_MAN:
			# TODO move to closest player and set marked flag
			# to prevent double marking
			_next_defensive_direction()
		State.MARK_ZONE:
			# TODO move to tactical position
			# usually diamond
			_next_defensive_direction()
		# ATTACK
		State.RECEIVE:
			if is_touching_ball():
				pass_received.emit()
				state = State.BALL
				ball.stop()
		State.FORCE_PASS:
			state = State.PASS
			short_pass.emit()
		State.BALL: # if player has ball not just received
			if _should_pass():
				state = State.PASS
				short_pass.emit()
			elif _should_shoot():
				state = State.SHOOT
				shoot.emit()


func kick_off(p_pos:Vector2) -> void:
	start_pos = p_pos
	set_pos()

func act() -> void:
	# move
	if speed > 0:
		pos += direction * speed
		speed -= deceleration
		stamina -= 0.01
	
	if pos.distance_to(destination) < 20 or speed == 0:
		destination = Vector2.INF
		stop()


func is_touching_ball() -> bool:
	if Geometry2D.is_point_in_circle(ball.pos, pos, interception_radius):
		# best case 59 + 20 * 2 = 99
		# worst case 59 + 1 * 2 = 62
		return Config.match_rng.randi_range(0, 100) < 59 + player_res.attributes.technical.interception * 2
	return false


func set_pos(p_pos:Vector2 = pos) -> void:
	pos = p_pos
	# reset values
	speed = 0
	destination = Vector2.INF


func set_destination(p_destination:Vector2) -> void:
	destination = p_destination
	direction = pos.direction_to(destination)
	# TODO use speed of attributes
	speed = Config.match_rng.randi_range(10, 20)


func stop() -> void:
	speed = 0


func _should_shoot() -> bool:
	if ball.empty_net:
		return true
	if  ball.players_in_shoot_trajectory < 2:
		return Config.match_rng.randi_range(1, 100) > 95
	return false
	
	
func _should_pass() -> bool:
	if distance_to_enemy < 50:
		return Config.match_rng.randi_range(1, 100) < 60
	return false


func _next_random_direction() -> void:
	if destination == Vector2.INF:
		# random destination
		set_destination(
			bound_field(
				pos + Vector2(Config.match_rng.randi_range(-150, 150),
				Config.match_rng.randi_range(-150, 150)
				)
			)
		)
		
func _next_defensive_direction() -> void:
	pass
	# TODO get next defensive direction from team,
	# depending on tactic 
	#if destination == Vector2.INF:
		#set_destination(bound_field()))


func bound_field(p_pos:Vector2) -> Vector2:
	p_pos.x = maxi(mini(p_pos.x, 1200), 1)
	p_pos.y = maxi(mini(p_pos.y, 600), 1)
	return p_pos
	
