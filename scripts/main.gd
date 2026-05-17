extends Node2D

enum CropState {
	EMPTY,
	GROWING,
	MATURE,
}

enum AdventurerState {
	WAITING,
	GOING_TO_SHOP,
	GOING_TO_EXIT,
	EXPEDITION,
	RETURNING,
}

const GROW_TIME := 30.0
const HERBS_PER_HARVEST := 2
const HERBS_PER_POTION := 2
const POTION_PRICE := 3
const EXPEDITION_TIME := 20.0
const ADVENTURER_SPEED := 180.0
const SHOP_UPGRADE_MATERIAL_COST := 5
const SHOP_UPGRADE_GOLD_COST := 10

const EXPEDITION_BAR_SIZE := Vector2(180, 14)
const FARM_PLOT_SIZE := Vector2(86, 86)
const WAIT_POS := Vector2(930, 520)
const SHOP_POS := Vector2(245, 515)
const EXIT_POS := Vector2(1180, 520)

var plots: Array[Dictionary] = []
var herbs := 0
var potion_stock := 0
var monster_materials := 0
var gold := 0
var shop_level := 1
var shop_capacity := 5

var adventurer_state := AdventurerState.WAITING
var adventurer_position := WAIT_POS
var expedition_timer := 0.0
var random := RandomNumberGenerator.new()

var resource_label: Label
var shop_label: Label
var adventurer_label: Label
var objective_label: Label
var hint_label: Label
var log_label: Label
var craft_button: Button
var upgrade_button: Button

func _ready() -> void:
	random.randomize()
	_setup_plots()
	_setup_ui()
	_log("欢迎来到第一版村庄原型。点击农田播种药草。")


func _process(delta: float) -> void:
	_update_crops(delta)
	_update_adventurer(delta)
	_update_ui()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_handle_world_click(get_global_mouse_position())


func _draw() -> void:
	_draw_world()
	_draw_farm()
	_draw_shop()
	_draw_adventurer()


func _setup_plots() -> void:
	var start := Vector2(100, 140)
	var gap := Vector2(102, 102)
	for row in range(2):
		for col in range(2):
			plots.append({
				"rect": Rect2(start + Vector2(col * gap.x, row * gap.y), FARM_PLOT_SIZE),
				"state": CropState.EMPTY,
				"timer": 0.0,
			})


func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.position = Vector2(20, 20)
	panel.custom_minimum_size = Vector2(390, 0)
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
	title.text = "冒险者村庄 v0.1"
	title.add_theme_font_size_override("font_size", 22)
	box.add_child(title)

	resource_label = Label.new()
	box.add_child(resource_label)

	shop_label = Label.new()
	box.add_child(shop_label)

	adventurer_label = Label.new()
	box.add_child(adventurer_label)

	objective_label = Label.new()
	objective_label.add_theme_font_size_override("font_size", 16)
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(objective_label)

	craft_button = Button.new()
	craft_button.text = "制作小药水：2 药草 → 1 小药水"
	craft_button.pressed.connect(_on_craft_pressed)
	box.add_child(craft_button)

	upgrade_button = Button.new()
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	box.add_child(upgrade_button)

	hint_label = Label.new()
	hint_label.text = "操作：点击棕色农田播种；发亮代表成熟；绿色进度条代表成长中。"
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint_label)

	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(log_label)


func _handle_world_click(mouse_position: Vector2) -> void:
	for index in range(plots.size()):
		var plot := plots[index]
		var rect := plot["rect"] as Rect2
		if rect.has_point(mouse_position):
			_handle_plot_click(index)
			return


func _handle_plot_click(index: int) -> void:
	var state := int(plots[index]["state"])
	if state == CropState.EMPTY:
		plots[index]["state"] = CropState.GROWING
		plots[index]["timer"] = GROW_TIME
		_log("种下药草。等待 %d 秒成熟。" % int(GROW_TIME))
	elif state == CropState.MATURE:
		plots[index]["state"] = CropState.EMPTY
		plots[index]["timer"] = 0.0
		herbs += HERBS_PER_HARVEST
		_log("收获药草 +%d。" % HERBS_PER_HARVEST)
	else:
		var remaining := int(ceil(float(plots[index]["timer"])))
		_log("药草还在成长，剩余约 %d 秒。" % remaining)


func _update_crops(delta: float) -> void:
	for index in range(plots.size()):
		if plots[index]["state"] == CropState.GROWING:
			plots[index]["timer"] = maxf(0.0, float(plots[index]["timer"]) - delta)
			if float(plots[index]["timer"]) <= 0.0:
				plots[index]["state"] = CropState.MATURE
				_log("有一块药草成熟了。")


