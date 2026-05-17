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

const SCREEN_SIZE := Vector2(1280, 720)
const PLAYER_SPEED := 230.0
const PLAYER_RADIUS := 18.0
const PLAYER_START := Vector2(650, 430)
const INTERACT_DISTANCE := 74.0
const CROP_GROW_TIME := 12.0
const DAY_LENGTH := 150.0
const ACTION_DURATION := 0.28
const SKILL_DURATION := 0.46

const TOOLS := [
	{"id": Tool.HOE, "name": "锄头", "hint": "开垦空地"},
	{"id": Tool.SEEDS, "name": "种子", "hint": "播种药草"},
	{"id": Tool.WATER, "name": "水壶", "hint": "浇水催熟"},
	{"id": Tool.AXE, "name": "斧头", "hint": "砍树"},
	{"id": Tool.SWORD, "name": "短剑", "hint": "挥砍攻击"},
	{"id": Tool.PHYSICAL, "name": "冲击", "hint": "物理技能"},
	{"id": Tool.SPELL, "name": "星火", "hint": "法术技能"},
]

var player_position := PLAYER_START
var player_facing := Vector2(0, 1)
var selected_tool_index := 0
var action_timer := 0.0
var action_tool := Tool.HOE
var action_facing := Vector2(0, 1)
var day_time := 0.24
var day_count := 1
var herbs := 0
var wood := 0
var action_label_timer := 0.0
var action_label_text := ""

var plots: Array[Dictionary] = []
var trees: Array[Dictionary] = []
var obstacles: Array[Rect2] = []

var resource_label: Label
var tool_label: Label
var objective_label: Label
var log_label: Label


func _ready() -> void:
	_setup_world()
	_setup_ui()
	_log("欢迎来到灯火边境家园原型。WASD 移动，滚轮切换工具，左键或空格使用。")


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
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_select_tool(-1)
			elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_select_tool(1)
			elif mouse_event.button_index == MOUSE_BUTTON_LEFT:
				_use_selected_tool()
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if key_event.keycode == KEY_SPACE:
				_use_selected_tool()
			elif key_event.keycode >= KEY_1 and key_event.keycode <= KEY_7:
				selected_tool_index = key_event.keycode - KEY_1
				_log("切换到 %s。" % _current_tool_name())


func _draw() -> void:
	_draw_world()
	_draw_plots()
	_draw_trees()
	_draw_buildings()
	_draw_player()
	_draw_action_effect()
	_draw_day_overlay()


