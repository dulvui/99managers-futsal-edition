# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name LoadingScreen
extends Control

signal loaded

var progress: float
var message: String
var indeterminate: bool

@onready var loading_progress_bar: ProgressBar = %LoadingProgressBar
@onready var message_label: Label = %Message


func start(p_message: String, p_indeterminate: bool = false) -> void:
	message = p_message
	indeterminate = p_indeterminate
	progress = 0


func update(p_progress: float) -> void:
	progress = p_progress
	loading_progress_bar.value = progress


func update_message(p_message: String) -> void:
	message = p_message
	message_label.text = message
	queue_redraw()


func _loaded() -> void:
	hide()
	loaded.emit()


func _on_visibility_changed() -> void:
	if is_node_ready() and visible:
		loading_progress_bar.value = 0
		loading_progress_bar.indeterminate = indeterminate
		message_label.text = message
		loading_progress_bar.value = progress