func _update_adventurer(delta: float) -> void:
	match adventurer_state:
		AdventurerState.WAITING:
			if potion_stock > 0:
				adventurer_state = AdventurerState.GOING_TO_SHOP
				_log("冒险者发现药剂店有药水，正在前往购买。")
		AdventurerState.GOING_TO_SHOP:
			_move_adventurer_towards(SHOP_POS, delta)
			if adventurer_position.distance_to(SHOP_POS) < 4.0:
				potion_stock -= 1
				gold += POTION_PRICE
				adventurer_state = AdventurerState.GOING_TO_EXIT
				_log("冒险者购买了 1 个小药水。金币 +%d。" % POTION_PRICE)
		AdventurerState.GOING_TO_EXIT:
			_move_adventurer_towards(EXIT_POS, delta)
			if adventurer_position.distance_to(EXIT_POS) < 4.0:
				adventurer_state = AdventurerState.EXPEDITION
				expedition_timer = EXPEDITION_TIME
				_log("冒险者出村讨伐怪物。")
		AdventurerState.EXPEDITION:
			expedition_timer = maxf(0.0, expedition_timer - delta)
			if expedition_timer <= 0.0:
				var gained_materials := random.randi_range(1, 3)
				monster_materials += gained_materials
				adventurer_position = EXIT_POS
				adventurer_state = AdventurerState.RETURNING
				_log("冒险者返回，带回怪物材料 +%d。" % gained_materials)
		AdventurerState.RETURNING:
			_move_adventurer_towards(WAIT_POS, delta)
			if adventurer_position.distance_to(WAIT_POS) < 4.0:
				adventurer_state = AdventurerState.WAITING
				_log("冒险者回到村庄，等待下一次补给。")


func _move_adventurer_towards(target: Vector2, delta: float) -> void:
	adventurer_position = adventurer_position.move_toward(target, ADVENTURER_SPEED * delta)


func _on_craft_pressed() -> void:
	if herbs < HERBS_PER_POTION:
		_log("药草不足，至少需要 %d 个药草。" % HERBS_PER_POTION)
		return
	if potion_stock >= shop_capacity:
		_log("药剂店库存已满，先等冒险者购买。")
		return

	herbs -= HERBS_PER_POTION
	potion_stock += 1
	_log("制作小药水 +1，已放入药剂店库存。")


func _on_upgrade_pressed() -> void:
	if monster_materials < SHOP_UPGRADE_MATERIAL_COST or gold < SHOP_UPGRADE_GOLD_COST:
		_log("升级材料不足，需要 %d 怪物材料和 %d 金币。" % [SHOP_UPGRADE_MATERIAL_COST, SHOP_UPGRADE_GOLD_COST])
		return

	monster_materials -= SHOP_UPGRADE_MATERIAL_COST
	gold -= SHOP_UPGRADE_GOLD_COST
	shop_level += 1
	shop_capacity += 5
	_log("药剂店升级到 Lv%d，库存上限提高到 %d。" % [shop_level, shop_capacity])


func _update_ui() -> void:
	resource_label.text = "资源：药草 %d | 小药水库存 %d | 怪物材料 %d | 金币 %d\n农田：%s" % [
		herbs,
		potion_stock,
		monster_materials,
		gold,
		_get_plot_summary_text(),
	]

	shop_label.text = "药剂店：Lv%d | 库存 %d/%d | 药水售价 %d 金币" % [
		shop_level,
		potion_stock,
		shop_capacity,
		POTION_PRICE,
	]

	adventurer_label.text = "冒险者：%s" % _get_adventurer_state_text()
	objective_label.text = "下一步：%s" % _get_objective_text()

	craft_button.disabled = herbs < HERBS_PER_POTION or potion_stock >= shop_capacity
	upgrade_button.text = "升级药剂店：%d 怪物材料 + %d 金币" % [
		SHOP_UPGRADE_MATERIAL_COST,
		SHOP_UPGRADE_GOLD_COST,
	]
	upgrade_button.disabled = monster_materials < SHOP_UPGRADE_MATERIAL_COST or gold < SHOP_UPGRADE_GOLD_COST


func _get_adventurer_state_text() -> String:
	match adventurer_state:
		AdventurerState.WAITING:
			return "等待药水"
		AdventurerState.GOING_TO_SHOP:
			return "前往药剂店"
		AdventurerState.GOING_TO_EXIT:
			return "前往村庄出口"
		AdventurerState.EXPEDITION:
			return "出征中，剩余 %d 秒" % int(ceil(expedition_timer))
		AdventurerState.RETURNING:
			return "返回村庄"
	return "未知"


func _get_plot_summary_text() -> String:
	return "空地 %d | 成长中 %d | 可收获 %d" % [
		_count_plots(CropState.EMPTY),
		_count_plots(CropState.GROWING),
		_count_plots(CropState.MATURE),
	]


