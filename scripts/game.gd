extends Control

class BoardCanvas extends Control:
	var owner_game: Control

	func _draw() -> void:
		if owner_game != null and owner_game.has_method("_draw_board_canvas"):
			owner_game._draw_board_canvas(self)

	func _gui_input(event: InputEvent) -> void:
		if owner_game != null and owner_game.has_method("_on_board_canvas_gui_input"):
			owner_game._on_board_canvas_gui_input(event)

const LEVEL_PATHS: Array[String] = [
	"res://levels/level_001.json",
	"res://levels/level_002.json",
	"res://levels/level_003.json",
	"res://levels/level_004.json",
	"res://levels/level_005.json",
	"res://levels/level_006.json",
	"res://levels/level_007.json",
	"res://levels/level_008.json",
	"res://levels/level_009.json",
	"res://levels/level_010.json",
	"res://levels/level_011.json",
	"res://levels/level_012.json",
	"res://levels/level_013.json",
	"res://levels/level_014.json",
]
const STORAGE_SIZE: int = 24
const STORAGE_COLUMNS: int = 12
const START_UNLOCKED_SLOTS: int = 12
const UNLOCK_PER_COMPLETED_REGION: int = 2
const BOARD_GAP: int = 0
const STORAGE_GAP: int = 6
const EMPTY_COLOR: int = -1
const BOARD_SOURCE: String = "board"
const STORAGE_SOURCE: String = "storage"
const SFX_PLAYER_COUNT: int = 12
const SFX_DEFAULT_VOLUME_DB: float = -10.0
const SFX_PUTIN_VOLUME_DB: float = 0.0
const SFX_SELECT: String = "select"
const SFX_FILL: String = "fill"
const SFX_PUTIN: String = "putin"
const SFX_GETIN: String = "getin"
const SFX_COMPLETE: String = "complete"
const SFX_VICTORY: String = "victory"
const FLY_DURATION: float = 0.04
const FLY_GAP: float = 0.012
const FLYER_MIN_SIZE: float = 22.0
const FLYER_MAX_SIZE: float = 44.0
const BEAN_PLACE_ANIMATION_FPS: float = 30.0
const BEAN_PLACE_ANIMATION_FRAMES: int = 7
const BOARD_TEXTURE_SCALE: float = 1.0
const GEM_TEXTURE_SCALE: float = 246.0 / 256.0
const SELECTED_GEM_LIFT_RATIO: float = 0.20
const BOARD_MIN_SCALE: float = 0.25
const BOARD_MAX_SCALE: float = 2.0
const BOARD_FIT_MARGIN: float = 32.0
const STORAGE_BOTTOM_MARGIN: float = 158.0
const STORAGE_PANEL_PADDING: float = 20.0
const MOUSE_DRAG_THRESHOLD: float = 8.0
const SAVE_PATH: String = "user://jewel_coloring_save.json"
const SCREEN_HOME: String = "home"
const SCREEN_LEVEL: String = "level"
const TUTORIAL_STEP_NONE: int = -1
const TUTORIAL_STEP_INTRO_1: int = 0
const TUTORIAL_STEP_INTRO_2: int = 1
const TUTORIAL_STEP_SELECT_BLUE: int = 2
const TUTORIAL_STEP_STORE_BLUE: int = 3
const TUTORIAL_STEP_SELECT_RED: int = 4
const TUTORIAL_STEP_PLACE_RED: int = 5
const TUTORIAL_STEP_SELECT_STORED_BLUE: int = 6
const TUTORIAL_STEP_PLACE_BLUE: int = 7
const TUTORIAL_STEP_OUTRO: int = 8
const TUTORIAL_HAND_OFFSET: Vector2 = Vector2(18.0, 12.0)
const STAMINA_MAX: int = 5
const STAMINA_COST_PER_LEVEL: int = 1
const STAMINA_RECOVERY_SECONDS: int = 30 * 60
const SHOW_STAMINA_WIDGET: bool = true
const STAMINA_FLOAT_TEXT_DURATION: float = 0.72
const STAMINA_FLOAT_TEXT_RISE: float = 58.0
# Turn this off before release builds.
const DEV_MODE: bool = false

const GEM_COLORS: Array[Color] = [
	Color("#e95d70"),
	Color("#35b1ff"),
	Color("#f5c84c"),
	Color("#4bd18f"),
	Color("#b47bff"),
	Color("#ff8a4c"),
	Color("#f6ead5")
]

const GEM_NAMES: Array[String] = [
	"Ruby",
	"Sapphire",
	"Topaz",
	"Emerald",
	"Amethyst",
	"Amber",
	"Pearl"
]

const LEGACY_COLOR_ID_ORDER: Array[String] = ["R", "B", "Y", "G", "P", "O", "W"]

const COLOR_IDS: Dictionary = {
	"R": 0,
	"B": 1,
	"Y": 2,
	"G": 3,
	"P": 4,
	"O": 5,
	"W": 6,
}

var board_cells: Array = []
var storage_slots: Array = []
var storage_color_order: Array[int] = []
var completed_regions: Dictionary = {}
var region_completion_cache: Dictionary = {}
var unlocked_slots: int = 0
var level_data: Dictionary = {}
var current_level_index: int = 0
var level_width: int = 0
var level_height: int = 0
var level_colors: Array[Color] = []
var level_color_names: Array[String] = []
var level_color_lookup: Dictionary = {}
var level_region_targets: Dictionary = {}
var level_active_regions: Array[String] = []
var level_initial_unlocked: int = START_UNLOCKED_SLOTS
var level_unlock_per_completed_region: int = UNLOCK_PER_COMPLETED_REGION
var selected_source: String = ""
var selected_color: int = EMPTY_COLOR
var selected_positions: Array = []
var is_animating: bool = false
var game_started: bool = false
var current_screen: String = SCREEN_HOME
var game_won_announced: bool = false
var stamina: int = STAMINA_MAX
var stamina_last_update_unix: int = 0
var sfx_streams: Dictionary = {}
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_player_index: int = 0
var board_texture: Texture2D = preload("res://textures/board09.png")
var bean_texture: Texture2D = preload("res://textures/bean.png")
var bean_animation_textures: Array[Texture2D] = [
	preload("res://textures/bean_001.png"),
	preload("res://textures/bean_002.png"),
	preload("res://textures/bean_003.png"),
	preload("res://textures/bean_004.png"),
	preload("res://textures/bean_005.png"),
	preload("res://textures/bean_006.png"),
	preload("res://textures/bean_007.png"),
]
var slot_texture: Texture2D = preload("res://textures/slot.png")
var home_screen_scene: PackedScene = preload("res://scenes/HomeScreen.tscn")
var dev_panel_scene: PackedScene = preload("res://scenes/DevPanel.tscn")
var gameplay_background_scene: PackedScene = preload("res://scenes/GameplayBackground.tscn")
var gameplay_ui_scene: PackedScene = preload("res://scenes/GameplayUI.tscn")
var top_bar_scene: PackedScene = preload("res://scenes/TopBar.tscn")
var tutorial_overlay_scene: PackedScene = preload("res://scenes/TutorialOverlay.tscn")

var board_buttons: Dictionary = {}
var board_base_textures: Dictionary = {}
var board_gem_textures: Dictionary = {}
var board_gem_base_positions: Dictionary = {}
var board_gem_animation_frames: Dictionary = {}
var remapped_bean_texture_cache: Dictionary = {}
var board_cell_size: float = 42.0
var storage_buttons: Array[Button] = []
var storage_slot_textures: Array[TextureRect] = []
var storage_gem_textures: Array[TextureRect] = []
var storage_gem_base_positions: Array[Vector2] = []
var game_background: ColorRect
var board_viewport: Control
var board_content: Control
var board_grid: BoardCanvas
var storage_panel: PanelContainer
var storage_grid: GridContainer
var fly_layer: Control
var gameplay_ui: Control
var home_screen: Control
var home_card: PanelContainer
var level_title_label: Label
var home_level_label: Label
var home_preview_frame: PanelContainer
var home_preview_grid: GridContainer
var home_start_button: Button
var home_catalog_button: Button
var catalog_page: Control
var catalog_grid: GridContainer
var catalog_back_button: Button
var stamina_widget: Control
var stamina_count_label: Label
var stamina_timer_label: Label
var stamina_tick_timer: Timer
var dev_panel: PanelContainer
var dev_level_label: Label
var tutorial_overlay: Control
var tutorial_dialog_box: PanelContainer
var tutorial_dialog_label: Label
var tutorial_hand: Control
var tutorial_active: bool = false
var tutorial_step: int = TUTORIAL_STEP_NONE
var tutorial_storage_slot_index: int = -1
var tutorial_hand_tween: Tween
var status_label: Label
var unlocked_label: Label
var active_touches: Dictionary = {}
var touch_start_positions: Dictionary = {}
var touch_dragged: Dictionary = {}
var last_pinch_distance: float = 0.0
var last_pinch_center: Vector2 = Vector2.ZERO
var board_dragging: bool = false
var mouse_drag_ready: bool = false
var last_drag_position: Vector2 = Vector2.ZERO
var mouse_drag_start: Vector2 = Vector2.ZERO


func _ready() -> void:
	randomize()
	var should_start_tutorial: bool = not _is_tutorial_completed()
	current_level_index = 0 if should_start_tutorial else _load_saved_level_index()
	var saved_screen: String = _load_saved_screen()
	_load_stamina_state()
	_load_level(LEVEL_PATHS[current_level_index])
	_setup_audio()
	_build_layout()
	_resize_cells()
	_center_board()
	if should_start_tutorial:
		_start_tutorial()
	elif saved_screen == SCREEN_LEVEL:
		_start_current_level()
	else:
		_show_home_screen()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and board_grid != null and storage_grid != null:
		_resize_cells()
		_center_board()

	if what == NOTIFICATION_APPLICATION_RESUMED:
		_update_stamina_from_clock(true)
		_refresh_stamina_ui()

	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		_save_current_session_state()


func _input(event: InputEvent) -> void:
	if board_content == null or is_animating or not game_started:
		return

	if _is_storage_input_event(event):
		_reset_board_drag_state_for_storage_input(event)
		return

	if tutorial_active:
		if event is InputEventScreenTouch:
			_handle_tutorial_screen_touch(event)
		return

	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _build_layout() -> void:
	game_background = gameplay_background_scene.instantiate() as ColorRect
	game_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(game_background)

	board_viewport = Control.new()
	board_viewport.name = "BoardViewport"
	board_viewport.mouse_filter = Control.MOUSE_FILTER_PASS
	board_viewport.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(board_viewport)

	board_content = Control.new()
	board_content.name = "BoardContent"
	board_content.mouse_filter = Control.MOUSE_FILTER_PASS
	board_viewport.add_child(board_content)

	board_grid = BoardCanvas.new()
	board_grid.owner_game = self
	board_grid.mouse_filter = Control.MOUSE_FILTER_STOP
	board_content.add_child(board_grid)

	_create_gameplay_ui()
	_create_fly_layer()
	_create_home_screen()
	if SHOW_STAMINA_WIDGET:
		_create_stamina_widget()
	_create_dev_panel()
	_create_tutorial_overlay()
	_create_stamina_timer()


func _create_board_buttons() -> void:
	board_buttons.clear()
	board_base_textures.clear()
	board_gem_textures.clear()
	board_gem_base_positions.clear()


func _rebuild_board_buttons() -> void:
	board_buttons.clear()
	board_base_textures.clear()
	board_gem_textures.clear()
	board_gem_base_positions.clear()
	board_gem_animation_frames.clear()
	if board_grid != null:
		board_grid.queue_redraw()


