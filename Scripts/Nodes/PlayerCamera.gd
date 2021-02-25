extends Camera2D

var screen_width = ProjectSettings.get_setting("display/window/size/width")
var screen_height = ProjectSettings.get_setting("display/window/size/height")
var extra_screen_margin = screen_width * 0.0625

export(Vector2) var tile_size = Vector2(16, 16)
export(NodePath) var camera_path
onready var camera : Camera2D = get_node(camera_path)
export(bool) var draw_grid = true

export(float, 0, 4) var line_thickness = 1
export(Color) var line_color = Color.white

func _draw():
	if not camera or not draw_grid:
		return
	var width = (screen_width + extra_screen_margin) * camera.zoom.x
	var height = (screen_height + extra_screen_margin) * camera.zoom.y
	var global_camera_pos = (camera.global_position - Vector2(width, height)/2).snapped(tile_size) - global_position
	for i in range((width / tile_size.x) + 1):
		var x = tile_size.x * i + global_camera_pos.x
		var from = Vector2(x, global_camera_pos.y - tile_size.y/2)
		var to = Vector2(x, global_camera_pos.y + height + tile_size.y/2)
		draw_line(from, to, line_color, line_thickness, false)
	for j in range((height / tile_size.y) + 1):
		var y = tile_size.y * j + global_camera_pos.y
		var from = Vector2(global_camera_pos.x - tile_size.x/2, y)
		var to = Vector2(global_camera_pos.x + width + tile_size.x/2, y)
		draw_line(from, to, line_color, line_thickness, false)

func _process(_delta):
	update()