func _get_objective_text() -> String:
	if monster_materials >= SHOP_UPGRADE_MATERIAL_COST and gold >= SHOP_UPGRADE_GOLD_COST:
		return "升级药剂店，扩大药水库存上限。"
	if _count_plots(CropState.MATURE) > 0:
		return "点击发亮的农田，收获药草。"
	if herbs >= HERBS_PER_POTION and potion_stock < shop_capacity:
		return "制作小药水，补给下一次出征。"
	if adventurer_state == AdventurerState.EXPEDITION:
		return "等待冒险者回村，带回怪物材料。"
	if adventurer_state == AdventurerState.GOING_TO_SHOP:
		return "冒险者正在买药水，准备出村。"
	if adventurer_state == AdventurerState.GOING_TO_EXIT:
		return "冒险者正前往出口，马上开始出征。"
	if adventurer_state == AdventurerState.RETURNING:
		return "冒险者正在回村，准备结算下一轮。"
	if potion_stock > 0:
		return "药剂店已有库存，冒险者会自动购买。"
	if _count_plots(CropState.GROWING) > 0:
		return "等待药草成熟，绿色条越满越接近收获。"
	if _count_plots(CropState.EMPTY) > 0:
		return "点击空农田播种药草。"
	return "继续种药草、制药水、供给冒险者。"


func _count_plots(state_value: int) -> int:
	var count := 0
	for plot in plots:
		if int(plot["state"]) == state_value:
			count += 1
	return count


func _draw_expedition_progress() -> void:
	if adventurer_state != AdventurerState.EXPEDITION:
		return

	var progress := 1.0 - expedition_timer / EXPEDITION_TIME
	var bar_position := Vector2(800, 72)
	var bar_rect := Rect2(bar_position, EXPEDITION_BAR_SIZE)
	draw_rect(bar_rect.grow(4), Color("#4e3d2c"))
	draw_rect(bar_rect, Color("#2e261d"))
	draw_rect(Rect2(bar_position, Vector2(EXPEDITION_BAR_SIZE.x * clampf(progress, 0.0, 1.0), EXPEDITION_BAR_SIZE.y)), Color("#f0c15a"))


func _draw_world() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#8fcf7a"))
	draw_rect(Rect2(Vector2(0, 575), Vector2(1280, 145)), Color("#6fbf68"))
	draw_line(SHOP_POS, EXIT_POS, Color("#d3b071"), 34.0)
	draw_line(SHOP_POS, EXIT_POS, Color("#c89f5b"), 26.0)
	draw_rect(Rect2(EXIT_POS + Vector2(-30, -60), Vector2(80, 120)), Color("#b18a55"))
	_draw_expedition_progress()


func _draw_farm() -> void:
	for plot in plots:
		var rect := plot["rect"] as Rect2
		var state := int(plot["state"])
		draw_rect(rect, Color("#7b4a25"))
		draw_rect(rect.grow(-5), Color("#9a6030"))
		match state:
			CropState.EMPTY:
				draw_rect(rect.grow(-18), Color("#8b552c"))
			CropState.GROWING:
				var progress := 1.0 - float(plot["timer"]) / GROW_TIME
				var crop_rect := rect.grow(-22)
				var progress_bar := Rect2(rect.position + Vector2(10, rect.size.y - 13), Vector2((rect.size.x - 20) * clampf(progress, 0.0, 1.0), 6))
				crop_rect.size.y *= clampf(progress, 0.15, 1.0)
				crop_rect.position.y = rect.position.y + rect.size.y - 22 - crop_rect.size.y
				draw_rect(crop_rect, Color("#51a64b"))
				draw_rect(Rect2(rect.position + Vector2(10, rect.size.y - 13), Vector2(rect.size.x - 20, 6)), Color("#5e3c24"))
				draw_rect(progress_bar, Color("#b9e56d"))
			CropState.MATURE:
				draw_rect(rect.grow(4), Color("#fff2a6"), false, 4.0)
				draw_rect(rect.grow(-18), Color("#4ebd4a"))
				draw_circle(rect.get_center(), 18.0, Color("#94e06f"))
				draw_circle(rect.get_center() + Vector2(22, -22), 7.0, Color("#fff8b8"))


func _draw_shop() -> void:
	var shop_rect := Rect2(SHOP_POS + Vector2(-90, -80), Vector2(180, 130))
	draw_rect(shop_rect, Color("#7e4d8f"))
	draw_rect(Rect2(shop_rect.position + Vector2(20, 35), Vector2(140, 75)), Color("#b471c7"))
	draw_rect(Rect2(shop_rect.position + Vector2(65, 75), Vector2(50, 35)), Color("#4d2e59"))
	draw_polygon([
		shop_rect.position + Vector2(-12, 35),
		shop_rect.position + Vector2(90, -28),
		shop_rect.position + Vector2(192, 35),
	], [Color("#5c336d")])


func _draw_adventurer() -> void:
	if adventurer_state == AdventurerState.EXPEDITION:
		return

	draw_circle(adventurer_position + Vector2(0, -24), 16.0, Color("#f1d0a8"))
	draw_rect(Rect2(adventurer_position + Vector2(-16, -10), Vector2(32, 42)), Color("#3b78cf"))
	draw_rect(Rect2(adventurer_position + Vector2(-22, 2), Vector2(44, 8)), Color("#27528d"))


func _log(message: String) -> void:
	if log_label != null:
		log_label.text = "日志：" + message
