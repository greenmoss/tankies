extends "res://common/state.gd"

var blocked_looks:Array[Vector2]


func _ready():
    clear()


func clear():
    blocked_looks = []


func enter():
    owner.unit.sounds.play_denied()

    if owner.unit.look_direction not in blocked_looks:
        #print("blocking look at position ",owner.unit.position,", looking at ",owner.unit.look_direction)
        blocked_looks.append(owner.unit.look_direction)
    #print("blocked looks: ",blocked_looks)

    emit_signal("next_state", "idle")


func get_positions() -> Array[Vector2]:
    var positions:Array[Vector2] = []
    for look in blocked_looks:
        positions.append(owner.unit.position + (look * Global.tile_size))
    return positions
