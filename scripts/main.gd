extends Node2D

enum CropState {
	UNTILLED,
	TILLED,
	SEEDED,
	WATERED,
	MATURE,
}

enum Tool {
	HOE,
	SEEDS,
	WATER,
	AXE,
	SWORD,
	PHYSICAL,
	SPELL,
}

enum PlacementMode {
	NONE,
	CABIN,
	FARM,
}

const SCREEN_SIZE := Vector2(1280, 720)
const PLAYER_SPEED := 155.0
const PLAYER_RADIUS := 18.0
const PLAYER_START := Vector2(650, 430)
const INTERACT_DISTANCE := 74.0
const CROP_GROW_TIME := 12.0
const DAY_LENGTH := 150.0
const ACTION_DURATION := 0.28
const SKILL_DURATION := 0.46
const HOMESTEAD_BASE_PATH := "res://art/maps/homestead_v1/base.png"
const CABIN_PATH := "res://art/sprites/buildings/player_cabin/cabin.png"
const TREE_PATH := "res://art/sprites/props/choppable_tree/tree.png"
const FARM_TILLED_PATH := "res://art/sprites/props/farm_plot_states/tilled.png"
const FARM_SEEDED_PATH := "res://art/sprites/props/farm_plot_states/seeded.png"
const FARM_WATERED_PATH := "res://art/sprites/props/farm_plot_states/watered.png"
const FARM_MATURE_PATH := "res://art/sprites/props/farm_plot_states/mature.png"
const PLAYER_IDLE_PATH := "res://art/sprites/player/guardian_youth/idle.png"
const PLAYER_WALK_PATH := "res://art/sprites/player/guardian_youth/walk.png"
const PLAYER_ATTACK_PATH := "res://art/sprites/player/guardian_youth/attack.png"
const PLAYER_PHYSICAL_PATH := "res://art/sprites/player/guardian_youth/physical.png"
const PLAYER_CAST_PATH := "res://art/sprites/player/guardian_youth/cast.png"
const TREE_VARIANT_PATHS := [
	"res://art/sprites/props/choppable_tree/tree.png",
	"res://art/sprites/props/choppable_tree/tree_variant_a.png",
	"res://art/sprites/props/choppable_tree/tree_variant_b.png",
]
const SAFE_BUILD_AREA := Rect2(Vector2(100, 118), Vector2(930, 502))
const POLLUTED_EDGE_X := 1010.0
const CABIN_VISUAL_SIZE := Vector2(184, 184)
const CABIN_FOOTPRINT := Vector2(118, 78)
const FARM_VISUAL_SIZE := Vector2(112, 84)
const FARM_FOOTPRINT := Vector2(84, 56)
const TREE_VISUAL_SIZE := Vector2(86, 122)
const TREE_COLLISION_RADIUS := 30.0

var player_position := PLAYER_START
var player_facing := Vector2(0, 1)
var action_timer := 0.0
var action_tool := Tool.HOE
var action_facing := Vector2(0, 1)
var placement_mode := PlacementMode.NONE
var placement_rotation := 0
var day_time := 0.24
var day_count := 1
var herbs := 0
var wood := 0
var player_is_moving := false
var action_label_timer := 0.0
var action_label_text := ""
var homestead_base: Texture2D
var cabin_texture: Texture2D
var player_idle_sheet: Texture2D
var player_walk_sheet: Texture2D
var player_attack_sheet: Texture2D
var player_physical_sheet: Texture2D
var player_cast_sheet: Texture2D
var farm_plot_textures: Dictionary = {}
var tree_textures: Array[Texture2D] = []

var plots: Array[Dictionary] = []
var trees: Array[Dictionary] = []
var cabins: Array[Dictionary] = []

var resource_label: Label
var tool_label: Label
var objective_label: Label
var log_label: Label


