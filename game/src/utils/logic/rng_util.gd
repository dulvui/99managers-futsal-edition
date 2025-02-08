# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

var rng: RandomNumberGenerator


func setup_rngs() -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = hash(Global.generation_seed) + Global.generation_player_names
	rng.state = Global.generation_state


func reset_seed(p_generation_seed: String, p_generation_player_names: int) -> void:
	Global.generation_seed = p_generation_seed
	Global.generation_player_names = p_generation_player_names as Enum.PlayerNames

	rng = RandomNumberGenerator.new()
	rng.seed = hash(Global.generation_seed + str(Global.generation_player_names))
	Global.generation_state = rng.state


# shuffle array using global RuandomNumberGenerator
func shuffle(array: Array[Variant]) -> void:
	for i in array.size():
		var index: int = rng.randi_range(0, array.size() - 1)
		if index != i:
			var temp: Variant = array[index]
			array[index] = array[i]
			array[i] = temp


# shuffle array using global RuandomNumberGenerator
func pick_random(array: Array[Variant]) -> Variant:
	return array[rng.randi() % array.size() - 1]


func uuid() -> String:
	# generate random seed like 26374-28372-887463
	return (
		str(randi_range(100000, 999999))
		+ "-"
		+ str(randi_range(100000, 999999))
		+ "-"
		+ str(randi_range(100000, 999999))
	)
