# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal loaded

enum Type {
	INITIALIZE_GAME,
	LOAD_GAME,
	SAVE_GAME,
	MATCH_RESULTS,
	NEXT_SEASON,
	GENERATION,
}

var progress: float
var message: String
var type: Type
var indeterminate: bool


func start(p_message: String, p_type: Type, p_indeterminate: bool = false) -> void:
	message = p_message
	type = p_type
	indeterminate = p_indeterminate
	progress = 0


func update(p_progress: float) -> void:
	progress = p_progress


func done() -> void:
	loaded.emit()