func _ready() -> void:
	homestead_base = load(HOMESTEAD_BASE_PATH) as Texture2D if ResourceLoader.exists(HOMESTEAD_BASE_PATH) else null
	cabin_texture = load(CABIN_PATH) as Texture2D if ResourceLoader.exists(CABIN_PATH) else null
	player_idle_sheet = load(PLAYER_IDLE_PATH) as Texture2D if ResourceLoader.exists(PLAYER_IDLE_PATH) else null
	player_walk_sheet = load(PLAYER_WALK_PATH) as Texture2D if ResourceLoader.exists(PLAYER_WALK_PATH) else null
	player_attack_sheet = load(PLAYER_ATTACK_PATH) as Texture2D if ResourceLoader.exists(PLAYER_ATTACK_PATH) else null
	player_physical_sheet = load(PLAYER_PHYSICAL_PATH) as Texture2D if ResourceLoader.exists(PLAYER_PHYSICAL_PATH) else null
	player_cast_sheet = load(PLAYER_CAST_PATH) as Texture2D if ResourceLoader.exists(PLAYER_CAST_PATH) else null
	tree_textures.clear()
	for path in TREE_VARIANT_PATHS:
		if ResourceLoader.exists(path):
			tree_textures.append(load(path) as Texture2D)
	farm_plot_textures = {
		CropState.TILLED: load(FARM_TILLED_PATH) as Texture2D if ResourceLoader.exists(FARM_TILLED_PATH) else null,
		CropState.SEEDED: load(FARM_SEEDED_PATH) as Texture2D if ResourceLoader.exists(FARM_SEEDED_PATH) else null,
		CropState.WATERED: load(FARM_WATERED_PATH) as Texture2D if ResourceLoader.exists(FARM_WATERED_PATH) else null,
		CropState.MATURE: load(FARM_MATURE_PATH) as Texture2D if ResourceLoader.exists(FARM_MATURE_PATH) else null,
	}
	_setup_world()
	_setup_ui()
	_log("WASD 移动。B 建造木屋，F 开垦农田，点击农田照料，点击树木砍伐。")


func _process(delta: float) -> void:
	_update_player(delta)
	_update_crops(delta)
	_update_day_cycle(delta)
	_update_action(delta)
	_update_ui()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			if mouse_event.button_index == MOUSE_BUTTON_LEFT:
				_handle_left_click(mouse_event.position)
			elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
				_cancel_placement()
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			match key_event.keycode:
				KEY_ESCAPE:
					_cancel_placement()
				KEY_B:
					_start_placement(PlacementMode.CABIN)
				KEY_F:
					_start_placement(PlacementMode.FARM)
				KEY_Q:
					_rotate_placement(-1)
				KEY_E:
					_rotate_placement(1)
				KEY_SPACE, KEY_J:
					_start_action(Tool.SWORD)
					_perform_sword_attack()
				KEY_K:
					_start_action(Tool.PHYSICAL)
					_perform_physical_skill()
				KEY_L:
					_start_action(Tool.SPELL)
					_perform_spell_skill()


func _draw() -> void:
	_draw_world()
	_draw_plots()
	_draw_interactive_props()
	_draw_placement_preview()
	_draw_player()
	_draw_action_effect()
	_draw_day_overlay()


func _setup_world() -> void:
	plots.clear()
	trees.clear()
	cabins.clear()

	trees = [
		{"pos": Vector2(238, 244), "hp": 3, "variant": 0, "scale": 0.86, "flip": false},
		{"pos": Vector2(310, 560), "hp": 3, "variant": 1, "scale": 0.72, "flip": true},
		{"pos": Vector2(1048, 252), "hp": 3, "variant": 2, "scale": 0.78, "flip": false},
		{"pos": Vector2(1114, 514), "hp": 3, "variant": 0, "scale": 0.68, "flip": true},
	]


