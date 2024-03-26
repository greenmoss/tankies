extends "res://common/state.gd"

#@export var max_walk_speed: float = 450
#@export var max_run_speed: float = 700

#REF
#var inputs = {
#    "right": Vector2.RIGHT,
#    "left": Vector2.LEFT,
#    "up": Vector2.UP,
#    "down": Vector2.DOWN,
#    }

var movement_tween: Tween
var move_animation_speed = 7.5

func enter():
    print("in state:move enter, moving toward ", owner.look_direction)

    owner.ray.target_position = owner.look_direction * Global.tile_size
    owner.ray.force_raycast_update()

    if owner.ray.is_colliding():
        emit_signal("next_state", "collide")
        return

    print("in state:move, no ray collision")

    face_toward(owner.look_direction)
    owner.sounds.play_move()

    movement_tween = create_tween()
    movement_tween.tween_property(owner, "position",
        owner.position +
        owner.look_direction * Global.tile_size,
        1.0/move_animation_speed
        ).set_trans(Tween.TRANS_SINE)
    #moving = true
    await movement_tween.finished
    #finished_movement.emit()
    #moving = false

    if(owner.in_city != null):
        if(owner.position != owner.in_city.position):
            await leave_city()

    reduce_moves()


func face_toward(direction):
    # if it's 0, maintain current facing
    match int(direction.x):
        -1:
            owner.sprite.flip_h = true
        1:
            owner.sprite.flip_h = false


func handle_input(event):
    return super.handle_input(event)


func leave_city():
    owner.in_city = null
    # TODO: read this from resource, instead of hard coding here
    owner.sprite.scale = Vector2(0.07, 0.07)
    owner.sprite.position = Vector2(0, 0)
    #$Sprite2D.centered = true


func reduce_moves():
    owner.moves_remaining -= 1
    if owner.moves_remaining <= 0:
        emit_signal("next_state", "end")
        return

    emit_signal("next_state", "idle")


func update(_delta):
    pass
    #print("in state:move update")
    #var input_direction = get_input_direction()
    #if input_direction.is_zero_approx():
    #    emit_signal("next_state", "idle")
    #update_look_direction(input_direction)

    #REF
    #for direction in inputs.keys():
    #    if Input.is_action_pressed(direction):
    #        print("requested direction ",direction)

    #if Input.is_action_pressed("run"):
    #    speed = max_run_speed
    #else:
    #    speed = max_walk_speed

    #var collision_info = move(speed, input_direction)
    #if not collision_info:
    #    return
    #if speed == max_run_speed and collision_info.collider.is_in_group("environment"):
    #    return null


#func move(speed, direction):
func move():
    print("in state:move move")
    #owner.velocity = direction.normalized() * speed
    #owner.move_and_slide()
    #if owner.get_slide_collision_count() == 0:
    #    return
    #return owner.get_slide_collision(0)
