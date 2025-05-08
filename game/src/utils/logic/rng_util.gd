# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name RngUtil
extends RandomNumberGenerator


func _init(
	p_seed: String = "",
	player_names: Enum.PlayerNames = Enum.PlayerNames.MIXED,
) -> void:
	if not p_seed.is_empty():
		# add player names noise
		# to have different results with different player names
		p_seed += str(player_names)
		seed = hash(p_seed)


func shuffle(array: Array[Variant]) -> void:
	for i: int in array.size():
		var index: int = self.randi_range(0, array.size() - 1)
		if index != i:
			var temp: Variant = array[index]
			array[index] = array[i]
			array[i] = temp


func pick_random(array: Array[Variant]) -> Variant:
	if array.is_empty():
		return null
	return array[self.randi() % array.size() - 1]


func rand100(probability: int) -> bool:
	return randi_range(0, 100) > probability

