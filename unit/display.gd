extends Node2D

@onready var icon = $icon
@onready var inactive_background = $inactive_background
@onready var symbol_background = $symbol_background

var full_scale:Vector2
var smaller_scale:Vector2


func _ready():
    # when debugging, we are the root scene
    if get_parent() == get_tree().root:
        position = Vector2(80,80)
    full_scale = scale
    smaller_scale = scale * 0.7


func remove_symbol():
    show_symbol('')
    symbol_background.hide()


func set_active():
    inactive_background.hide()


func set_asleep():
    show_symbol('sleep')
    symbol_background.show()


func set_from_city():
    if owner.in_city == null:
        set_full()
        return

    if owner.position != owner.in_city.position:
        push_warning("WARNING: unit is in a city, but city position doesn't match unit position; minifying anyway")

    set_mini()


func set_from_direction():
    # if it's 0, we moved up or down
    # so maintain current facing
    match int(owner.look_direction.x):
        -1:
            icon.flip_h = true
        1:
            icon.flip_h = false


func set_full():
    scale = full_scale
    position = Vector2(0, 0)


func set_hauled():
    show_symbol('haul')
    symbol_background.show()


func set_inactive():
    inactive_background.show()


func set_mini():
    scale = smaller_scale
    position = Vector2(-10, 10)


func show_symbol(symbol_name:String) -> void:
  for label in symbol_background.get_children():
      if label.name == symbol_name:
          label.show()
          continue

      label.hide()