func _create_gameplay_ui() -> void:
	gameplay_ui = gameplay_ui_scene.instantiate()
	gameplay_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gameplay_ui)

	level_title_label = gameplay_ui.get_node("LevelTitle")
	storage_panel = gameplay_ui.get_node("StoragePanel")
	storage_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	storage_panel.gui_input.connect(_on_storage_panel_gui_input)
	status_label = gameplay_ui.get_node("StoragePanel/StorageBox/StorageHeader/StatusLabel")
	unlocked_label = gameplay_ui.get_node("StoragePanel/StorageBox/StorageHeader/UnlockedLabel")
	storage_grid = gameplay_ui.get_node("StoragePanel/StorageBox/StorageGrid")
	storage_grid.columns = STORAGE_COLUMNS
	storage_grid.add_theme_constant_override("h_separation", STORAGE_GAP)
	storage_grid.add_theme_constant_override("v_separation", STORAGE_GAP)

	_bind_storage_slots()
	_refresh_level_title()


func _bind_storage_slots() -> void:
	storage_buttons.clear()
	storage_slot_textures.clear()
	storage_gem_textures.clear()
	storage_gem_base_positions.clear()

	for index in range(STORAGE_SIZE):
		var button: Button = storage_grid.get_node("StorageSlot%02d" % index)
		button.pressed.connect(_on_storage_pressed.bind(index))
		storage_buttons.append(button)

		var slot_background: TextureRect = button.get_node("StorageSlotTexture")
		storage_slot_textures.append(slot_background)

		var gem_texture: TextureRect = button.get_node("StorageBeanTexture")
		storage_gem_textures.append(gem_texture)
		storage_gem_base_positions.append(Vector2.ZERO)


func _create_fly_layer() -> void:
	fly_layer = Control.new()
	fly_layer.name = "FlyLayer"
	fly_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fly_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fly_layer)


func _refresh_level_title() -> void:
	if level_title_label == null:
		return

	level_title_label.text = "第%d关" % (current_level_index + 1)


func _create_stamina_widget() -> void:
	stamina_widget = top_bar_scene.instantiate()
	stamina_widget.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stamina_widget)

	stamina_count_label = stamina_widget.find_child("StaminaCount", true, false) as Label
	stamina_timer_label = stamina_widget.find_child("StaminaTimer", true, false) as Label
	_refresh_stamina_ui()


func _create_stamina_timer() -> void:
	stamina_tick_timer = Timer.new()
	stamina_tick_timer.name = "StaminaTickTimer"
	stamina_tick_timer.wait_time = 1.0
	stamina_tick_timer.autostart = true
	stamina_tick_timer.timeout.connect(_on_stamina_tick)
	add_child(stamina_tick_timer)


func _create_dev_panel() -> void:
	if not DEV_MODE:
		return

	dev_panel = dev_panel_scene.instantiate()
	dev_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dev_panel)

	var previous_button: Button = dev_panel.get_node("Row/PreviousButton")
	previous_button.pressed.connect(_dev_previous_level)

	dev_level_label = dev_panel.get_node("Row/LevelLabel")
	dev_level_label.add_theme_font_size_override("font_size", 16)
	dev_level_label.add_theme_color_override("font_color", Color.WHITE)

	var next_button: Button = dev_panel.get_node("Row/NextButton")
	next_button.pressed.connect(_dev_next_level)

	var reset_level_button: Button = dev_panel.get_node("Row/ResetButton")
	reset_level_button.pressed.connect(_dev_reset_current_level)

	var home_button: Button = dev_panel.get_node("Row/HomeButton")
	home_button.pressed.connect(_dev_return_home)

	_refresh_dev_panel()


func _create_tutorial_overlay() -> void:
	tutorial_overlay = tutorial_overlay_scene.instantiate()
	tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_overlay.visible = false
	add_child(tutorial_overlay)

	tutorial_dialog_box = tutorial_overlay.get_node("DialogBox")
	tutorial_dialog_box.gui_input.connect(_on_tutorial_dialog_gui_input)
	tutorial_dialog_label = tutorial_overlay.get_node("DialogBox/DialogMargin/DialogStack/DialogLabel")
	tutorial_hand = tutorial_overlay.get_node("HandPointer")


func _refresh_dev_panel() -> void:
	if dev_panel == null or dev_level_label == null:
		return

	dev_panel.visible = DEV_MODE and not tutorial_active
	dev_level_label.text = "DEV Lv %d/%d" % [current_level_index + 1, LEVEL_PATHS.size()]


func _create_home_screen() -> void:
	home_screen = home_screen_scene.instantiate()
	home_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(home_screen)

	home_card = home_screen.get_node("HomeCard")
	home_level_label = home_screen.get_node("HomeCard/Content/LevelLabelSlot/LevelLabel")

	home_preview_frame = home_screen.get_node("HomeCard/Content/PreviewFrame")

	home_preview_grid = home_screen.get_node("HomeCard/Content/PreviewFrame/PreviewGrid")

	home_start_button = home_screen.get_node("HomeCard/Content/StartButton")
	home_start_button.pressed.connect(_try_start_current_level)

	home_catalog_button = home_screen.get_node("HomeCard/Content/CatalogButton")
	home_catalog_button.pressed.connect(_show_catalog_page)

	catalog_page = home_screen.get_node("CatalogPage")
	catalog_grid = home_screen.get_node("CatalogPage/CatalogCard/CatalogContent/CatalogScroll/CatalogGrid")
	catalog_back_button = home_screen.get_node("CatalogPage/CatalogCard/CatalogContent/CatalogHeader/BackButton")
	catalog_back_button.pressed.connect(_hide_catalog_page)

	_refresh_home_screen()


func _build_level_preview(preview_grid: GridContainer, cell_size: float) -> void:
	for y in range(level_height):
		for x in range(level_width):
			var pos: Vector2i = Vector2i(x, y)
			var tile: ColorRect = ColorRect.new()
			tile.custom_minimum_size = Vector2(cell_size, cell_size)

			var region_value: Variant = _get_level_grid_value("region_map", pos)
			if region_value == null:
				tile.color = Color(1, 1, 1, 0)
			else:
				var region_id: String = str(region_value)
				var target_color: int = int(level_region_targets.get(region_id, EMPTY_COLOR))
				tile.color = _get_texture_tint(target_color, false)

			preview_grid.add_child(tile)


func _refresh_home_screen() -> void:
	if home_level_label == null or home_preview_grid == null:
		return

	home_level_label.text = "第%d关" % (current_level_index + 1)
	_hide_catalog_page()
	_refresh_stamina_ui()
	_refresh_dev_panel()
	home_preview_grid.columns = level_width
	for child in home_preview_grid.get_children():
		child.queue_free()

	var preview_axis: int = max(level_width, level_height)
	var preview_gap: int = 1 if preview_axis > 24 else 2
	home_preview_grid.add_theme_constant_override("h_separation", preview_gap)
	home_preview_grid.add_theme_constant_override("v_separation", preview_gap)
	var cell_size: float = clamp(floor(230.0 / float(preview_axis)), 4.0, 44.0)
	_build_level_preview(home_preview_grid, cell_size)


func _show_catalog_page() -> void:
	if home_card == null or catalog_page == null:
		return

	home_card.visible = false
	catalog_page.visible = true
	_build_catalog_grid()


func _hide_catalog_page() -> void:
	if home_card != null:
		home_card.visible = true
	if catalog_page != null:
		catalog_page.visible = false


func _build_catalog_grid() -> void:
	if catalog_grid == null:
		return

	for child in catalog_grid.get_children():
		child.queue_free()

	for index in range(LEVEL_PATHS.size()):
		var entry: PanelContainer = _make_catalog_entry(index, _is_catalog_level_completed(index))
		catalog_grid.add_child(entry)


func _make_catalog_entry(index: int, is_completed: bool) -> PanelContainer:
	var entry: PanelContainer = PanelContainer.new()
	entry.custom_minimum_size = Vector2(124.0, 152.0)
	entry.add_theme_stylebox_override("panel", _make_panel_style(Color("#fff4df"), Color("#c9905d"), 2, 18, 10))

	var stack: VBoxContainer = VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 8)
	entry.add_child(stack)

	var preview_frame: PanelContainer = PanelContainer.new()
	preview_frame.custom_minimum_size = Vector2(96.0, 96.0)
	preview_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_frame.add_theme_stylebox_override("panel", _make_panel_style(Color("#f4e2c9"), Color("#d4a06f"), 1, 14, 8))
	stack.add_child(preview_frame)

	if is_completed:
		var preview_grid: GridContainer = GridContainer.new()
		preview_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		preview_grid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		preview_frame.add_child(preview_grid)
		_build_catalog_level_preview(index, preview_grid, 84.0)
	else:
		var question: Label = Label.new()
		question.text = "?"
		question.custom_minimum_size = Vector2(96.0, 96.0)
		question.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		question.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		question.add_theme_font_size_override("font_size", 58)
		question.add_theme_color_override("font_color", Color("#8a6546"))
		preview_frame.add_child(question)

	var label: Label = Label.new()
	label.text = "第%d关" % (index + 1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("#8a5c3d"))
	stack.add_child(label)
	return entry


func _build_catalog_level_preview(index: int, preview_grid: GridContainer, max_size: float) -> void:
	var preview_data: Dictionary = _load_catalog_preview_data(index)
	var rows: Array = preview_data.get("rows", [])
	if rows.is_empty():
		return

	var preview_width: int = int(preview_data.get("width", 1))
	var preview_height: int = int(preview_data.get("height", 1))
	var region_colors: Dictionary = preview_data.get("region_colors", {})
	var preview_axis: int = max(preview_width, preview_height)
	var gap: int = 1 if preview_axis <= 24 else 0
	var cell_size: float = clamp(floor((max_size - float(max(preview_axis - 1, 0)) * float(gap)) / float(preview_axis)), 2.0, 16.0)
	preview_grid.columns = preview_width
	preview_grid.add_theme_constant_override("h_separation", gap)
	preview_grid.add_theme_constant_override("v_separation", gap)

	for y in range(preview_height):
		var row: Array = rows[y]
		for x in range(preview_width):
			var tile: ColorRect = ColorRect.new()
			tile.custom_minimum_size = Vector2(cell_size, cell_size)
			var region_value: Variant = row[x]
			tile.color = Color(1, 1, 1, 0) if region_value == null else Color.html(str(region_colors.get(str(region_value), "#ffffff")))
			preview_grid.add_child(tile)


func _load_catalog_preview_data(index: int) -> Dictionary:
	var file: FileAccess = FileAccess.open(LEVEL_PATHS[index], FileAccess.READ)
	if file == null:
		return {}

	var parse_result: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parse_result) != TYPE_DICTIONARY:
		return {}

	var data: Dictionary = parse_result
	var rows: Array = _get_preview_rows_from_level_data(data)
	return {
		"width": int(data.get("width", 0)),
		"height": int(data.get("height", 0)),
		"rows": rows,
		"region_colors": _get_preview_region_colors(data),
	}


func _get_preview_rows_from_level_data(data: Dictionary) -> Array:
	if data.has("region_rows"):
		var legend: Dictionary = data.get("legend", {})
		var normalized_rows: Array = []
		for row_value in data.get("region_rows", []):
			var row_text: String = str(row_value)
			var row: Array = []
			for index in range(row_text.length()):
				var marker: String = row_text[index]
				if marker == ".":
					row.append(null)
				else:
					row.append(str(legend.get(marker, marker)))
			normalized_rows.append(row)
		return normalized_rows

	return data.get("region_map", [])


