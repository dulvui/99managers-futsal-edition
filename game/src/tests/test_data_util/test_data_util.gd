# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestDataUtil
extends Test


func test() -> void:
	print("test: res util...")
	Global.reset_data()
	test_from_to_json()
	# Global.reset_data()
	# test_compressions()
	print("test: res util done.")


func test_from_to_json() -> void:
	var world_reference: World = Tests.create_mock_world(true)
	world_reference.world_cup.id = 123

	var world_json: Dictionary = world_reference.to_json()

	var world: World = World.new()
	world.from_json(world_json)

	# continents
	assert(world.continents.size() == world_reference.continents.size())
	assert(world.world_cup.id == world_reference.world_cup.id)
	# nations
	assert(world.continents[0].nations.size() == world_reference.continents[0].nations.size())


func test_compressions() -> void:
	var world_reference: World = Tests.create_mock_world(false)

	var world_json: Dictionary = world_reference.to_json()

	var file: FileAccess = (
		FileAccess
		. open(
			"user://world.json",
			FileAccess.WRITE,
		)
	)
	file.store_string(JSON.stringify(world_json))

	# with compressions
	var file_gzip: FileAccess = FileAccess.open_compressed(
		"user://world.json.gzip", FileAccess.WRITE, FileAccess.COMPRESSION_GZIP
	)
	file_gzip.store_string(JSON.stringify(world_json))

	var file_zstd: FileAccess = FileAccess.open_compressed(
		"user://world.json.zstd", FileAccess.WRITE, FileAccess.COMPRESSION_ZSTD
	)
	file_zstd.store_string(JSON.stringify(world_json))

	var file_deflate: FileAccess = FileAccess.open_compressed(
		"user://world.json.deflate", FileAccess.WRITE, FileAccess.COMPRESSION_DEFLATE
	)
	file_deflate.store_string(JSON.stringify(world_json))

	var file_fastlz: FileAccess = FileAccess.open_compressed(
		"user://world.json.fastlz", FileAccess.WRITE, FileAccess.COMPRESSION_FASTLZ
	)
	file_fastlz.store_string(JSON.stringify(world_json))