func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.position = Vector2(20, 18)
	panel.custom_minimum_size = Vector2(430, 0)
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var title := Label.new()
	title.text = "灯火边境：家园原型"
	title.add_theme_font_size_override("font_size", 22)
	box.add_child(title)

	resource_label = Label.new()
	box.add_child(resource_label)

	tool_label = Label.new()
	box.add_child(tool_label)

	objective_label = Label.new()
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(objective_label)

	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(log_label)


func _update_player(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1.0

	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	player_is_moving = input_vector.length() > 0.01
	if player_is_moving:
		player_facing = input_vector.normalized()
		var target_position := player_position + input_vector * PLAYER_SPEED * delta
		if _can_move_to(target_position):
			player_position = target_position


func _can_move_to(target_position: Vector2) -> bool:
	if target_position.x < 62 or target_position.x > SCREEN_SIZE.x - 62:
		return false
	if target_position.y < 92 or target_position.y > SCREEN_SIZE.y - 66:
		return false

	var body_rect := Rect2(target_position - Vector2(PLAYER_RADIUS, PLAYER_RADIUS), Vector2(PLAYER_RADIUS * 2, PLAYER_RADIUS * 2))
	for blocker in _get_blocking_rects():
		if body_rect.intersects(blocker):
			return false
	for tree in trees:
		var tree_pos := tree["pos"] as Vector2
		var tree_scale := float(tree.get("scale", 1.0))
		if tree_pos.distance_to(target_position) < TREE_COLLISION_RADIUS * tree_scale + PLAYER_RADIUS:
			return false
	return true


func _update_crops(delta: float) -> void:
	for plot in plots:
		if int(plot["state"]) == CropState.WATERED:
			plot["timer"] = maxf(0.0, float(plot["timer"]) - delta)
			if float(plot["timer"]) <= 0.0:
				plot["state"] = CropState.MATURE
				_log("一块药草成熟了。")


func _update_day_cycle(delta: float) -> void:
	day_time += delta / DAY_LENGTH
	if day_time >= 1.0:
		day_time -= 1.0
		day_count += 1
		_log("第 %d 天开始。安全灯仍然亮着。" % day_count)


func _update_action(delta: float) -> void:
	action_timer = maxf(0.0, action_timer - delta)
	action_label_timer = maxf(0.0, action_label_timer - delta)


func _update_ui() -> void:
	resource_label.text = "第 %d 天  %s\n药草 %d | 木材 %d | 农田：%s" % [
		day_count,
		_get_time_label(),
		herbs,
		wood,
		_get_plot_summary_text(),
	]

	if placement_mode == PlacementMode.NONE:
		tool_label.text = "建造：B 木屋 | F 农田\n战斗：J/空格 挥砍 | K 冲击 | L 星火"
	else:
		tool_label.text = "放置中：%s  旋转 Q/E\n左键确认，右键或 Esc 取消" % _placement_name()

	objective_label.text = "目标：%s" % _get_objective_text()


func _start_action(tool: int) -> void:
	if action_timer > 0.0:
		return
	action_tool = tool
	action_facing = player_facing
	action_timer = SKILL_DURATION if tool == Tool.PHYSICAL or tool == Tool.SPELL else ACTION_DURATION


func _handle_left_click(screen_position: Vector2) -> void:
	if placement_mode != PlacementMode.NONE:
		_try_place_at(screen_position)
		return
	var plot := _plot_at(screen_position)
	if not plot.is_empty():
		_interact_plot(plot)
		return
	var tree := _tree_at(screen_position)
	if not tree.is_empty():
		_try_chop_tree(tree)
		return
	_log("点击 B 建造木屋，点击 F 开垦农田；点农田可以照料作物。")


func _interact_plot(plot: Dictionary) -> void:
	match int(plot["state"]):
		CropState.UNTILLED:
			_start_action(Tool.HOE)
			plot["state"] = CropState.TILLED
			_log("开垦了一块农田。")
		CropState.TILLED:
			_start_action(Tool.SEEDS)
			plot["state"] = CropState.SEEDED
			_log("播下药草种子。")
		CropState.SEEDED:
			_start_action(Tool.WATER)
			plot["state"] = CropState.WATERED
			plot["timer"] = CROP_GROW_TIME
			_log("浇水完成，药草开始生长。")
		CropState.WATERED:
			_show_action_text("生长中")
			_log("这块药草正在生长。")
		CropState.MATURE:
			_try_harvest_plot(plot)


func _try_chop_tree(tree: Dictionary) -> void:
	if (tree["pos"] as Vector2).distance_to(player_position) > INTERACT_DISTANCE + 28.0:
		_show_action_text("离树太远")
		return
	_start_action(Tool.AXE)
	tree["hp"] = int(tree["hp"]) - 1
	_show_action_text("砍击")
	if int(tree["hp"]) <= 0:
		wood += 3
		trees.erase(tree)
		_log("砍倒一棵变异边缘树，获得木材 +3。")
	else:
		_log("树木还很结实。")


func _try_harvest_plot(plot: Dictionary) -> bool:
	if int(plot["state"]) != CropState.MATURE:
		return false
	plot["state"] = CropState.UNTILLED
	plot["timer"] = 0.0
	herbs += 2
	_show_action_text("收获")
	_log("收获药草 +2。")
	return true


func _perform_sword_attack() -> void:
	_show_action_text("挥砍")
	_log("主角进行了一次基础挥砍。")


func _perform_physical_skill() -> void:
	_show_action_text("冲击")
	_log("释放物理技能：短距离冲击。")


func _perform_spell_skill() -> void:
	_show_action_text("星火")
	_log("释放法术技能：安全灯火的余烬。")


func _plot_at(screen_position: Vector2) -> Dictionary:
	for plot in plots:
		var rect := plot["rect"] as Rect2
		if rect.grow(18.0).has_point(screen_position):
			return plot
	return {}


func _tree_at(screen_position: Vector2) -> Dictionary:
	for tree in trees:
		var pos := tree["pos"] as Vector2
		var tree_scale := float(tree.get("scale", 1.0))
		var pick_rect := Rect2(pos + Vector2(-44, -118) * tree_scale, TREE_VISUAL_SIZE * tree_scale)
		if pick_rect.has_point(screen_position):
			return tree
	return {}


func _start_placement(mode: int) -> void:
	placement_mode = mode
	placement_rotation = 0
	_log("移动鼠标选择%s位置，绿色可建造，红色不可建造。" % _placement_name())


func _cancel_placement() -> void:
	if placement_mode == PlacementMode.NONE:
		return
	placement_mode = PlacementMode.NONE
	_log("已取消建造。")


func _rotate_placement(direction: int) -> void:
	if placement_mode == PlacementMode.NONE:
		return
	placement_rotation = wrapi(placement_rotation + direction, 0, 4)


func _try_place_at(position: Vector2) -> void:
	if not _is_placement_valid(position):
		_show_action_text("不可建造")
		_log("这里不能建造：需要在安全区内，且不能和已有物体重叠。")
		return
	match placement_mode:
		PlacementMode.CABIN:
			cabins.append({
				"pos": position,
				"rotation": placement_rotation,
			})
			_log("木屋地基已经确定，开始建造。")
		PlacementMode.FARM:
			plots.append({
				"rect": _farm_rect(position),
				"state": CropState.UNTILLED,
				"timer": 0.0,
			})
			_log("新的农田已经规划完成，点击它开始开垦。")
	placement_mode = PlacementMode.NONE


func _is_placement_valid(position: Vector2) -> bool:
	var footprint := _placement_footprint(position)
	if not SAFE_BUILD_AREA.encloses(footprint):
		return false
	if footprint.end.x > POLLUTED_EDGE_X:
		return false
	if footprint.has_point(player_position):
		return false
	for blocker in _get_blocking_rects():
		if footprint.intersects(blocker):
			return false
	for plot in plots:
		var plot_rect := plot["rect"] as Rect2
		if footprint.intersects(plot_rect.grow(8.0)):
			return false
	for tree in trees:
		var tree_pos := tree["pos"] as Vector2
		var tree_scale := float(tree.get("scale", 1.0))
		if footprint.grow(TREE_COLLISION_RADIUS * tree_scale).has_point(tree_pos):
			return false
	return true


func _placement_footprint(position: Vector2) -> Rect2:
	if placement_mode == PlacementMode.CABIN:
		return Rect2(position - CABIN_FOOTPRINT * 0.5, CABIN_FOOTPRINT)
	if placement_mode == PlacementMode.FARM:
		return _farm_rect(position)
	return Rect2(position, Vector2.ZERO)


func _farm_rect(position: Vector2) -> Rect2:
	return Rect2(position - FARM_FOOTPRINT * 0.5, FARM_FOOTPRINT)


func _get_blocking_rects() -> Array[Rect2]:
	var blockers: Array[Rect2] = [
		Rect2(Vector2(1046, 84), Vector2(174, 522)),
	]
	for cabin in cabins:
		var pos := cabin["pos"] as Vector2
		blockers.append(Rect2(pos - CABIN_FOOTPRINT * 0.5, CABIN_FOOTPRINT))
	return blockers


func _placement_name() -> String:
	if placement_mode == PlacementMode.CABIN:
		return "木屋"
	if placement_mode == PlacementMode.FARM:
		return "农田"
	return ""


func _get_plot_summary_text() -> String:
	return "%d 未开垦 | %d 已开垦 | %d 已播种 | %d 生长中 | %d 可收获" % [
		_count_plots(CropState.UNTILLED),
		_count_plots(CropState.TILLED),
		_count_plots(CropState.SEEDED),
		_count_plots(CropState.WATERED),
		_count_plots(CropState.MATURE),
	]


func _get_objective_text() -> String:
	if _count_plots(CropState.UNTILLED) > 0:
		return "点击未开垦农田，把它开垦出来。"
	if _count_plots(CropState.TILLED) > 0:
		return "点击已开垦农田播种。"
	if _count_plots(CropState.SEEDED) > 0:
		return "点击播种农田浇水。"
	if _count_plots(CropState.WATERED) > 0:
		return "等待药草成熟，也可以点击树木砍伐。"
	if _count_plots(CropState.MATURE) > 0:
		return "点击成熟药草收获。"
	return "按 B 放置木屋，按 F 放置农田。"


func _count_plots(state_value: int) -> int:
	var count := 0
	for plot in plots:
		if int(plot["state"]) == state_value:
			count += 1
	return count


func _get_time_label() -> String:
	if day_time < 0.25:
		return "深夜"
	if day_time < 0.45:
		return "清晨"
	if day_time < 0.72:
		return "白天"
	if day_time < 0.88:
		return "黄昏"
	return "夜晚"


func _show_action_text(text: String) -> void:
	action_label_text = text
	action_label_timer = 0.8


func _log(message: String) -> void:
	if log_label != null:
		log_label.text = "日志：" + message


func _draw_world() -> void:
	if homestead_base != null:
		draw_texture_rect(homestead_base, Rect2(Vector2.ZERO, SCREEN_SIZE), false)
		return
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("#243647"))
	draw_rect(Rect2(Vector2(70, 88), Vector2(1040, 540)), Color("#87b86c"))
	draw_circle(Vector2(1088, 164), 22.0, Color("#ffe28a"))
	draw_circle(Vector2(1088, 164), 44.0, Color(1.0, 0.76, 0.24, 0.14))
	draw_circle(Vector2(1088, 544), 22.0, Color("#ffe28a"))
	draw_circle(Vector2(1088, 544), 44.0, Color(1.0, 0.76, 0.24, 0.14))