func _setup_world() -> void:
	plots.clear()
	trees.clear()
	obstacles.clear()

	var plot_start := Vector2(430, 330)
	for row in range(2):
		for col in range(3):
			plots.append({
				"rect": Rect2(plot_start + Vector2(col * 76, row * 58), Vector2(62, 44)),
				"state": CropState.UNTILLED,
				"timer": 0.0,
			})

	trees = [
		{"pos": Vector2(290, 230), "hp": 3},
		{"pos": Vector2(330, 470), "hp": 3},
		{"pos": Vector2(995, 210), "hp": 3},
		{"pos": Vector2(1070, 462), "hp": 3},
	]

	obstacles = [
		Rect2(Vector2(130, 238), Vector2(210, 150)),
		Rect2(Vector2(760, 218), Vector2(210, 154)),
		Rect2(Vector2(98, 96), Vector2(120, 92)),
		Rect2(Vector2(1110, 126), Vector2(95, 336)),
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
	if input_vector.length() > 0.01:
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
	for obstacle in obstacles:
		if body_rect.intersects(obstacle):
			return false
	for tree in trees:
		var tree_pos := tree["pos"] as Vector2
		if tree_pos.distance_to(target_position) < 46.0:
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

	tool_label.text = "当前工具：%s  [%s]\n滚轮或 1-7 切换，左键/空格使用" % [
		_current_tool_name(),
		TOOLS[selected_tool_index]["hint"],
	]

	objective_label.text = "目标：%s" % _get_objective_text()


func _select_tool(direction: int) -> void:
	selected_tool_index = wrapi(selected_tool_index + direction, 0, TOOLS.size())
	_log("切换到 %s。" % _current_tool_name())


func _use_selected_tool() -> void:
	if action_timer > 0.0:
		return

	var tool := int(TOOLS[selected_tool_index]["id"])
	action_tool = tool
	action_facing = player_facing
	action_timer = SKILL_DURATION if tool == Tool.PHYSICAL or tool == Tool.SPELL else ACTION_DURATION

	match tool:
		Tool.HOE:
			_try_till_plot()
		Tool.SEEDS:
			_try_seed_plot()
		Tool.WATER:
			_try_water_plot()
		Tool.AXE:
			_try_chop_tree()
		Tool.SWORD:
			_perform_sword_attack()
		Tool.PHYSICAL:
			_perform_physical_skill()
		Tool.SPELL:
			_perform_spell_skill()


func _try_till_plot() -> void:
	var plot := _nearest_plot()
	if plot.is_empty():
		_show_action_text("离农田太远")
		return
	if _try_harvest_plot(plot):
		return
	if int(plot["state"]) != CropState.UNTILLED:
		_show_action_text("这块地已经处理过了")
		return
	plot["state"] = CropState.TILLED
	_log("开垦了一块农田。")


func _try_seed_plot() -> void:
	var plot := _nearest_plot()
	if plot.is_empty():
		_show_action_text("离农田太远")
		return
	if _try_harvest_plot(plot):
		return
	if int(plot["state"]) != CropState.TILLED:
		_show_action_text("需要先开垦")
		return
	plot["state"] = CropState.SEEDED
	_log("播下药草种子。")


func _try_water_plot() -> void:
	var plot := _nearest_plot()
	if plot.is_empty():
		_show_action_text("离农田太远")
		return
	if _try_harvest_plot(plot):
		return
	if int(plot["state"]) != CropState.SEEDED:
		_show_action_text("这里还不能浇水")
		return
	plot["state"] = CropState.WATERED
	plot["timer"] = CROP_GROW_TIME
	_log("浇水完成，药草开始生长。")


func _try_chop_tree() -> void:
	var tree := _nearest_tree()
	if tree.is_empty():
		_show_action_text("离树太远")
		return
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


func _nearest_plot() -> Dictionary:
	var best_plot: Dictionary = {}
	var best_distance := INF
	for plot in plots:
		var rect := plot["rect"] as Rect2
		var distance := rect.get_center().distance_to(player_position)
		if distance < best_distance:
			best_distance = distance
			best_plot = plot
	if best_distance <= INTERACT_DISTANCE:
		return best_plot
	return {}


func _nearest_tree() -> Dictionary:
	var best_tree: Dictionary = {}
	var best_distance := INF
	for tree in trees:
		var distance := (tree["pos"] as Vector2).distance_to(player_position)
		if distance < best_distance:
			best_distance = distance
			best_tree = tree
	if best_distance <= INTERACT_DISTANCE:
		return best_tree
	return {}


func _current_tool_name() -> String:
	return TOOLS[selected_tool_index]["name"]


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
		return "用锄头开垦一块农田。"
	if _count_plots(CropState.TILLED) > 0:
		return "切到种子，在已开垦农田播种。"
	if _count_plots(CropState.SEEDED) > 0:
		return "切到水壶，给种下的药草浇水。"
	if _count_plots(CropState.WATERED) > 0:
		return "等待药草成熟，同时可以用斧头砍树。"
	if _count_plots(CropState.MATURE) > 0:
		return "靠近成熟药草，按空格收获。"
	return "练习切换武器和技能，熟悉家园范围。"


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
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("#243647"))
	draw_rect(Rect2(Vector2(70, 88), Vector2(1040, 540)), Color("#87b86c"))
	draw_rect(Rect2(Vector2(92, 112), Vector2(996, 494)), Color("#a5c97b"))
	draw_rect(Rect2(Vector2(1090, 86), Vector2(130, 542)), Color("#30405a"))

	for i in range(7):
		var x := 1112.0 + i * 18.0
		draw_line(Vector2(x, 104), Vector2(x + 66, 610), Color("#61705a"), 8.0)

	draw_line(Vector2(235, 470), Vector2(1110, 480), Color("#d0ae72"), 42.0)
	draw_line(Vector2(250, 470), Vector2(1080, 480), Color("#bd955a"), 28.0)
	draw_line(Vector2(552, 352), Vector2(642, 480), Color("#d0ae72"), 34.0)
	draw_line(Vector2(560, 352), Vector2(642, 480), Color("#bd955a"), 22.0)

	draw_rect(Rect2(Vector2(92, 112), Vector2(996, 494)), Color("#f8d77a"), false, 3.0)
	draw_circle(Vector2(1088, 164), 22.0, Color("#ffe28a"))
	draw_circle(Vector2(1088, 164), 44.0, Color(1.0, 0.76, 0.24, 0.14))
	draw_circle(Vector2(1088, 544), 22.0, Color("#ffe28a"))
	draw_circle(Vector2(1088, 544), 44.0, Color(1.0, 0.76, 0.24, 0.14))


