# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name RngUtil
extends RandomNumberGenerator


func _init(
	p_generation_seed: String = "",
	p_generation_player_names: Enum.PlayerNames = Enum.PlayerNames.MIXED,
) -> void:
	if p_generation_seed.is_empty():
		seed = hash(Global.generation_seed) + Global.generation_player_names
	else:
		seed = hash(p_generation_seed) + p_generation_player_names

	state = Global.generation_state


# shuffle array using global RuandomNumberGenerator
func shuffle(array: Array[Variant]) -> void:
	for i: int in array.size():
		var index: int = randi_range(0, array.size() - 1)
		if index != i:
			var temp: Variant = array[index]
			array[index] = array[i]
			array[i] = temp


# shuffle array using global RuandomNumberGenerator
func pick_random(array: Array[Variant]) -> Variant:
	if array.is_empty():
		return null
	return array[randi() % array.size() - 1]