func _get_preview_region_colors(data: Dictionary) -> Dictionary:
	var region_colors: Dictionary = {}
	var regions: Dictionary = data.get("regions", {})
	for region_key in regions.keys():
		var region_id: String = str(region_key)
		var region_info: Dictionary = regions[region_key]
		var color_value: String = str(region_info.get("target_color", "#ffffff"))
		region_colors[region_id] = color_value if Color.html_is_valid(color_value) else "#ffffff"

	for color_id in COLOR_IDS.keys():
		var legacy_id: String = str(color_id)
		if not region_colors.has(legacy_id):
			region_colors[legacy_id] = _get_color_html(GEM_COLORS[int(COLOR_IDS[legacy_id])])

	return region_colors


func _get_color_html(color: Color) -> String:
	return "#%02x%02x%02x" % [
		int(round(clamp(color.r, 0.0, 1.0) * 255.0)),
		int(round(clamp(color.g, 0.0, 1.0) * 255.0)),
		int(round(clamp(color.b, 0.0, 1.0) * 255.0)),
	]


func _is_catalog_level_completed(index: int) -> bool:
	var save_root: Dictionary = _load_save_root()
	var levels: Dictionary = save_root.get("levels", {})
	var level_id: String = _get_level_id_for_index(index)
	if level_id == "" or not levels.has(level_id):
		return false

	var save_data: Dictionary = levels[level_id]
	return bool(save_data.get("completed", false)) or bool(save_data.get("game_won_announced", false))


func _get_level_id_for_index(index: int) -> String:
	var file: FileAccess = FileAccess.open(LEVEL_PATHS[index], FileAccess.READ)
	if file == null:
		return ""

	var parse_result: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parse_result) != TYPE_DICTIONARY:
		return ""

	var data: Dictionary = parse_result
	return str(data.get("id", ""))


func _resize_cells() -> void:
	var storage_cell_size: float = _get_storage_cell_size()
	var storage_height: float = _get_storage_panel_height(storage_cell_size)
	storage_panel.offset_left = max(28.0, size.x * 0.052)
	storage_panel.offset_right = -max(28.0, size.x * 0.052)
	storage_panel.offset_top = -(storage_height + STORAGE_BOTTOM_MARGIN)
	storage_panel.offset_bottom = -STORAGE_BOTTOM_MARGIN

	var available_width: float = max(size.x - 40.0, 320.0)
	var board_available_height: float = max(size.y - storage_height - 220.0, 320.0)
	var board_span: float = min(available_width * 0.82, board_available_height * 0.68)
	var max_board_axis: int = max(level_width, level_height)
	board_cell_size = floor((board_span - float(max_board_axis - 1) * BOARD_GAP) / float(max_board_axis))
	board_cell_size = clamp(board_cell_size, 42.0, 96.0)

	var board_width: float = board_cell_size * float(level_width) + float(level_width - 1) * BOARD_GAP
	var board_height: float = board_cell_size * float(level_height) + float(level_height - 1) * BOARD_GAP
	board_content.custom_minimum_size = Vector2(board_width, board_height)
	board_content.size = Vector2(board_width, board_height)
	board_grid.custom_minimum_size = Vector2(board_width, board_height)
	board_grid.size = Vector2(board_width, board_height)
	board_grid.queue_redraw()

	for button in storage_buttons:
		button.custom_minimum_size = Vector2(storage_cell_size, storage_cell_size)

	for slot_background in storage_slot_textures:
		slot_background.size = Vector2(storage_cell_size, storage_cell_size)
		slot_background.position = Vector2.ZERO

	for index in range(storage_gem_textures.size()):
		var gem_texture: TextureRect = storage_gem_textures[index]
		var gem_size: float = storage_cell_size * GEM_TEXTURE_SCALE
		var gem_offset: float = (storage_cell_size - gem_size) * 0.5
		gem_texture.size = Vector2(gem_size, gem_size)
		gem_texture.position = Vector2(gem_offset, gem_offset)
		storage_gem_base_positions[index] = Vector2(gem_offset, gem_offset)


func _draw_board_canvas(canvas: Control) -> void:
	if board_cells.is_empty():
		return

	for y in range(level_height):
		for x in range(level_width):
			var pos: Vector2i = Vector2i(x, y)
			var cell: Dictionary = _get_board_cell(pos)
			if not cell["active"]:
				continue

			var origin: Vector2 = Vector2(float(x) * (board_cell_size + BOARD_GAP), float(y) * (board_cell_size + BOARD_GAP))
			var target_color: int = cell["target_color"]
			var current_color: int = cell["current_color"]
			var is_complete: bool = _is_region_complete(cell["region_id"])
			var base_rect: Rect2 = Rect2(origin, Vector2(board_cell_size, board_cell_size))
			canvas.draw_texture_rect(board_texture, base_rect, false, _get_texture_tint(target_color, is_complete))

			if current_color == EMPTY_COLOR:
				continue

			var is_selected: bool = selected_source == BOARD_SOURCE and selected_positions.has(pos)
			var gem_size: float = board_cell_size * GEM_TEXTURE_SCALE
			var gem_offset: float = (board_cell_size - gem_size) * 0.5
			var lift_offset: float = gem_size * SELECTED_GEM_LIFT_RATIO if is_selected else 0.0
			var gem_rect: Rect2 = Rect2(origin + Vector2(gem_offset, gem_offset - lift_offset), Vector2(gem_size, gem_size))
			var gem_texture: Texture2D = _get_board_gem_texture(pos, current_color)
			canvas.draw_texture_rect(gem_texture, gem_rect, false, Color.WHITE)


func _on_board_canvas_gui_input(event: InputEvent) -> void:
	if is_animating or not game_started:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_drag_ready = false
		board_dragging = false
		_press_board_at_canvas_position(event.position)
		accept_event()


func _press_board_at_canvas_position(canvas_position: Vector2) -> void:
	var pos: Vector2i = Vector2i(int(floor(canvas_position.x / (board_cell_size + BOARD_GAP))), int(floor(canvas_position.y / (board_cell_size + BOARD_GAP))))
	if pos.x < 0 or pos.x >= level_width or pos.y < 0 or pos.y >= level_height:
		return

	_on_board_pressed(pos)


func _press_board_at_screen_position(screen_position: Vector2) -> void:
	if board_grid == null or not board_grid.visible:
		return

	var canvas_position: Vector2 = board_grid.get_global_transform_with_canvas().affine_inverse() * screen_position
	if canvas_position.x < 0.0 or canvas_position.y < 0.0 or canvas_position.x >= board_grid.size.x or canvas_position.y >= board_grid.size.y:
		return

	_press_board_at_canvas_position(canvas_position)


func _center_board() -> void:
	if board_content == null:
		return

	var storage_top: float = size.y - (_get_storage_panel_height(_get_storage_cell_size()) + STORAGE_BOTTOM_MARGIN)
	var top_limit: float = 96.0
	var bottom_limit: float = storage_top - BOARD_FIT_MARGIN
	var available_width: float = max(size.x - BOARD_FIT_MARGIN * 2.0, 1.0)
	var available_height: float = max(bottom_limit - top_limit, 1.0)
	var fit_scale: float = min(available_width / board_content.size.x, available_height / board_content.size.y, 1.0)
	fit_scale = clamp(fit_scale, BOARD_MIN_SCALE, BOARD_MAX_SCALE)

	var scaled_size: Vector2 = board_content.size * fit_scale
	var board_area_center: Vector2 = Vector2(size.x * 0.5, top_limit + available_height * 0.5)
	board_content.scale = Vector2(fit_scale, fit_scale)
	board_content.position = board_area_center - scaled_size * 0.5


func _show_home_screen() -> void:
	current_screen = SCREEN_HOME
	game_started = false
	active_touches.clear()
	touch_start_positions.clear()
	touch_dragged.clear()
	board_dragging = false
	mouse_drag_ready = false
	game_background.visible = false
	board_viewport.visible = false
	fly_layer.visible = false
	gameplay_ui.visible = false
	if stamina_widget != null:
		stamina_widget.visible = true
	_refresh_dev_panel()
	_refresh_home_screen()
	home_screen.visible = true
	_save_navigation_state()


func _try_start_current_level() -> void:
	if not _consume_stamina(STAMINA_COST_PER_LEVEL):
		return

	_start_current_level()


func _dev_previous_level() -> void:
	_dev_switch_level(current_level_index - 1)


func _dev_next_level() -> void:
	_dev_switch_level(current_level_index + 1)


func _dev_reset_current_level() -> void:
	if not DEV_MODE or is_animating:
		return

	_delete_current_level_save()
	_load_level(LEVEL_PATHS[current_level_index])
	_refresh_level_title()
	_clear_selection()
	_clear_fly_layer()

	if current_screen == SCREEN_LEVEL:
		_load_current_level_for_play(false)
		_save_progress()
	else:
		_refresh_home_screen()
		_save_navigation_state()

	_refresh_dev_panel()


func _dev_return_home() -> void:
	if not DEV_MODE or is_animating:
		return

	if current_screen == SCREEN_LEVEL:
		_return_to_home()
	else:
		_refresh_home_screen()
		_refresh_dev_panel()
		_save_navigation_state()


func _dev_switch_level(target_index: int) -> void:
	if not DEV_MODE or is_animating:
		return

	var clamped_index: int = clampi(target_index, 0, LEVEL_PATHS.size() - 1)
	if clamped_index == current_level_index:
		return

	if current_screen == SCREEN_LEVEL:
		_save_progress()

	current_level_index = clamped_index
	_load_level(LEVEL_PATHS[current_level_index])
	_refresh_level_title()
	_clear_selection()
	_clear_fly_layer()

	if current_screen == SCREEN_LEVEL:
		_load_current_level_for_play(true)
	else:
		_refresh_home_screen()

	_refresh_dev_panel()
	_save_navigation_state()


func _start_current_level() -> void:
	current_screen = SCREEN_LEVEL
	game_started = true
	home_screen.visible = false
	game_background.visible = true
	board_viewport.visible = true
	fly_layer.visible = true
	gameplay_ui.visible = true
	if stamina_widget != null:
		stamina_widget.visible = true
	_refresh_dev_panel()
	_refresh_stamina_ui()
	_load_current_level_for_play(true)
	_save_progress()


func _start_tutorial() -> void:
	tutorial_active = true
	tutorial_step = TUTORIAL_STEP_INTRO_1
	tutorial_storage_slot_index = -1
	current_level_index = 0
	current_screen = SCREEN_LEVEL
	game_started = true
	home_screen.visible = false
	game_background.visible = true
	board_viewport.visible = true
	fly_layer.visible = true
	gameplay_ui.visible = true
	if stamina_widget != null:
		stamina_widget.visible = false
	if tutorial_overlay != null:
		tutorial_overlay.visible = true
	_refresh_dev_panel()
	_load_current_level_for_play(false)
	_show_tutorial_dialog("完蛋了！不小心把拼豆打翻了")
	_save_navigation_state()


func _on_tutorial_dialog_gui_input(event: InputEvent) -> void:
	if not tutorial_active:
		return

	if event is InputEventScreenTouch and event.pressed:
		_advance_tutorial_dialog()
		accept_event()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance_tutorial_dialog()
		accept_event()


func _advance_tutorial_dialog() -> void:
	if tutorial_step == TUTORIAL_STEP_INTRO_1:
		tutorial_step = TUTORIAL_STEP_INTRO_2
		_show_tutorial_dialog("让我们赶快复原一下吧！")
	elif tutorial_step == TUTORIAL_STEP_INTRO_2:
		tutorial_step = TUTORIAL_STEP_SELECT_BLUE
		_show_tutorial_hand_at_board(Vector2i(0, 0))
	elif tutorial_step == TUTORIAL_STEP_OUTRO:
		_finish_tutorial()


func _show_tutorial_dialog(text: String) -> void:
	if tutorial_overlay == null:
		return

	tutorial_overlay.visible = true
	tutorial_dialog_box.visible = true
	tutorial_dialog_label.text = text
	_hide_tutorial_hand()