func _draw_plots() -> void:
	for plot in plots:
		var rect := plot["rect"] as Rect2
		var state := int(plot["state"])
		var plot_texture := farm_plot_textures.get(state) as Texture2D
		if plot_texture != null:
			draw_texture_rect(plot_texture, Rect2(rect.get_center() - FARM_VISUAL_SIZE * 0.5, FARM_VISUAL_SIZE), false)
			if state == CropState.MATURE:
				draw_rect(rect.grow(8), Color("#fff0a6"), false, 3.0)
			elif rect.grow(18.0).has_point(get_viewport().get_mouse_position()):
				draw_rect(rect.grow(8), Color(1.0, 0.93, 0.44, 0.55), false, 2.0)
			continue
		if state == CropState.UNTILLED:
			draw_polygon(_diamond_points(rect), [Color(0.46, 0.33, 0.22, 0.28)])
			draw_polygon(_diamond_points(rect.grow(-7)), [Color(0.62, 0.48, 0.33, 0.22)])
			if rect.grow(18.0).has_point(get_viewport().get_mouse_position()):
				draw_polygon(_diamond_points(rect.grow(6)), [Color(1.0, 0.93, 0.44, 0.18)])
			continue
		draw_polygon([
			rect.position + Vector2(rect.size.x * 0.5, 0),
			rect.position + Vector2(rect.size.x, rect.size.y * 0.38),
			rect.position + Vector2(rect.size.x * 0.5, rect.size.y),
			rect.position + Vector2(0, rect.size.y * 0.38),
		], [Color("#815333")])
		match state:
			CropState.UNTILLED:
				draw_polygon(_diamond_points(rect.grow(-8)), [Color("#9f744d")])
			CropState.TILLED:
				draw_polygon(_diamond_points(rect.grow(-8)), [Color("#6f472d")])
			CropState.SEEDED:
				draw_polygon(_diamond_points(rect.grow(-8)), [Color("#6f472d")])
				draw_circle(rect.get_center(), 5.0, Color("#d7e17c"))
			CropState.WATERED:
				var progress := 1.0 - float(plot["timer"]) / CROP_GROW_TIME
				draw_polygon(_diamond_points(rect.grow(-8)), [Color("#65452e")])
				draw_rect(Rect2(rect.position + Vector2(13, rect.size.y - 10), Vector2((rect.size.x - 26) * progress, 5)), Color("#9be15c"))
				draw_circle(rect.get_center(), 8.0 + 8.0 * progress, Color("#4fac46"))
			CropState.MATURE:
				draw_polygon(_diamond_points(rect.grow(-8)), [Color("#4fac46")])
				draw_circle(rect.get_center(), 17.0, Color("#9fea75"))
				draw_rect(rect.grow(4), Color("#fff0a6"), false, 3.0)


