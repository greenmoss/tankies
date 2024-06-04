extends Sprite2D

var full_scale:Vector2
var smaller_scale:Vector2


func _ready():
    full_scale = scale
    smaller_scale = scale * 0.7


func set_from_direction():
    # if it's 0, we moved up or down
    # so maintain current facing
    match int(owner.look_direction.x):
        -1:
            flip_h = true
        1:
            flip_h = false


func set_from_city():
    if owner.in_city == null:
        set_full()
        return

    if owner.position != owner.in_city.position:
        push_warning("WARNING: unit is in a city, but city position doesn't match unit position; minifying anyway")

    set_mini()


func set_mini():
    scale = smaller_scale
    position = Vector2(-10, 10)


func set_full():
    scale = full_scale
    position = Vector2(0, 0)