func _show_tutorial_hand_at_board(pos: Vector2i) -> void:
	if tutorial_overlay == null:
		return

	tutorial_overlay.visible = true
	tutorial_dialog_box.visible = false
	_position_tutorial_hand(_get_board_cell_center(pos))


func _show_tutorial_hand_at_storage(index: int) -> void:
	if tutorial_overlay == null:
		return

	tutorial_overlay.visible = true
	tutorial_dialog_box.visible = false
	_position_tutorial_hand(_get_storage_slot_center(index))


func _position_tutorial_hand(center: Vector2) -> void:
	if tutorial_hand == null:
		return

	tutorial_hand.visible = true
	tutorial_hand.size = Vector2(72.0, 72.0)
	tutorial_hand.position = center - tutorial_hand.size * 0.5 + TUTORIAL_HAND_OFFSET
	if tutorial_hand_tween != null:
		tutorial_hand_tween.kill()

	tutorial_hand.scale = Vector2.ONE
	tutorial_hand_tween = create_tween()
	tutorial_hand_tween.set_loops()
	tutorial_hand_tween.tween_property(tutorial_hand, "scale", Vector2(0.88, 0.88), 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tutorial_hand_tween.tween_property(tutorial_hand, "scale", Vector2.ONE, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _hide_tutorial_hand() -> void:
	if tutorial_hand_tween != null:
		tutorial_hand_tween.kill()
		tutorial_hand_tween = null
	if tutorial_hand != null:
		tutorial_hand.visible = false


func _finish_tutorial() -> void:
	tutorial_active = false
	tutorial_step = TUTORIAL_STEP_NONE
	tutorial_storage_slot_index = -1
	_hide_tutorial_hand()
	if tutorial_overlay != null:
		tutorial_overlay.visible = false

	_set_tutorial_completed(true)
	_save_progress()
	if current_level_index < LEVEL_PATHS.size() - 1:
		current_level_index = 1
		_load_level(LEVEL_PATHS[current_level_index])
		_refresh_level_title()
		_refresh_dev_panel()

	_show_home_screen()


func _load_current_level_for_play(should_restore_progress: bool = true) -> void:
	_load_level(LEVEL_PATHS[current_level_index])
	_refresh_level_title()
	_rebuild_board_buttons()
	_resize_cells()
	_center_board()
	_new_game(false)
	if should_restore_progress:
		_load_progress()

	_refresh_all()


func _advance_to_next_level() -> void:
	_save_progress()
	if current_level_index < LEVEL_PATHS.size() - 1:
		current_level_index += 1
		_load_level(LEVEL_PATHS[current_level_index])
		_refresh_level_title()
		_refresh_dev_panel()

	_show_home_screen()


func _return_to_home() -> void:
	if is_animating:
		return

	_save_progress()
	_clear_selection()
	_clear_fly_layer()
	_refresh_all()
	_show_home_screen()


func _clear_fly_layer() -> void:
	for child in fly_layer.get_children():
		child.queue_free()


func _reset_progress() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
		if error != OK:
			push_error("Cannot remove save file: %s" % SAVE_PATH)

	current_level_index = 0
	stamina = STAMINA_MAX
	stamina_last_update_unix = _get_unix_time()
	_load_level(LEVEL_PATHS[current_level_index])
	_refresh_level_title()
	_refresh_dev_panel()
	_clear_selection()
	_refresh_home_screen()
	_save_navigation_state()


func _get_storage_cell_size() -> float:
	var storage_width: float = max(size.x - max(56.0, size.x * 0.104), 320.0)
	var storage_inner_padding: float = STORAGE_PANEL_PADDING * 2.0
	var storage_cell_size: float = floor((storage_width - storage_inner_padding - float(STORAGE_COLUMNS - 1) * STORAGE_GAP) / STORAGE_COLUMNS)
	return max(24.0, storage_cell_size)


func _get_storage_panel_height(storage_cell_size: float) -> float:
	var storage_rows: int = int(ceil(float(STORAGE_SIZE) / float(STORAGE_COLUMNS)))
	var content_height: float = storage_cell_size * float(storage_rows) + float(storage_rows - 1) * STORAGE_GAP
	return content_height + STORAGE_PANEL_PADDING * 2.0


func _is_storage_input_event(event: InputEvent) -> bool:
	if storage_panel == null or not storage_panel.visible:
		return false

	var event_position: Vector2
	if event is InputEventScreenTouch:
		event_position = event.position
	elif event is InputEventScreenDrag:
		event_position = event.position
	elif event is InputEventMouseButton:
		event_position = event.position
	elif event is InputEventMouseMotion:
		event_position = event.position
	else:
		return false

	return storage_panel.get_global_rect().has_point(event_position)


func _reset_board_drag_state_for_storage_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			active_touches.erase(event.index)
		else:
			active_touches.erase(event.index)
		touch_start_positions.erase(event.index)
		touch_dragged.erase(event.index)
		_update_touch_state()
	elif event is InputEventScreenDrag:
		active_touches.erase(event.index)
		touch_start_positions.erase(event.index)
		touch_dragged.erase(event.index)
		_update_touch_state()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_drag_ready = false
		board_dragging = false
	elif event is InputEventMouseMotion:
		mouse_drag_ready = false
		board_dragging = false


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		active_touches[event.index] = event.position
		touch_start_positions[event.index] = event.position
		touch_dragged[event.index] = false
	else:
		var was_tap: bool = active_touches.size() == 1 \
			and touch_start_positions.has(event.index) \
			and not bool(touch_dragged.get(event.index, false)) \
			and Vector2(touch_start_positions[event.index]).distance_to(event.position) < MOUSE_DRAG_THRESHOLD
		if was_tap:
			_press_board_at_screen_position(event.position)

		active_touches.erase(event.index)
		touch_start_positions.erase(event.index)
		touch_dragged.erase(event.index)

	_update_touch_state()


func _handle_tutorial_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		active_touches[event.index] = event.position
		touch_start_positions[event.index] = event.position
		touch_dragged[event.index] = false
		return

	var was_tap: bool = touch_start_positions.has(event.index) \
		and not bool(touch_dragged.get(event.index, false)) \
		and Vector2(touch_start_positions[event.index]).distance_to(event.position) < MOUSE_DRAG_THRESHOLD
	if was_tap:
		_press_board_at_screen_position(event.position)

	active_touches.erase(event.index)
	touch_start_positions.erase(event.index)
	touch_dragged.erase(event.index)
	_update_touch_state()


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if not active_touches.has(event.index):
		return

	active_touches[event.index] = event.position
	if active_touches.size() == 1:
		if touch_start_positions.has(event.index) and Vector2(touch_start_positions[event.index]).distance_to(event.position) >= MOUSE_DRAG_THRESHOLD:
			touch_dragged[event.index] = true
		_pan_board(event.relative)
	elif active_touches.size() >= 2:
		touch_dragged[event.index] = true
		_update_pinch_zoom()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		mouse_drag_ready = event.pressed
		board_dragging = false
		mouse_drag_start = event.position
		last_drag_position = event.position
	elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom_board(1.08, event.position)
	elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom_board(0.92, event.position)


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if mouse_drag_ready and not board_dragging and mouse_drag_start.distance_to(event.position) >= MOUSE_DRAG_THRESHOLD:
		board_dragging = true

	if mouse_drag_ready and board_dragging:
		_pan_board(event.position - last_drag_position)
		last_drag_position = event.position


func _update_touch_state() -> void:
	if active_touches.size() == 2:
		var positions: Array = active_touches.values()
		var first_position: Vector2 = positions[0]
		var second_position: Vector2 = positions[1]
		last_pinch_distance = first_position.distance_to(second_position)
		last_pinch_center = (first_position + second_position) * 0.5
	else:
		last_pinch_distance = 0.0


func _update_pinch_zoom() -> void:
	var positions: Array = active_touches.values()
	if positions.size() < 2:
		return

	var first_position: Vector2 = positions[0]
	var second_position: Vector2 = positions[1]
	var current_distance: float = max(first_position.distance_to(second_position), 1.0)
	var current_center: Vector2 = (first_position + second_position) * 0.5
	if last_pinch_distance > 0.0:
		_zoom_board(current_distance / last_pinch_distance, current_center)
		_pan_board(current_center - last_pinch_center)

	last_pinch_distance = current_distance
	last_pinch_center = current_center


func _pan_board(delta: Vector2) -> void:
	board_content.position += delta


func _zoom_board(factor: float, center: Vector2) -> void:
	var old_scale: float = board_content.scale.x
	var new_scale: float = clamp(old_scale * factor, BOARD_MIN_SCALE, BOARD_MAX_SCALE)
	if is_equal_approx(old_scale, new_scale):
		return

	var local_center: Vector2 = (center - board_content.position) / old_scale
	board_content.scale = Vector2(new_scale, new_scale)
	board_content.position = center - local_center * new_scale


func _load_level(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open level file: %s" % path)
		return

	var parse_result: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parse_result) != TYPE_DICTIONARY:
		push_error("Level file is not a valid JSON object: %s" % path)
		return

	level_data = parse_result
	_normalize_level_grid("region_rows", "region_map")
	_normalize_level_grid("initial_rows", "initial_gems")
	level_width = int(level_data.get("width", 0))
	level_height = int(level_data.get("height", 0))
	level_initial_unlocked = START_UNLOCKED_SLOTS
	level_unlock_per_completed_region = UNLOCK_PER_COMPLETED_REGION
	_reset_level_palette()

	var storage: Dictionary = level_data.get("storage", {})
	level_initial_unlocked = int(storage.get("initial_unlocked", START_UNLOCKED_SLOTS))
	level_unlock_per_completed_region = int(storage.get("unlock_per_completed_region", UNLOCK_PER_COMPLETED_REGION))

	level_region_targets = {}
	level_active_regions = []
	var regions: Dictionary = level_data.get("regions", {})
	for region_key in regions.keys():
		var region_id: String = str(region_key)
		var region_info: Dictionary = regions[region_key]
		var color_value: Variant = region_info.get("target_color", "")
		var target_color: int = _color_value_to_index(color_value)
		level_region_targets[region_id] = target_color
		_register_level_color_alias(region_id, target_color)

	_register_color_regions_from_map()
	_validate_level_data(path)


func _register_color_regions_from_map() -> void:
	for y in range(level_height):
		for x in range(level_width):
			var region_value: Variant = _get_level_grid_value("region_map", Vector2i(x, y))
			if region_value == null:
				continue

			var region_id: String = str(region_value)
			if not level_active_regions.has(region_id):
				level_active_regions.append(region_id)

			if level_region_targets.has(region_id):
				continue

			if COLOR_IDS.has(region_id):
				level_region_targets[region_id] = _color_value_to_index(region_id)


func _normalize_level_grid(rows_name: String, grid_name: String) -> void:
	if level_data.has(grid_name) or not level_data.has(rows_name):
		return

	var rows: Array = level_data.get(rows_name, [])
	var legend: Dictionary = level_data.get("legend", {})
	var grid: Array = []
	for row_value in rows:
		var row_text: String = str(row_value)
		var row: Array = []
		for index in range(row_text.length()):
			var marker: String = row_text[index]
			if marker == ".":
				row.append(null)
			elif legend.has(marker):
				row.append(legend[marker])
			else:
				push_error("Level %s uses undefined legend marker: %s" % [str(level_data.get("id", "")), marker])
				row.append(null)

		grid.append(row)

	level_data[grid_name] = grid


func _validate_level_data(path: String) -> void:
	if level_width <= 0 or level_height <= 0:
		push_error("Level %s has invalid width/height." % path)
		return

	_validate_level_grid_shape(path, "region_map")
	_validate_level_grid_shape(path, "initial_gems")

	for y in range(level_height):
		for x in range(level_width):
			var pos: Vector2i = Vector2i(x, y)
			var region_value: Variant = _get_level_grid_value("region_map", pos)
			var gem_value: Variant = _get_level_grid_value("initial_gems", pos)
			if region_value == null:
				if gem_value != null:
					push_error("Level %s has gem on inactive cell at (%d,%d)." % [path, x, y])
				continue

			var region_id: String = str(region_value)
			if not level_region_targets.has(region_id):
				push_error("Level %s references undefined region %s at (%d,%d)." % [path, region_id, x, y])

			if gem_value != null and _color_value_to_index(gem_value) == EMPTY_COLOR:
				push_error("Level %s has invalid gem color %s at (%d,%d)." % [path, str(gem_value), x, y])


func _validate_level_grid_shape(path: String, grid_name: String) -> void:
	var grid: Array = level_data.get(grid_name, [])
	if grid.size() != level_height:
		push_error("Level %s %s row count must be %d." % [path, grid_name, level_height])
		return

	for y in range(level_height):
		var row: Array = grid[y]
		if row.size() != level_width:
			push_error("Level %s %s row %d width must be %d." % [path, grid_name, y, level_width])


func _reset_level_palette() -> void:
	remapped_bean_texture_cache.clear()
	level_colors = []
	level_color_names = []
	level_color_lookup = {}
	for color_id in LEGACY_COLOR_ID_ORDER:
		var color_index: int = int(COLOR_IDS[color_id])
		_register_level_color(color_id, GEM_COLORS[color_index], GEM_NAMES[color_index])


func _color_value_to_index(color_value: Variant) -> int:
	if color_value == null:
		return EMPTY_COLOR

	var color_key: String = str(color_value).strip_edges()
	if color_key.is_empty():
		return EMPTY_COLOR

	var normalized_key: String = color_key.to_upper()
	if level_color_lookup.has(normalized_key):
		return int(level_color_lookup[normalized_key])

	if Color.html_is_valid(color_key):
		var color: Color = Color.html(color_key)
		return _register_level_color(color_key, color, color_key)

	push_error("Unknown color value: %s" % color_key)
	return EMPTY_COLOR


func _register_level_color(color_key: String, color: Color, color_name: String) -> int:
	var normalized_key: String = color_key.strip_edges().to_upper()
	if level_color_lookup.has(normalized_key):
		return int(level_color_lookup[normalized_key])

	for existing_index in range(level_colors.size()):
		if _colors_are_equivalent(level_colors[existing_index], color):
			level_color_lookup[normalized_key] = existing_index
			return existing_index

	var color_index: int = level_colors.size()
	level_color_lookup[normalized_key] = color_index
	level_colors.append(color)
	level_color_names.append(color_name)
	return color_index


func _register_level_color_alias(color_key: String, color_index: int) -> void:
	if color_index == EMPTY_COLOR:
		return

	var normalized_key: String = color_key.strip_edges().to_upper()
	if normalized_key.is_empty() or level_color_lookup.has(normalized_key):
		return

	level_color_lookup[normalized_key] = color_index


func _colors_are_equivalent(first: Color, second: Color) -> bool:
	const COLOR_MATCH_TOLERANCE: float = 0.002
	return abs(first.r - second.r) <= COLOR_MATCH_TOLERANCE \
		and abs(first.g - second.g) <= COLOR_MATCH_TOLERANCE \
		and abs(first.b - second.b) <= COLOR_MATCH_TOLERANCE \
		and abs(first.a - second.a) <= COLOR_MATCH_TOLERANCE


func _get_level_grid_value(grid_name: String, pos: Vector2i) -> Variant:
	var grid: Array = level_data.get(grid_name, [])
	if pos.y < 0 or pos.y >= grid.size():
		return null

	var row: Array = grid[pos.y]
	if pos.x < 0 or pos.x >= row.size():
		return null

	return row[pos.x]


func _load_save_root() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var parse_result: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parse_result) != TYPE_DICTIONARY:
		return {}

	var save_root: Dictionary = parse_result
	if save_root.has("levels"):
		return save_root

	return _migrate_legacy_save(save_root)


func _migrate_legacy_save(legacy_save: Dictionary) -> Dictionary:
	var migrated: Dictionary = {
		"current_level_index": 0,
		"current_screen": SCREEN_HOME,
		"tutorial_completed": false,
		"levels": {},
	}

	var legacy_level_id: String = str(legacy_save.get("level_id", ""))
	if legacy_level_id != "":
		migrated["levels"][legacy_level_id] = legacy_save

	return migrated


func _write_save_root(save_root: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write save file: %s" % SAVE_PATH)
		return

	file.store_string(JSON.stringify(save_root))


func _load_saved_level_index() -> int:
	var save_root: Dictionary = _load_save_root()
	var saved_index: int = int(save_root.get("current_level_index", 0))
	return clampi(saved_index, 0, LEVEL_PATHS.size() - 1)


func _load_saved_screen() -> String:
	var save_root: Dictionary = _load_save_root()
	var saved_screen: String = str(save_root.get("current_screen", SCREEN_HOME))
	return SCREEN_LEVEL if saved_screen == SCREEN_LEVEL else SCREEN_HOME


func _is_tutorial_completed() -> bool:
	var save_root: Dictionary = _load_save_root()
	return bool(save_root.get("tutorial_completed", false))


func _set_tutorial_completed(value: bool) -> void:
	var save_root: Dictionary = _load_save_root()
	save_root["tutorial_completed"] = value
	if not save_root.has("levels"):
		save_root["levels"] = {}

	_write_save_root(save_root)


func _load_stamina_state() -> void:
	var save_root: Dictionary = _load_save_root()
	var now: int = _get_unix_time()
	stamina = clampi(int(save_root.get("stamina", STAMINA_MAX)), 0, STAMINA_MAX)
	stamina_last_update_unix = int(save_root.get("stamina_last_update_unix", now))
	if stamina_last_update_unix <= 0:
		stamina_last_update_unix = now

	_update_stamina_from_clock(false)


func _get_unix_time() -> int:
	return int(Time.get_unix_time_from_system())


func _update_stamina_from_clock(should_save: bool = false) -> void:
	var now: int = _get_unix_time()
	if stamina >= STAMINA_MAX:
		stamina = STAMINA_MAX
		if should_save:
			_save_navigation_state()
		return

	var elapsed: int = max(0, now - stamina_last_update_unix)
	var recovered: int = elapsed / STAMINA_RECOVERY_SECONDS
	if recovered <= 0:
		return

	stamina = min(STAMINA_MAX, stamina + recovered)
	if stamina >= STAMINA_MAX:
		stamina_last_update_unix = now
	else:
		stamina_last_update_unix += recovered * STAMINA_RECOVERY_SECONDS

	if should_save:
		_save_navigation_state()


func _consume_stamina(amount: int) -> bool:
	_update_stamina_from_clock(false)
	if stamina < amount:
		_refresh_stamina_ui()
		_save_navigation_state()
		return false

	stamina -= amount
	stamina_last_update_unix = _get_unix_time()
	_refresh_stamina_ui()
	_show_stamina_cost_float(amount)
	_save_navigation_state()
	return true


func _get_stamina_seconds_remaining() -> int:
	if stamina >= STAMINA_MAX:
		return 0

	var elapsed: int = max(0, _get_unix_time() - stamina_last_update_unix)
	return max(0, STAMINA_RECOVERY_SECONDS - elapsed)


func _format_stamina_time(seconds: int) -> String:
	var minutes: int = seconds / 60
	var remain_seconds: int = seconds % 60
	return "%02d:%02d" % [minutes, remain_seconds]


func _refresh_stamina_ui() -> void:
	if stamina_count_label == null or stamina_timer_label == null:
		return

	_update_stamina_from_clock(false)
	stamina_count_label.text = str(stamina)
	stamina_timer_label.text = "" if stamina >= STAMINA_MAX else _format_stamina_time(_get_stamina_seconds_remaining())
	if home_start_button != null:
		home_start_button.disabled = stamina < STAMINA_COST_PER_LEVEL


func _show_stamina_cost_float(amount: int) -> void:
	if stamina_count_label == null or stamina_widget == null or not stamina_widget.visible:
		return

	var float_label: Label = Label.new()
	float_label.name = "StaminaCostFloat"
	float_label.text = "-%d" % amount
	float_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	float_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	float_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	float_label.add_theme_color_override("font_color", Color("#fff4d3"))
	float_label.add_theme_color_override("font_shadow_color", Color("#0c2840"))
	float_label.add_theme_constant_override("shadow_offset_x", 2)
	float_label.add_theme_constant_override("shadow_offset_y", 3)
	float_label.add_theme_font_size_override("font_size", 38)
	float_label.size = Vector2(96.0, 56.0)
	add_child(float_label)

	var count_rect: Rect2 = stamina_count_label.get_global_rect()
	var start_position: Vector2 = count_rect.get_center() - float_label.size * 0.5 + Vector2(42.0, -4.0)
	float_label.global_position = start_position
	float_label.pivot_offset = float_label.size * 0.5
	float_label.scale = Vector2(0.92, 0.92)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(float_label, "global_position", start_position - Vector2(0.0, STAMINA_FLOAT_TEXT_RISE), STAMINA_FLOAT_TEXT_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(float_label, "modulate:a", 0.0, STAMINA_FLOAT_TEXT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(float_label, "scale", Vector2(1.16, 1.16), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_callback(float_label.queue_free)


func _on_stamina_tick() -> void:
	var previous_stamina: int = stamina
	var previous_update: int = stamina_last_update_unix
	_update_stamina_from_clock(false)
	_refresh_stamina_ui()
	if stamina != previous_stamina or stamina_last_update_unix != previous_update:
		_save_navigation_state()


func _save_navigation_state() -> void:
	var save_root: Dictionary = _load_save_root()
	if not save_root.has("levels"):
		save_root["levels"] = {}

	save_root["current_level_index"] = current_level_index
	save_root["current_screen"] = current_screen
	save_root["stamina"] = stamina
	save_root["stamina_last_update_unix"] = stamina_last_update_unix
	save_root["tutorial_completed"] = bool(save_root.get("tutorial_completed", false))
	_write_save_root(save_root)


func _save_current_session_state() -> void:
	if current_screen == SCREEN_LEVEL:
		_save_progress()
	else:
		_save_navigation_state()


func _delete_current_level_save() -> void:
	var save_root: Dictionary = _load_save_root()
	var levels: Dictionary = save_root.get("levels", {})
	var level_id: String = str(level_data.get("id", ""))
	if level_id != "" and levels.has(level_id):
		levels.erase(level_id)

	save_root["levels"] = levels
	save_root["current_level_index"] = current_level_index
	save_root["current_screen"] = current_screen
	save_root["stamina"] = stamina
	save_root["stamina_last_update_unix"] = stamina_last_update_unix
	save_root["tutorial_completed"] = bool(save_root.get("tutorial_completed", false))
	_write_save_root(save_root)


func _save_progress() -> void:
	if board_cells.is_empty() or storage_slots.is_empty():
		_save_navigation_state()
		return

	var board_colors: Array = []
	for y in range(level_height):
		var row: Array[int] = []
		for x in range(level_width):
			row.append(int(board_cells[y][x]["current_color"]))
		board_colors.append(row)

	var storage_colors: Array[int] = []
	var storage_unlocked: Array[bool] = []
	for slot in storage_slots:
		storage_colors.append(int(slot["current_color"]))
		storage_unlocked.append(bool(slot["unlocked"]))

	var completed_region_ids: Array[String] = []
	for region_key in completed_regions.keys():
		completed_region_ids.append(str(region_key))

	var level_save: Dictionary = {
		"level_id": str(level_data.get("id", "")),
		"board_colors": board_colors,
		"storage_colors": storage_colors,
		"storage_unlocked": storage_unlocked,
		"storage_color_order": storage_color_order,
		"completed_regions": completed_region_ids,
		"unlocked_slots": unlocked_slots,
		"game_won_announced": game_won_announced,
		"completed": game_won_announced,
	}

	var save_root: Dictionary = _load_save_root()
	if not save_root.has("levels"):
		save_root["levels"] = {}

	save_root["current_level_index"] = current_level_index
	save_root["current_screen"] = current_screen
	save_root["stamina"] = stamina
	save_root["stamina_last_update_unix"] = stamina_last_update_unix
	save_root["tutorial_completed"] = bool(save_root.get("tutorial_completed", false))
	save_root["levels"][str(level_data.get("id", ""))] = level_save
	_write_save_root(save_root)


func _load_progress() -> bool:
	var save_root: Dictionary = _load_save_root()
	var levels: Dictionary = save_root.get("levels", {})
	var level_id: String = str(level_data.get("id", ""))
	if not levels.has(level_id):
		return false

	var save_data: Dictionary = levels[level_id]
	if not _save_data_matches_level(save_data):
		return false

	var board_colors: Array = save_data["board_colors"]
	for y in range(level_height):
		var row: Array = board_colors[y]
		for x in range(level_width):
			board_cells[y][x]["current_color"] = int(row[x])

	var storage_colors: Array = save_data["storage_colors"]
	var storage_unlocked: Array = save_data["storage_unlocked"]
	for index in range(STORAGE_SIZE):
		storage_slots[index]["current_color"] = int(storage_colors[index])
		storage_slots[index]["unlocked"] = bool(storage_unlocked[index])

	storage_color_order = []
	var saved_order: Array = save_data.get("storage_color_order", [])
	for color in saved_order:
		storage_color_order.append(int(color))

	completed_regions.clear()
	var saved_completed_regions: Array = save_data.get("completed_regions", [])
	for region_id in saved_completed_regions:
		completed_regions[str(region_id)] = true

	_rebuild_region_completion_cache()
	unlocked_slots = int(save_data.get("unlocked_slots", level_initial_unlocked))
	for index in range(STORAGE_SIZE):
		storage_slots[index]["unlocked"] = index < unlocked_slots or bool(storage_slots[index]["unlocked"])

	game_won_announced = bool(save_data.get("game_won_announced", false))
	_clear_selection()
	return true


func _save_data_matches_level(save_data: Dictionary) -> bool:
	var board_colors: Array = save_data.get("board_colors", [])
	if board_colors.size() != level_height:
		return false

	for y in range(level_height):
		var row: Array = board_colors[y]
		if row.size() != level_width:
			return false

	var storage_colors: Array = save_data.get("storage_colors", [])
	var storage_unlocked: Array = save_data.get("storage_unlocked", [])
	return storage_colors.size() == STORAGE_SIZE and storage_unlocked.size() == STORAGE_SIZE


func _new_game(should_refresh: bool = true) -> void:
	if is_animating:
		return

	_clear_selection()
	completed_regions.clear()
	region_completion_cache.clear()
	board_gem_animation_frames.clear()
	unlocked_slots = level_initial_unlocked
	game_won_announced = false
	board_cells = []
	storage_slots = []
	storage_color_order = []

	for y in range(level_height):
		var row: Array[Dictionary] = []
		for x in range(level_width):
			var pos: Vector2i = Vector2i(x, y)
			var region_id: String = str(_get_level_grid_value("region_map", pos))
			var gem_color_id: Variant = _get_level_grid_value("initial_gems", pos)
			if _get_level_grid_value("region_map", pos) == null:
				row.append({
					"active": false,
					"region_id": "",
					"target_color": EMPTY_COLOR,
					"current_color": EMPTY_COLOR,
				})
				continue

			var target_color: int = int(level_region_targets.get(region_id, EMPTY_COLOR))
			var current_color: int = EMPTY_COLOR if gem_color_id == null else _color_value_to_index(gem_color_id)
			row.append({
				"active": true,
				"region_id": region_id,
				"target_color": target_color,
				"current_color": current_color,
			})
		board_cells.append(row)

	for index in range(STORAGE_SIZE):
		storage_slots.append({
			"unlocked": index < unlocked_slots,
			"current_color": EMPTY_COLOR,
		})

	_register_initial_completed_regions()
	_rebuild_region_completion_cache()

	if should_refresh:
		_refresh_all()


func _register_initial_completed_regions() -> void:
	_rebuild_region_completion_cache()
	for region_id in level_active_regions:
		if _is_region_complete(region_id):
			completed_regions[region_id] = true


func _on_board_pressed(pos: Vector2i) -> void:
	if is_animating:
		return

	if tutorial_active and not _can_tutorial_press_board(pos):
		return

	var cell: Dictionary = _get_board_cell(pos)
	if not cell["active"]:
		return

	var color: int = cell["current_color"]
	if _is_board_cell_correct(pos):
		return

	if selected_positions.is_empty():
		if color != EMPTY_COLOR:
			_select_board_group(pos)
		return

	if selected_source == BOARD_SOURCE and selected_positions.has(pos):
		_clear_selection()
		_refresh_all()
		return

	if color == EMPTY_COLOR:
		_try_fill_board(pos)
	else:
		_select_board_group(pos)


func _on_storage_pressed(index: int) -> void:
	if is_animating:
		return

	if tutorial_active and not _can_tutorial_press_storage(index):
		return

	var slot: Dictionary = storage_slots[index]
	var color: int = slot["current_color"]
	if selected_positions.is_empty():
		if color != EMPTY_COLOR:
			_select_storage_color(color)
		return

	if selected_source == STORAGE_SOURCE and selected_positions.has(index):
		_clear_selection()
		_refresh_all()
		return

	if color == EMPTY_COLOR:
		if slot["unlocked"] and selected_source == BOARD_SOURCE:
			_fill_storage(index)
	else:
		_select_storage_color(color)


func _on_storage_panel_gui_input(event: InputEvent) -> void:
	if not _should_fill_storage_from_panel():
		return

	if event is InputEventScreenTouch and event.pressed:
		if tutorial_active and not _can_tutorial_press_storage_panel():
			return
		_fill_storage_from_panel(event.position)
		accept_event()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if tutorial_active and not _can_tutorial_press_storage_panel():
			return
		_fill_storage_from_panel(event.position)
		accept_event()


func _should_fill_storage_from_panel() -> bool:
	return not is_animating \
		and game_started \
		and selected_source == BOARD_SOURCE \
		and not selected_positions.is_empty()


func _can_tutorial_press_board(pos: Vector2i) -> bool:
	if not _is_on_board(pos):
		return false

	var cell: Dictionary = _get_board_cell(pos)
	if tutorial_step == TUTORIAL_STEP_SELECT_BLUE:
		return selected_positions.is_empty() and cell["current_color"] == _tutorial_blue_color() and not _is_board_cell_correct(pos)
	if tutorial_step == TUTORIAL_STEP_SELECT_RED:
		return selected_positions.is_empty() and cell["current_color"] == _tutorial_red_color() and not _is_board_cell_correct(pos)
	if tutorial_step == TUTORIAL_STEP_PLACE_RED:
		return selected_source == BOARD_SOURCE and selected_color == _tutorial_red_color() and cell["current_color"] == EMPTY_COLOR and cell["target_color"] == _tutorial_red_color()
	if tutorial_step == TUTORIAL_STEP_PLACE_BLUE:
		return selected_source == STORAGE_SOURCE and selected_color == _tutorial_blue_color() and cell["current_color"] == EMPTY_COLOR and cell["target_color"] == _tutorial_blue_color()

	return false


func _can_tutorial_press_storage(index: int) -> bool:
	if index < 0 or index >= STORAGE_SIZE:
		return false

	var slot: Dictionary = storage_slots[index]
	if tutorial_step == TUTORIAL_STEP_STORE_BLUE:
		return selected_source == BOARD_SOURCE and selected_color == _tutorial_blue_color() and slot["unlocked"] and slot["current_color"] == EMPTY_COLOR
	if tutorial_step == TUTORIAL_STEP_SELECT_STORED_BLUE:
		return slot["current_color"] == _tutorial_blue_color()

	return false


func _can_tutorial_press_storage_panel() -> bool:
	return tutorial_step == TUTORIAL_STEP_STORE_BLUE \
		and selected_source == BOARD_SOURCE \
		and selected_color == _tutorial_blue_color()


func _after_tutorial_board_selected(color: int) -> void:
	if not tutorial_active:
		return

	if tutorial_step == TUTORIAL_STEP_SELECT_BLUE and color == _tutorial_blue_color():
		tutorial_step = TUTORIAL_STEP_STORE_BLUE
		_show_tutorial_hand_at_storage(0)
	elif tutorial_step == TUTORIAL_STEP_SELECT_RED and color == _tutorial_red_color():
		tutorial_step = TUTORIAL_STEP_PLACE_RED
		_show_tutorial_hand_at_board(Vector2i(0, 0))


func _after_tutorial_storage_selected(color: int) -> void:
	if not tutorial_active:
		return

	if tutorial_step == TUTORIAL_STEP_SELECT_STORED_BLUE and color == _tutorial_blue_color():
		tutorial_step = TUTORIAL_STEP_PLACE_BLUE
		_show_tutorial_hand_at_board(Vector2i(2, 0))


func _after_tutorial_fill_finished(fills_board: bool) -> void:
	if not tutorial_active:
		return

	if tutorial_step == TUTORIAL_STEP_STORE_BLUE and not fills_board:
		tutorial_storage_slot_index = _find_storage_slot_with_color(_tutorial_blue_color())
		tutorial_step = TUTORIAL_STEP_SELECT_RED
		_show_tutorial_hand_at_board(Vector2i(2, 0))
	elif tutorial_step == TUTORIAL_STEP_PLACE_RED and fills_board:
		tutorial_step = TUTORIAL_STEP_SELECT_STORED_BLUE
		if tutorial_storage_slot_index == -1:
			tutorial_storage_slot_index = _find_storage_slot_with_color(_tutorial_blue_color())
		_show_tutorial_hand_at_storage(max(tutorial_storage_slot_index, 0))
	elif tutorial_step == TUTORIAL_STEP_PLACE_BLUE and fills_board:
		tutorial_step = TUTORIAL_STEP_OUTRO
		_show_tutorial_dialog("你真是拼豆高手，接下来就拜托你啦！")


func _refresh_tutorial_hint() -> void:
	if not tutorial_active or tutorial_overlay == null or not tutorial_overlay.visible:
		return

	match tutorial_step:
		TUTORIAL_STEP_SELECT_BLUE:
			if tutorial_hand.visible:
				_position_tutorial_hand(_get_board_cell_center(Vector2i(0, 0)))
		TUTORIAL_STEP_STORE_BLUE:
			if tutorial_hand.visible:
				_position_tutorial_hand(_get_storage_slot_center(0))
		TUTORIAL_STEP_SELECT_RED:
			if tutorial_hand.visible:
				_position_tutorial_hand(_get_board_cell_center(Vector2i(2, 0)))
		TUTORIAL_STEP_PLACE_RED:
			if tutorial_hand.visible:
				_position_tutorial_hand(_get_board_cell_center(Vector2i(0, 0)))
		TUTORIAL_STEP_SELECT_STORED_BLUE:
			if tutorial_hand.visible:
				if tutorial_storage_slot_index == -1:
					tutorial_storage_slot_index = _find_storage_slot_with_color(_tutorial_blue_color())
				_position_tutorial_hand(_get_storage_slot_center(max(tutorial_storage_slot_index, 0)))
		TUTORIAL_STEP_PLACE_BLUE:
			if tutorial_hand.visible:
				_position_tutorial_hand(_get_board_cell_center(Vector2i(2, 0)))


func _tutorial_blue_color() -> int:
	return _color_value_to_index("B")


func _tutorial_red_color() -> int:
	return _color_value_to_index("R")


func _find_storage_slot_with_color(color: int) -> int:
	for index in range(STORAGE_SIZE):
		if int(storage_slots[index]["current_color"]) == color:
			return index

	return -1


func _fill_storage_from_panel(panel_position: Vector2) -> void:
	var clicked_index: int = _get_storage_index_at_panel_position(panel_position)
	if clicked_index == -1:
		clicked_index = _get_first_unlocked_empty_storage_index()

	if clicked_index != -1:
		_fill_storage(clicked_index)


func _select_board_group(start: Vector2i) -> void:
	var start_color: int = _get_board_cell(start)["current_color"]
	if start_color == EMPTY_COLOR or _is_board_cell_correct(start):
		return

	selected_source = BOARD_SOURCE
	selected_color = start_color
	selected_positions = _find_connected_board_color(start, start_color)
	_refresh_all()
	_play_sfx(SFX_SELECT)
	_after_tutorial_board_selected(start_color)


func _select_storage_color(color: int) -> void:
	if color == EMPTY_COLOR:
		return

	selected_source = STORAGE_SOURCE
	selected_color = color
	selected_positions = []
	for index in range(STORAGE_SIZE):
		if storage_slots[index]["current_color"] == color:
			selected_positions.append(index)
	_refresh_all()
	_play_sfx(SFX_SELECT)
	_after_tutorial_storage_selected(color)


func _try_fill_board(start: Vector2i) -> bool:
	var cell: Dictionary = _get_board_cell(start)
	if cell["target_color"] != selected_color:
		return false

	var targets: Array = _find_connected_board_empty_targets(start, selected_color)
	if targets.is_empty():
		return false

	var fill_count: int = min(selected_positions.size(), targets.size())
	if fill_count <= 0:
		return false

	var moves: Array[Dictionary] = []
	for i in range(fill_count):
		var source: Variant = selected_positions[i]
		var target: Vector2i = targets[i]
		moves.append(_make_board_move(source, target, selected_color))

	_start_fill_sequence(moves, fill_count, selected_source == STORAGE_SOURCE, true, selected_source == STORAGE_SOURCE)
	return true


func _fill_storage(clicked_index: int) -> bool:
	var targets: Array = _get_unlocked_empty_storage_indices(clicked_index)
	var fill_count: int = min(selected_positions.size(), targets.size())
	if fill_count <= 0:
		return false

	var moves: Array[Dictionary] = []
	for i in range(fill_count):
		var source: Variant = selected_positions[i]
		var target_index: int = targets[i]
		moves.append(_make_storage_move(source, target_index, selected_color))

	_register_storage_color(selected_color)
	_start_fill_sequence(moves, fill_count, true, false, false)
	return true


func _start_fill_sequence(moves: Array[Dictionary], fill_count: int, should_sort_storage: bool, fills_board: bool, can_play_storage_reorder_sfx: bool) -> void:
	is_animating = true
	var storage_before_sort: Array[int] = _get_storage_color_layout()
	_refresh_all()

	await _animate_moves(moves)
	_update_selection_after_fill(fill_count)

	if should_sort_storage:
		_sort_storage()
		_rebuild_storage_selection_after_sort()
		if can_play_storage_reorder_sfx and _should_play_storage_reorder_sfx(storage_before_sort):
			_play_sfx(SFX_GETIN)

	if fills_board:
		_play_sfx(SFX_FILL)

	var newly_completed_regions: Array[String] = _update_region_completion_and_unlocks()
	if not newly_completed_regions.is_empty():
		_play_region_flash(newly_completed_regions)

	var should_finish_level: bool = false
	if _is_game_complete() and not game_won_announced:
		game_won_announced = true
		_play_sfx(SFX_VICTORY)
		should_finish_level = true
	elif not newly_completed_regions.is_empty():
		_play_sfx(SFX_COMPLETE)

	is_animating = false
	_refresh_all()
	_save_progress()
	_after_tutorial_fill_finished(fills_board)
	if should_finish_level and not tutorial_active:
		_advance_to_next_level()


func _remove_move_source_gem(move: Dictionary) -> void:
	var source_type: String = move["source_type"]
	if source_type == BOARD_SOURCE:
		var pos: Vector2i = move["source"]
		board_cells[pos.y][pos.x]["current_color"] = EMPTY_COLOR
	elif source_type == STORAGE_SOURCE:
		var slot_index: int = move["source"]
		storage_slots[slot_index]["current_color"] = EMPTY_COLOR


func _make_board_move(source: Variant, target: Vector2i, color: int) -> Dictionary:
	return {
		"source_type": selected_source,
		"source": source,
		"from": _get_selected_source_center(source),
		"to": _get_board_cell_center(target),
		"target_type": BOARD_SOURCE,
		"target": target,
		"color": color,
	}


func _make_storage_move(source: Variant, target_index: int, color: int) -> Dictionary:
	return {
		"source_type": selected_source,
		"source": source,
		"from": _get_selected_source_center(source),
		"to": _get_storage_slot_center(target_index),
		"target_type": STORAGE_SOURCE,
		"target": target_index,
		"color": color,
	}


func _animate_moves(moves: Array[Dictionary]) -> void:
	for move_index in range(moves.size()):
		var move: Dictionary = moves[move_index]
		_remove_move_source_gem(move)
		_refresh_all()
		await _animate_single_move(move)
		_apply_move_target(move)

		if move_index < moves.size() - 1:
			await get_tree().create_timer(FLY_GAP).timeout


func _animate_single_move(move: Dictionary) -> void:
	var flyer: TextureRect = TextureRect.new()
	var color: int = move["color"]
	var flyer_size: float = _get_flyer_size()
	flyer.texture = _get_remapped_bean_texture(bean_texture, color)
	flyer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flyer.stretch_mode = TextureRect.STRETCH_SCALE
	flyer.size = Vector2(flyer_size, flyer_size)
	flyer.pivot_offset = Vector2(flyer_size * 0.5, flyer_size * 0.5)
	var from_position: Vector2 = move["from"]
	var to_position: Vector2 = move["to"]
	flyer.position = from_position - flyer.pivot_offset
	flyer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flyer.modulate = Color.WHITE
	fly_layer.add_child(flyer)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(flyer, "position", to_position - flyer.pivot_offset, FLY_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(flyer, "scale", Vector2(1.04, 1.04), FLY_DURATION * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(flyer, "scale", Vector2.ONE, FLY_DURATION * 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await tween.finished
	flyer.queue_free()


func _apply_move_target(move: Dictionary) -> void:
	var color: int = move["color"]
	if move["target_type"] == BOARD_SOURCE:
		var target: Vector2i = move["target"]
		board_cells[target.y][target.x]["current_color"] = color
		if _is_board_cell_correct(target):
			_play_board_gem_place_animation(target)
	elif move["target_type"] == STORAGE_SOURCE:
		var target_index: int = move["target"]
		storage_slots[target_index]["current_color"] = color

	_play_sfx(SFX_PUTIN)
	_refresh_all()


func _update_selection_after_fill(fill_count: int) -> void:
	if fill_count >= selected_positions.size():
		_clear_selection()
		return

	if selected_source == BOARD_SOURCE:
		selected_positions = selected_positions.slice(fill_count)
	elif selected_source == STORAGE_SOURCE:
		selected_positions = []
		for index in range(STORAGE_SIZE):
			if storage_slots[index]["current_color"] == selected_color:
				selected_positions.append(index)


func _clear_selection() -> void:
	selected_source = ""
	selected_color = EMPTY_COLOR
	selected_positions = []


func _get_board_gem_texture(pos: Vector2i, color_index: int) -> Texture2D:
	var source_texture: Texture2D = bean_texture
	if board_gem_animation_frames.has(pos):
		var frame_index: int = int(board_gem_animation_frames[pos])
		if frame_index >= 0 and frame_index < bean_animation_textures.size():
			source_texture = bean_animation_textures[frame_index]

	return _get_remapped_bean_texture(source_texture, color_index)


func _get_remapped_bean_texture(source_texture: Texture2D, color_index: int) -> Texture2D:
	if source_texture == null:
		return bean_texture

	var cache_key: String = "%d:%d" % [source_texture.get_instance_id(), color_index]
	if remapped_bean_texture_cache.has(cache_key):
		return remapped_bean_texture_cache[cache_key]

	var source_image: Image = source_texture.get_image()
	var remapped_image: Image = Image.create(source_image.get_width(), source_image.get_height(), false, Image.FORMAT_RGBA8)
	var gem_color: Color = _get_level_color(color_index)
	for y in range(source_image.get_height()):
		for x in range(source_image.get_width()):
			var source_color: Color = source_image.get_pixel(x, y)
			var blue_weight: float = source_color.b
			var green_weight: float = source_color.g
			var alpha: float = source_color.a
			var output_color: Color = gem_color * blue_weight + Color.WHITE * green_weight
			output_color.a = alpha
			remapped_image.set_pixel(x, y, output_color)

	var remapped_texture: ImageTexture = ImageTexture.create_from_image(remapped_image)
	remapped_bean_texture_cache[cache_key] = remapped_texture
	return remapped_texture


func _play_board_gem_place_animation(pos: Vector2i) -> void:
	if bean_animation_textures.is_empty():
		return

	_run_board_gem_place_animation(pos)


func _run_board_gem_place_animation(pos: Vector2i) -> void:
	var frame_delay: float = 1.0 / BEAN_PLACE_ANIMATION_FPS
	var original_color: int = int(_get_board_cell(pos)["current_color"])
	for frame_index in range(min(BEAN_PLACE_ANIMATION_FRAMES, bean_animation_textures.size())):
		if not _is_on_board(pos) or int(_get_board_cell(pos)["current_color"]) != original_color:
			board_gem_animation_frames.erase(pos)
			_refresh_board()
			return

		board_gem_animation_frames[pos] = frame_index
		_refresh_board()
		await get_tree().create_timer(frame_delay).timeout

	board_gem_animation_frames.erase(pos)
	_refresh_board()


func _update_region_completion_and_unlocks() -> Array[String]:
	_rebuild_region_completion_cache()
	var newly_completed_regions: Array[String] = []
	for region_id in level_active_regions:
		if completed_regions.has(region_id):
			continue

		if _is_region_complete(region_id):
			completed_regions[region_id] = true
			newly_completed_regions.append(region_id)

	if not newly_completed_regions.is_empty():
		unlocked_slots = min(STORAGE_SIZE, unlocked_slots + newly_completed_regions.size() * level_unlock_per_completed_region)
		for index in range(STORAGE_SIZE):
			storage_slots[index]["unlocked"] = index < unlocked_slots

	return newly_completed_regions


func _rebuild_region_completion_cache() -> void:
	region_completion_cache.clear()
	for region_id in level_active_regions:
		region_completion_cache[region_id] = _compute_region_complete(region_id)


func _is_region_complete(region_id: String) -> bool:
	if region_completion_cache.has(region_id):
		return bool(region_completion_cache[region_id])

	var is_complete: bool = _compute_region_complete(region_id)
	region_completion_cache[region_id] = is_complete
	return is_complete


func _compute_region_complete(region_id: String) -> bool:
	if not level_region_targets.has(region_id):
		return false

	var target_color: int = int(level_region_targets.get(region_id, EMPTY_COLOR))
	for y in range(level_height):
		for x in range(level_width):
			var cell: Dictionary = board_cells[y][x]
			if cell["active"] and cell["region_id"] == region_id and cell["current_color"] != target_color:
				return false
	return true


func _is_game_complete() -> bool:
	for region_id in level_active_regions:
		if not _is_region_complete(region_id):
			return false
	return true


func _play_region_flash(region_ids: Array[String]) -> void:
	for y in range(level_height):
		for x in range(level_width):
			var cell: Dictionary = board_cells[y][x]
			if not cell["active"] or not region_ids.has(cell["region_id"]):
				continue

			var pos: Vector2i = Vector2i(x, y)
			var flash: Panel = Panel.new()
			flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var scaled_size: Vector2 = Vector2(board_cell_size, board_cell_size) * board_content.scale.x
			flash.size = scaled_size
			flash.pivot_offset = scaled_size * 0.5
			flash.position = _get_board_cell_center(pos) - scaled_size * 0.5
			flash.add_theme_stylebox_override("panel", _make_panel_style(Color(1.0, 1.0, 1.0, 0.82), Color(1.0, 0.95, 0.68, 0.72), 2, 10, 0))
			fly_layer.add_child(flash)

			var tween: Tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(flash, "modulate:a", 0.0, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(flash, "scale", Vector2(1.16, 1.16), 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.finished.connect(flash.queue_free)


func _find_connected_board_color(start: Vector2i, color: int) -> Array:
	var result: Array[Vector2i] = []
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {}
	visited[start] = true

	while not queue.is_empty():
		var pos: Vector2i = queue.pop_front()
		result.append(pos)

		for neighbor in _get_neighbors(pos):
			if visited.has(neighbor):
				continue

			var cell: Dictionary = _get_board_cell(neighbor)
			if cell["active"] and cell["current_color"] == color and not _is_board_cell_correct(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)

	return result


func _find_connected_board_empty_targets(start: Vector2i, target_color: int) -> Array:
	var result: Array[Vector2i] = []
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {}
	visited[start] = true

	while not queue.is_empty():
		var pos: Vector2i = queue.pop_front()
		result.append(pos)

		for neighbor in _get_neighbors(pos):
			if visited.has(neighbor):
				continue

			var cell: Dictionary = _get_board_cell(neighbor)
			if cell["active"] and cell["current_color"] == EMPTY_COLOR and cell["target_color"] == target_color:
				visited[neighbor] = true
				queue.append(neighbor)

	return result


func _get_neighbors(pos: Vector2i) -> Array:
	var neighbors: Array[Vector2i] = []
	for y_offset in range(-1, 2):
		for x_offset in range(-1, 2):
			if x_offset == 0 and y_offset == 0:
				continue

			var neighbor: Vector2i = Vector2i(pos.x + x_offset, pos.y + y_offset)
			if _is_on_board(neighbor):
				neighbors.append(neighbor)

	return neighbors


func _is_on_board(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= level_width or pos.y < 0 or pos.y >= level_height:
		return false

	return board_cells[pos.y][pos.x]["active"]


func _get_board_cell(pos: Vector2i) -> Dictionary:
	return board_cells[pos.y][pos.x]


func _get_board_cell_center(pos: Vector2i) -> Vector2:
	var local_center: Vector2 = Vector2((float(pos.x) + 0.5) * (board_cell_size + BOARD_GAP), (float(pos.y) + 0.5) * (board_cell_size + BOARD_GAP))
	return board_grid.get_global_transform_with_canvas() * local_center - get_global_rect().position


func _get_storage_slot_center(index: int) -> Vector2:
	var button: Button = storage_buttons[index]
	return button.get_global_rect().get_center() - get_global_rect().position


func _get_selected_source_center(source: Variant) -> Vector2:
	if selected_source == BOARD_SOURCE:
		return _get_board_cell_center(source)

	return _get_storage_slot_center(source)


func _get_flyer_size() -> float:
	return clamp(board_cell_size * board_content.scale.x * 0.52 * GEM_TEXTURE_SCALE, FLYER_MIN_SIZE, FLYER_MAX_SIZE)


func _is_board_cell_correct(pos: Vector2i) -> bool:
	var cell: Dictionary = _get_board_cell(pos)
	return cell["active"] and cell["current_color"] != EMPTY_COLOR and cell["current_color"] == cell["target_color"]


func _get_unlocked_empty_storage_indices(clicked_index: int) -> Array:
	var result: Array[int] = []
	if storage_slots[clicked_index]["unlocked"] and storage_slots[clicked_index]["current_color"] == EMPTY_COLOR:
		result.append(clicked_index)

	for index in range(STORAGE_SIZE):
		if index == clicked_index:
			continue

		if storage_slots[index]["unlocked"] and storage_slots[index]["current_color"] == EMPTY_COLOR:
			result.append(index)

	return result


func _get_first_unlocked_empty_storage_index() -> int:
	for index in range(STORAGE_SIZE):
		if storage_slots[index]["unlocked"] and storage_slots[index]["current_color"] == EMPTY_COLOR:
			return index

	return -1


func _get_storage_index_at_panel_position(panel_position: Vector2) -> int:
	var global_position: Vector2 = storage_panel.get_global_rect().position + panel_position
	for index in range(STORAGE_SIZE):
		var button: Button = storage_buttons[index]
		if button.get_global_rect().has_point(global_position):
			return index

	return -1


func _sort_storage() -> void:
	var color_counts: Dictionary = {}
	for slot in storage_slots:
		if slot["current_color"] != EMPTY_COLOR:
			var color: int = slot["current_color"]
			color_counts[color] = color_counts.get(color, 0) + 1

	_prune_storage_color_order(color_counts)

	var colors: Array[int] = []
	for color in storage_color_order:
		var count: int = color_counts.get(color, 0)
		for index in range(count):
			colors.append(color)

	for index in range(STORAGE_SIZE):
		storage_slots[index]["current_color"] = colors[index] if index < colors.size() else EMPTY_COLOR


func _get_storage_color_layout() -> Array[int]:
	var layout: Array[int] = []
	for slot in storage_slots:
		if slot["current_color"] != EMPTY_COLOR:
			layout.append(slot["current_color"])

	return layout


func _should_play_storage_reorder_sfx(before_layout: Array[int]) -> bool:
	var after_layout: Array[int] = _get_storage_color_layout()
	if before_layout == after_layout:
		return false

	var shared_count: int = min(before_layout.size(), after_layout.size())
	for index in range(shared_count):
		if before_layout[index] != after_layout[index]:
			return true

	return after_layout.size() > before_layout.size()


func _register_storage_color(color: int) -> void:
	if color != EMPTY_COLOR and not storage_color_order.has(color):
		storage_color_order.append(color)


func _prune_storage_color_order(color_counts: Dictionary) -> void:
	var active_order: Array[int] = []
	for color in storage_color_order:
		if color_counts.has(color):
			active_order.append(color)

	storage_color_order = active_order


func _rebuild_storage_selection_after_sort() -> void:
	if selected_source != STORAGE_SOURCE or selected_color == EMPTY_COLOR:
		return

	selected_positions = []
	for index in range(STORAGE_SIZE):
		if storage_slots[index]["current_color"] == selected_color:
			selected_positions.append(index)


func _setup_audio() -> void:
	sfx_streams[SFX_SELECT] = load("res://sounds/game-choose.mp3")
	sfx_streams[SFX_FILL] = load("res://sounds/game-afteputin.mp3")
	sfx_streams[SFX_PUTIN] = load("res://sounds/game-putin.mp3")
	sfx_streams[SFX_GETIN] = load("res://sounds/game-getin.mp3")
	sfx_streams[SFX_COMPLETE] = load("res://sounds/game-complate.mp3")
	sfx_streams[SFX_VICTORY] = load("res://sounds/game-complate.mp3")

	for index in range(SFX_PLAYER_COUNT):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = "Master"
		player.volume_db = SFX_DEFAULT_VOLUME_DB
		add_child(player)
		sfx_players.append(player)


func _play_sfx(name: String) -> void:
	if not sfx_streams.has(name) or sfx_players.is_empty():
		return

	var player: AudioStreamPlayer = sfx_players[sfx_player_index]
	sfx_player_index = (sfx_player_index + 1) % sfx_players.size()
	player.stop()
	player.stream = sfx_streams[name]
	player.volume_db = SFX_PUTIN_VOLUME_DB if name == SFX_PUTIN else SFX_DEFAULT_VOLUME_DB
	player.play()


func _refresh_all() -> void:
	_refresh_board()
	_refresh_storage()
	_refresh_status()
	_refresh_tutorial_hint()


func _refresh_board() -> void:
	if board_grid != null:
		board_grid.queue_redraw()


func _refresh_storage() -> void:
	for index in range(STORAGE_SIZE):
		var button: Button = storage_buttons[index]
		var slot_background: TextureRect = storage_slot_textures[index]
		var gem_texture: TextureRect = storage_gem_textures[index]
		var slot: Dictionary = storage_slots[index]
		var color: int = slot["current_color"]
		var unlocked: bool = slot["unlocked"]
		var is_selected: bool = selected_source == STORAGE_SOURCE and selected_positions.has(index)

		button.text = ""
		button.disabled = not unlocked
		slot_background.visible = true
		slot_background.modulate = Color.WHITE if unlocked else Color("#676a70")
		gem_texture.visible = unlocked and color != EMPTY_COLOR
		gem_texture.texture = _get_remapped_bean_texture(bean_texture, color) if color != EMPTY_COLOR else bean_texture
		gem_texture.modulate = Color.WHITE
		gem_texture.scale = Vector2.ONE
		var gem_base_position: Vector2 = storage_gem_base_positions[index]
		var lift_offset: float = gem_texture.size.y * SELECTED_GEM_LIFT_RATIO if is_selected else 0.0
		gem_texture.position = gem_base_position - Vector2(0.0, lift_offset)


func _refresh_status() -> void:
	unlocked_label.text = "Unlocked %d/%d" % [unlocked_slots, STORAGE_SIZE]

	if _is_game_complete():
		status_label.text = "Victory"
	elif selected_positions.is_empty():
		status_label.text = "Select jewels"
	else:
		var source_name: String = "board" if selected_source == BOARD_SOURCE else "storage"
		status_label.text = "%s x%d from %s" % [_get_color_name(selected_color), selected_positions.size(), source_name]


func _get_board_text(current_color: int, target_color: int) -> String:
	var target_hint: String = _get_color_name(target_color).substr(0, 1)
	if current_color == EMPTY_COLOR:
		return "\n[%s]" % target_hint

	return "%s\n[%s]" % [_get_color_name(current_color).substr(0, 1), target_hint]


func _make_cell_style(current_color: int, target_color: int, selected: bool, complete: bool) -> StyleBoxFlat:
	var fill: Color = Color("#334253") if current_color == EMPTY_COLOR else _get_level_color(current_color)
	if current_color == EMPTY_COLOR:
		fill = _get_level_color(target_color).darkened(0.68)
	elif complete:
		fill = _get_level_color(current_color).lightened(0.12)

	var border: Color = _get_level_color(target_color).darkened(0.18)
	if selected:
		border = Color("#fff4a8")
	elif complete:
		border = Color("#efffd8")

	return _make_panel_style(fill, border, 4 if selected else 2, 8)


func _get_texture_tint(color_index: int, complete: bool) -> Color:
	if color_index == EMPTY_COLOR:
		return Color.WHITE

	return _get_level_color(color_index)


func _get_level_color(color_index: int) -> Color:
	if color_index < 0 or color_index >= level_colors.size():
		return Color.WHITE

	return level_colors[color_index]


func _get_color_name(color_index: int) -> String:
	if color_index < 0 or color_index >= level_color_names.size():
		return "Unknown"

	return level_color_names[color_index]


func _make_panel_style(fill: Color, border: Color, border_width: int, radius: int, margin: int = 8) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = margin
	style.content_margin_top = margin
	style.content_margin_right = margin
	style.content_margin_bottom = margin
	return style
