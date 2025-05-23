# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control

@onready var icon: TextureRect = %Icon

@onready var teaser: VBoxContainer = %Teaser
@onready var teaser_title: Label = %Title
@onready var teaser_text: Label = %Text

@onready var content: Control = %Content

@onready var mouse_cursor: MouseCursor = %MouseCursor


func _ready() -> void:
	# apply dark theme
	Main.apply_theme(1)
	Global.config.theme_index = 1
	theme = ThemeUtil.get_active_theme()

	Tests.setup_mock_world(true)

	# search next match day, to have real team and player names
	Tests.find_next_matchday()

	mouse_cursor.hide()

	# match
	var match_scene: PackedScene = load(Const.SCREEN_MATCH)
	var match_screen: MatchScreen = match_scene.instantiate()
	content.add_child(match_screen)
	# simulate match to later state
	# match_screen.match_simulator.engine.simulate(45)

	# dashboard
	var dashboard_scene: PackedScene = load(Const.SCREEN_DASHBOARD)
	var dashboard_screen: Dashboard = dashboard_scene.instantiate()
	content.add_child(dashboard_screen)

	# set initial modulates
	icon.modulate = Color.TRANSPARENT
	match_screen.modulate = Color.TRANSPARENT
	teaser.modulate = Color.TRANSPARENT
	dashboard_screen.modulate = Color.TRANSPARENT

	Global.match_speed = Enum.MatchSpeed.FULL_GAME

	# match
	await show_screen(6, match_screen)

	# dashboard teaser
	# await show_teaser(1, "Have full control")
	# dashboard
	await show_screen(4, dashboard_screen)
	# match
	match_screen.match_simulator.engine.simulate(89)
	await show_screen(4, match_screen)
	# show formation
	# await show_teaser(1, "Choose tactics")
	dashboard_screen._on_formation_button_pressed()
	await show_screen(6, dashboard_screen)
	# show formation
	# await show_teaser(1, "Find the next talent")
	dashboard_screen._on_search_player_button_pressed()
	await show_screen(6, dashboard_screen)
	# show calendat
	# await show_teaser(1, "Plan your journey")
	dashboard_screen._on_calendar_button_pressed()
	await show_screen(6, dashboard_screen)

	# match
	match_screen.match_simulator.engine.simulate(456)
	await show_screen(4, match_screen)
	# icon
	await fade_in(icon)
	await wait(1)
	# await fade_out(icon)

	await show_teaser(2, "Get the beta version on 99managers.org")
	await show_teaser(2, "Add to your wishlist now!")

	# quit scene to finish registration
	get_tree().quit()


func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout


func show_teaser(time: float, title: String, text: String = "", do_fade_out: bool = true) -> void:
	teaser_title.text = title
	if text.is_empty():
		teaser_text.hide()
	else:
		teaser_text.show()
		teaser_text.text = text

	await fade_in(teaser)
	await wait(time)
	if do_fade_out:
		await fade_out(teaser)


func show_screen(time: float, screen: Node) -> void:
	mouse_cursor.show()
	await fade_in(screen)
	await wait(time)
	await fade_out(screen)
	mouse_cursor.hide()


func fade_in(node: Node) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(node, "modulate", Color.WHITE, 0.25)
	await tween.finished


func fade_out(node: Node) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(node, "modulate", Color.TRANSPARENT, 0.25)
	await tween.finished
