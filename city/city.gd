extends Area2D

var tile_size = 80
var selected = false
var mouse_is_over_me = false

@export var city_name = "City"

func _ready():
    position = position.snapped(Vector2.ONE * tile_size/2)