func _draw_plots() -> void:
	for plot in plots:
		var rect := plot["rect"] as Rect2
		var state := int(plot["state"])
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


func _draw_trees() -> void:
	for tree in trees:
		var pos := tree["pos"] as Vector2
		draw_rect(Rect2(pos + Vector2(-9, 8), Vector2(18, 38)), Color("#6e4a2d"))
		draw_circle(pos + Vector2(0, -12), 34.0, Color("#385f4a"))
		draw_circle(pos + Vector2(-22, 0), 25.0, Color("#477350"))
		draw_circle(pos + Vector2(22, 2), 25.0, Color("#2f5745"))
		draw_circle(pos + Vector2(16, -23), 8.0, Color("#81d28a"))


func _draw_buildings() -> void:
	_draw_house(Vector2(205, 300), Vector2(210, 150), Color("#8d5b43"), Color("#d99659"))
	_draw_house(Vector2(865, 292), Vector2(210, 154), Color("#70508a"), Color("#bb7ed0"))
	_draw_house(Vector2(158, 142), Vector2(120, 92), Color("#526a74"), Color("#88a6a5"))


func _draw_house(center: Vector2, size: Vector2, wall_color: Color, roof_color: Color) -> void:
	var base := Rect2(center - size * 0.5, size)
	draw_rect(Rect2(base.position + Vector2(0, 28), Vector2(size.x, size.y - 28)), wall_color)
	draw_polygon([
		base.position + Vector2(-16, 36),
		base.position + Vector2(size.x * 0.5, -30),
		base.position + Vector2(size.x + 16, 36),
	], [roof_color])
	draw_rect(Rect2(center + Vector2(-18, 30), Vector2(36, 46)), Color("#463324"))
	draw_rect(base, Color("#3d2c25"), false, 3.0)


func _draw_player() -> void:
	var bob := sin(Time.get_ticks_msec() / 120.0) * 2.0 if action_timer <= 0.0 else 0.0
	var body_pos := player_position + Vector2(0, bob)
	draw_circle(body_pos + Vector2(0, 22), 19.0, Color(0, 0, 0, 0.2))
	draw_rect(Rect2(body_pos + Vector2(-15, -8), Vector2(30, 40)), Color("#4d78c9"))
	draw_circle(body_pos + Vector2(0, -24), 17.0, Color("#f0c79d"))
	draw_rect(Rect2(body_pos + Vector2(-19, -4), Vector2(38, 8)), Color("#2e4d8c"))
	draw_line(body_pos + Vector2(0, -1), body_pos + player_facing.normalized() * 34.0, Color("#ffe7a3"), 4.0)

	if action_label_timer > 0.0:
		draw_string(ThemeDB.fallback_font, body_pos + Vector2(-24, -58), action_label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff1a8"))


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
