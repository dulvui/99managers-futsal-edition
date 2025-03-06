# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListView
extends VBoxContainer

signal selected(player: Player)
signal sort(sort_key: String)

@onready var header: PlayerListHeader = %Header
@onready var rows: VBoxContainer = %Rows


func _ready() -> void:
	var children: Array[Node] = header.buttons.get_children()
	for i: int in children.size():
		if children[i] is PlayerListSortButton:
			var button: PlayerListSortButton = children[i] as PlayerListSortButton
			button.pressed.connect(func() -> void: sort.emit(button.sort_key))



func setup(players: Array[Player], row_scene: PackedScene) -> void:
	if row_scene == null:
		return

	# TODO update instead of destroying
	# for child: Node in rows.get_children():
	# 	child.queue_free()

	for player: Player in players:
		var row: PlayerListRow = row_scene.instantiate()
		row.selected.connect(func() -> void: selected.emit(player))
		rows.add_child(row)
		row.setup(player)


func _on_player_list_header_sort(index: int) -> void:
	sort.emit(index)
