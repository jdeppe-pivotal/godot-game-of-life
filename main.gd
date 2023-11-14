extends Node2D

@export var scaling : float = 1.0
@export var speed : float = 1.0

var cell = preload("res://cell.tscn")
var screen_size : Vector2
var sprite_size : Vector2
var cells = []
var cell_bitmap_1 = []
var cell_bitmap_2 = []
var rows
var columns


func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

	# Instantiate the cell to get its size and figure out how many fit on the screen
	var t_cell : Sprite2D  = cell.instantiate()
	sprite_size = t_cell.texture.get_size()
	screen_size = get_tree().get_root().size	
	rows = screen_size.y / (sprite_size.y * scaling)
	columns = screen_size.x / (sprite_size.x * scaling)
	t_cell.queue_free()
	
	# Initialize all of the structures
	for y in range(rows):
		cells.append([])
		cells[y].resize(columns)
		cell_bitmap_1.append([])
		cell_bitmap_1[y].resize(columns)
		cell_bitmap_2.append([])
		cell_bitmap_2[y].resize(columns)
		for x in range(columns):
			cell_bitmap_1[y][x] = randi_range(0, 1)
			cell_bitmap_2[y][x] = 0

	add_child(flood_all_cells(cells))
	
	var timer := Timer.new()
	timer.wait_time = 1.0 / speed
	timer.connect("timeout", do_next_generation)
	add_child(timer)
	timer.start()


func flood_all_cells(c : Array) -> Node2D:
	var node = Node2D.new()
	node.scale = Vector2(scaling, scaling)
	node.set_name("Cells")
	
	for y in range(c.size()):
		for x in range(c[y].size()):
			var t_cell = cell.instantiate()
			t_cell.position = Vector2(x * sprite_size.x, y * sprite_size.y)
			node.add_child(t_cell)
			cells[y][x] = t_cell
	
	return node


#func _process(delta):
#	do_next_generation()


func do_next_generation():
	next_generation(cell_bitmap_1, cell_bitmap_2)

	set_cells_from_bitmap(cell_bitmap_1)

	var swap = cell_bitmap_2
	cell_bitmap_2 = cell_bitmap_1
	cell_bitmap_1 = swap


func set_cells_from_bitmap(c : Array):
	for y in range(c.size()):
		for x in range(c[y].size()):
			if c[y][x] == 1:
				cells[y][x].visible = true
			else:
				cells[y][x].visible = false


func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		do_next_generation()


func next_generation(c1 : Array, c2 : Array):
	for y in range(c1.size()):
		for x in range(c1[y].size()):
			var n = neighbors(c1, y, x)
			if c1[y][x] == 1 && (n == 2 || n == 3):
				c2[y][x] = 1
			elif c1[y][x] == 0 && n == 3:
				c2[y][x] = 1
			else:
				c2[y][x] = 0


func neighbors(c : Array, y : int, x : int) -> int:
	var n = 0
	n += wrapped(c, y - 1, x - 1)
	n += wrapped(c, y - 1, x)
	n += wrapped(c, y - 1, x + 1)
	n += wrapped(c, y, x - 1)
	n += wrapped(c, y, x + 1)
	n += wrapped(c, y + 1, x - 1)
	n += wrapped(c, y + 1, x)
	n += wrapped(c, y + 1, x + 1)
	return n


func wrapped(c : Array, y : int, x : int) -> int:
	if y < 0:
		y = c.size() - 1
	if y == c.size():
		y = 0
	if x < 0:
		x = c[0].size() - 1
	if x == c[0].size():
		x = 0
	return c[y][x]
