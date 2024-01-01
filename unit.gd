extends Area2D

var tile_size = 80
var inputs = {
    "right": Vector2.RIGHT,
    "left": Vector2.LEFT,
    "up": Vector2.UP,
    "down": Vector2.DOWN,
    }
var selected = false
var mouse_is_over_me = false

@export var unit_name = "MyUnit"

func _ready():
    position = position.snapped(Vector2.ONE * tile_size)
    position += Vector2.ONE * tile_size/2

func _unhandled_input(event):
    if not selected: return
    for direction in inputs.keys():
        if event.is_action_pressed(direction):
            move(direction)

func move(direction):
    position += inputs[direction] * tile_size

func _on_mouse_entered():
    mouse_is_over_me = true

func _on_mouse_exited():
    mouse_is_over_me = false

func _input(event):
    if event.is_action_pressed("click"):
        if mouse_is_over_me:
            print("selected " + unit_name)
            selected = true
        else:
            print("deselected " + unit_name)
            selected = false