func _draw_interactive_props() -> void:
	for cabin in cabins:
		if cabin_texture != null:
			var pos := cabin["pos"] as Vector2
			var rotation := float(int(cabin.get("rotation", 0))) * PI * 0.5
			draw_set_transform(pos, rotation, Vector2.ONE)
			draw_texture_rect(cabin_texture, Rect2(-CABIN_VISUAL_SIZE * 0.5, CABIN_VISUAL_SIZE), false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for tree in trees:
		var pos := tree["pos"] as Vector2
		var tree_scale := float(tree.get("scale", 1.0))
		var variant := int(tree.get("variant", 0))
		var tree_texture := tree_textures[variant % tree_textures.size()] if tree_textures.size() > 0 else null
		if tree_texture != null:
			var size := TREE_VISUAL_SIZE * tree_scale
			var rect := Rect2(pos + Vector2(-size.x * 0.5, -size.y), size)
			if bool(tree.get("flip", false)):
				draw_set_transform(pos, 0.0, Vector2(-1.0, 1.0))
				draw_texture_rect(tree_texture, Rect2(Vector2(-size.x * 0.5, -size.y), size), false)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			else:
				draw_texture_rect(tree_texture, rect, false)
		var distance := pos.distance_to(player_position)
		if distance <= INTERACT_DISTANCE + 12.0:
			draw_circle(pos + Vector2(0, 4), 36.0, Color(1.0, 0.92, 0.45, 0.16))
			draw_arc(pos + Vector2(0, 4), 38.0, 0.0, TAU, 28, Color("#ffe88a"), 3.0)

	for blocker in _get_blocking_rects():
		if blocker.get_center().distance_to(player_position) < 140.0:
			draw_rect(blocker, Color(1.0, 0.86, 0.38, 0.08), false, 2.0)


func _draw_placement_preview() -> void:
	if placement_mode == PlacementMode.NONE:
		return
	var mouse_pos := get_viewport().get_mouse_position()
	var footprint := _placement_footprint(mouse_pos)
	var valid := _is_placement_valid(mouse_pos)
	var color := Color(0.20, 0.95, 0.38, 0.34) if valid else Color(1.0, 0.18, 0.16, 0.34)
	var outline := Color(0.55, 1.0, 0.62, 0.95) if valid else Color(1.0, 0.34, 0.30, 0.95)
	draw_rect(footprint, color, true)
	draw_rect(footprint, outline, false, 3.0)
	if placement_mode == PlacementMode.CABIN and cabin_texture != null:
		var rotation := float(placement_rotation) * PI * 0.5
		draw_set_transform(mouse_pos, rotation, Vector2.ONE)
		draw_texture_rect(cabin_texture, Rect2(-CABIN_VISUAL_SIZE * 0.5, CABIN_VISUAL_SIZE), false, Color(1.0, 1.0, 1.0, 0.48))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	elif placement_mode == PlacementMode.FARM:
		draw_polygon(_diamond_points(footprint), [Color(color.r, color.g, color.b, 0.42)])


func _draw_player() -> void:
	var bob := sin(Time.get_ticks_msec() / 210.0) * 1.0 if player_is_moving and action_timer <= 0.0 else 0.0
	var body_pos := player_position + Vector2(0, bob)
	draw_set_transform(player_position + Vector2(0, 5), 0.0, Vector2(1.7, 0.55))
	draw_circle(Vector2.ZERO, 11.0, Color(0, 0, 0, 0.26))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var player_texture := _get_player_texture()
	var player_source := _get_player_source_rect(player_texture)
	if player_texture != null:
		draw_texture_rect_region(player_texture, Rect2(body_pos + Vector2(-31, -86), Vector2(62, 88)), player_source)
		if action_label_timer > 0.0:
			draw_string(ThemeDB.fallback_font, body_pos + Vector2(-24, -80), action_label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff1a8"))
		return
	draw_rect(Rect2(body_pos + Vector2(-15, -8), Vector2(30, 40)), Color("#4d78c9"))
	draw_circle(body_pos + Vector2(0, -24), 17.0, Color("#f0c79d"))
	draw_rect(Rect2(body_pos + Vector2(-19, -4), Vector2(38, 8)), Color("#2e4d8c"))
	draw_line(body_pos + Vector2(0, -1), body_pos + player_facing.normalized() * 34.0, Color("#ffe7a3"), 4.0)

	if action_label_timer > 0.0:
		draw_string(ThemeDB.fallback_font, body_pos + Vector2(-24, -58), action_label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff1a8"))


func _get_player_texture() -> Texture2D:
	if action_timer > 0.0:
		match action_tool:
			Tool.AXE, Tool.SWORD:
				if player_attack_sheet != null:
					return player_attack_sheet
			Tool.PHYSICAL:
				if player_physical_sheet != null:
					return player_physical_sheet
			Tool.SPELL:
				if player_cast_sheet != null:
					return player_cast_sheet
	if player_is_moving and player_walk_sheet != null:
		return player_walk_sheet
	return player_idle_sheet


func _get_player_source_rect(player_texture: Texture2D) -> Rect2:
	if player_texture == null:
		return Rect2(Vector2.ZERO, Vector2(1, 1))
	if action_timer > 0.0 and (player_texture == player_attack_sheet or player_texture == player_physical_sheet or player_texture == player_cast_sheet):
		var action_cell_size := Vector2(player_texture.get_width() / 2.0, player_texture.get_height() / 2.0)
		var duration := SKILL_DURATION if action_tool == Tool.PHYSICAL or action_tool == Tool.SPELL else ACTION_DURATION
		var progress := clampf(1.0 - action_timer / duration, 0.0, 0.999)
		var index := int(progress * 4.0)
		return Rect2(Vector2(index % 2, index / 2) * action_cell_size, action_cell_size)
	if player_texture == player_walk_sheet:
		var cell_size := Vector2(player_texture.get_width() / 4.0, player_texture.get_height() / 4.0)
		var row := _get_walk_direction_row()
		var col := int(Time.get_ticks_msec() / 220) % 4
		return Rect2(Vector2(col, row) * cell_size, cell_size)
	var idle_cell_size := Vector2(player_texture.get_width() / 2.0, player_texture.get_height() / 2.0)
	var idle_col := int(Time.get_ticks_msec() / 360) % 2
	var idle_row := int(Time.get_ticks_msec() / 720) % 2
	return Rect2(Vector2(idle_col, idle_row) * idle_cell_size, idle_cell_size)


func _get_walk_direction_row() -> int:
	if absf(player_facing.x) > absf(player_facing.y):
		return 1 if player_facing.x > 0.0 else 3
	return 0 if player_facing.y > 0.0 else 2


func _draw_action_effect() -> void:
	if action_timer <= 0.0:
		return
	var progress := 1.0 - action_timer / (SKILL_DURATION if action_tool == Tool.PHYSICAL or action_tool == Tool.SPELL else ACTION_DURATION)
	var origin := player_position + action_facing.normalized() * 42.0
	match action_tool:
		Tool.AXE, Tool.SWORD:
			var radius := 30.0 + progress * 18.0
			draw_arc(origin, radius, -1.2, 1.2, 18, Color("#fff0b2"), 6.0)
		Tool.PHYSICAL:
			draw_circle(origin + action_facing.normalized() * progress * 48.0, 28.0, Color(0.7, 0.9, 1.0, 0.38))
			draw_circle(origin + action_facing.normalized() * progress * 48.0, 12.0, Color("#d9f2ff"))
		Tool.SPELL:
			draw_circle(origin, 22.0 + progress * 28.0, Color(1.0, 0.48, 0.16, 0.28))
			draw_circle(origin, 9.0, Color("#ffd36c"))
		Tool.HOE, Tool.SEEDS, Tool.WATER:
			draw_circle(origin, 12.0 + progress * 10.0, Color(1.0, 0.95, 0.62, 0.32))


func _draw_day_overlay() -> void:
	var darkness := 0.0
	if day_time < 0.22:
		darkness = 0.46
	elif day_time < 0.32:
		darkness = lerpf(0.46, 0.08, (day_time - 0.22) / 0.1)
	elif day_time < 0.72:
		darkness = 0.05
	elif day_time < 0.9:
		darkness = lerpf(0.08, 0.42, (day_time - 0.72) / 0.18)
	else:
		darkness = 0.46
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.08, 0.12, 0.24, darkness))


func _diamond_points(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position + Vector2(rect.size.x * 0.5, 0),
		rect.position + Vector2(rect.size.x, rect.size.y * 0.38),
		rect.position + Vector2(rect.size.x * 0.5, rect.size.y),
		rect.position + Vector2(0, rect.size.y * 0.38),
	])
