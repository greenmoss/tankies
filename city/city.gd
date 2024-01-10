extends Area2D

var selected = false
var mouse_is_over_me = false

@export var city_name = "City"

func _ready():
    position = position.snapped(Vector2.ONE * Global.tile_size/2)

