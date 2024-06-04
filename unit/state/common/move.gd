extends "res://common/state.gd"

var movement_tween: Tween
var move_animation_speed = 7.5


func exit():
    owner.unit.vision.update()


func animate():
    owner.unit.sounds.play_move()

    movement_tween = create_tween()
    movement_tween.tween_property(owner.unit, "position",
        owner.unit.position +
        owner.unit.look_direction * Global.tile_size,
        1.0/move_animation_speed
        ).set_trans(Tween.TRANS_SINE)
    await movement_tween.finished

    if(owner.unit.in_city != null):
        # moved out of city
        if(owner.unit.position != owner.unit.in_city.position):
            owner.unit.in_city = null

        owner.unit.icon.set_from_city()


func reduce_moves():
    owner.unit.moves_remaining -= 1
    if owner.unit.moves_remaining <= 0:
        emit_signal("next_state", "end")
        return

    emit_signal("next_state", "idle")
