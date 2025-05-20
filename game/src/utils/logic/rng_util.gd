# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name RngUtil

# use internal rng and not extend by it
# to prevent accidental @Global function calls
# that breaks deterministic behavior
var _rng: RandomNumberGenerator


func _init(
	p_seed: String = "",
	player_names: Enum.PlayerNames = Enum.PlayerNames.MIXED,
) -> void:
	_rng = RandomNumberGenerator.new()

	if not p_seed.is_empty():
		# add player names noise
		# to have different results with different player names
		p_seed += str(player_names)
		_rng.seed = hash(p_seed)


func shuffle(array: Array[Variant]) -> void:
	for i: int in array.size():
		var index: int = _rng.randi_range(0, array.size() - 1)
		if index != i:
			var temp: Variant = array[index]
			array[index] = array[i]
			array[i] = temp


func pick_random(array: Array[Variant]) -> Variant:
	if array.is_empty():
		return null
	return array[_rng.randi() % array.size() - 1]


func rand100(probability: int) -> bool:
	return _rng.randi_range(0, 100) > probability


func randi_range(from: int, to: int) -> int:
	return _rng.randi_range(from, to)


func randf_range(from: float, to: float) -> float:
	return _rng.randf_range(from, to)


func randi() -> int:
	return _rng.randi()


func randf() -> float:
	return _rng.randf()


func randomize() -> void:
	return _rng.randomize()


func rand_weighted(weights: PackedFloat32Array) -> int:
	return _rng.rand_weighted(weights)

