# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestRngUtil
extends Test


func test() -> void:
	print("test: rng util...")

	var rng_util: RngUtil = RngUtil.new("TestSeed")
	var test_rng_util: RngUtil = RngUtil.new("TestSeed")

	# randi
	for i:int in 100:
		var value: int = rng_util.randi_range(0, 10_000)
		var test_value: int = test_rng_util.randi_range(0, 10_000)
		assert(value == test_value)

	# pick random
	var array: Array[int] = []
	for i:int in 10_000:
		array.append(i)

	for i: int in 100:
		var value: int = rng_util.pick_random(array)
		var test_value: int = test_rng_util.pick_random(array)
		assert(value == test_value)

	# shuffle
	var shuffle_array: Array[int] = []
	var test_shuffle_array: Array[int] = []
	for i:int in 10_000:
		shuffle_array.append(i)
		test_shuffle_array.append(i)

	for i: int in 100:
		rng_util.shuffle(shuffle_array)
		test_rng_util.shuffle(test_shuffle_array)
		# compare
		for j: int in shuffle_array.size():
			assert(shuffle_array[j] == test_shuffle_array[j])

	print("test: rng util done.")

