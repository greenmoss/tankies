extends "res://common/state.gd"

var movement_tween: Tween
var move_animation_speed = 7.5


func animate():
    owner.sounds.play_move()

    movement_tween = create_tween()
    movement_tween.tween_property(owner, "position",
        owner.position +
        owner.look_direction * Global.tile_size,
        1.0/move_animation_speed
        ).set_trans(Tween.TRANS_SINE)
    await movement_tween.finished

    if(owner.in_city != null):
        # moved out of city
        if(owner.position != owner.in_city.position):
            owner.in_city = null

        owner.icon.set_from_city()
