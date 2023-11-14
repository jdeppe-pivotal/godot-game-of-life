extends Node2D

@export var scaling : float = 1.0
@export var speed : float = 1.0

var cell = preload("res://cell.tscn")
var screen_size : Vector2
var sprite_size : Vector2
var cells = []
var t_cells = []
var rows
var columns
var generate = false
var iteration = 0


func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

	var t_cell = cell.instantiate()
	var t_sprite : Sprite2D = t_cell.get_child(0)
	sprite_size = t_sprite.texture.get_size()
	screen_size = get_tree().get_root().size	
	rows = screen_size.y / (sprite_size.y * scaling)
	columns = screen_size.x / (sprite_size.x * scaling)
	
	for y in range(rows):
		cells.append([])
		cells[y].resize(columns)
		t_cells.append([])
		t_cells[y].resize(columns)
		for x in range(columns):
			cells[y][x] = randi_range(0, 1)
			t_cells[y][x] = 0

	add_child(draw_life(cells))
	
	var timer := Timer.new()
	timer.wait_time = 1.0 / speed
	timer.connect("timeout", do_next_generation)
	add_child(timer)
	timer.start()


func draw_life(c : Array) -> Node2D:
	var node = Node2D.new()
	node.scale = Vector2(scaling, scaling)
	node.set_name("Generation_" + str(iteration))
	iteration += 1
	
	for y in range(c.size()):
		for x in range(c[y].size()):
			if c[y][x] == 1:
				var t_cell = cell.instantiate()
				t_cell.position = Vector2(x * sprite_size.x, y * sprite_size.y)
				node.add_child(t_cell)
	
	return node


func print_cells(c1 : Array, c2 : Array):
	for i in range(c1.size()):
		print(c1[i],  "  ", c2[i])


#func _process(delta):
#	if iteration > 0:
#		do_next_generation()


func do_next_generation():
	var next_gen = next_generation(cells)

	var gen = get_node("Generation_" + str(iteration - 1))
	gen.queue_free()

	add_child(draw_life(next_gen))

	var swap = cells
	cells = next_gen
	t_cells = swap
	
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		generate = true


func next_generation(c : Array) -> Array:
#	var t_cells = []
#	for y in range(c.size()):
#		t_cells.append([])
#		t_cells[y].resize(c[y].size())
#		for x in range(c[y].size()):
#			t_cells[y][x] = 0
	
	for y in range(c.size()):
		for x in range(c[y].size()):
			var n = neighbors(c, y, x)
			if cells[y][x] == 1 && (n == 2 || n == 3):
				t_cells[y][x] = 1
			elif cells[y][x] == 0 && n == 3:
				t_cells[y][x] = 1
			else:
				t_cells[y][x] = 0
	
	return t_cells


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
