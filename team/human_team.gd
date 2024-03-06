extends 'team.gd'

class_name HumanTeam

@onready var cursor:Sprite2D = $cursor

func _ready():
    super._ready()
    cursor.controller_team = name

func _on_cursor_want_next_unit(coordinates):
    var next = units.get_cardinal_closest_active(coordinates)
    if next != null:
        next.select_me()
        cursor.mark_unit(next)

func move():
    var next = units.get_cardinal_closest_active(cursor.position)
    if next != null:
        next.select_me()
        cursor.mark_unit(next)
