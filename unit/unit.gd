extends Area2D

class_name Unit

var inputs = {
    "right": Vector2.RIGHT,
    "left": Vector2.LEFT,
    "up": Vector2.UP,
    "down": Vector2.DOWN,
    }
var selected = false
var mouse_is_over_me = false
var move_animation_speed = 10
var moving = false
var facing = 0 # default/right
var requested_direction = null
var in_city = null
var sleep_turns = 0

@export var moves_per_turn = 2
var moves_remaining

@export var my_team = "NoTeam"

@onready var ray = $RayCast2D

func _ready():
    moves_per_turn = 2
    sleep_turns = 0
    position = position.snapped(Vector2.ONE * Global.tile_size / 2)
    reset_moves()
    assign_groups()

func _input(event):
    if event.is_action_pressed("click"):

        if mouse_is_over_me:
            if on_my_team():
                select_me()
                return

            $Sounds.play_denied()
            return

        deselect_me()
        return

func _unhandled_input(event):
    if not selected: return
    if moving: return
    for direction in inputs.keys():
        if event.is_action_pressed(direction):
            request_move(direction)
            return
    if event.is_action_pressed('sleep'):
        toggle_sleep()

func toggle_sleep():
    # if sleeping, wake up
    if sleep_turns != 0:
        sleep_turns = 0
        return

    # otherwise, go to sleep until awoken
    deselect_me()
    sleep_turns = -1

func is_awake():
    return (sleep_turns == 0)

func is_sleeping():
    return (sleep_turns != 0)

func request_move(direction):
    if not has_more_moves():
        deny_move()
        return

    requested_direction = direction
    ray.target_position = inputs[direction] * Global.tile_size
    ray.force_raycast_update()

    # nothing's there, free to move
    if not(ray.is_colliding()):
        move_to_requested()
        return

    # TODO: get all ray collision targets
    # units can be inside other units or in cities, so ray can collide with multiple
    # technique from https://forum.godotengine.org/t/27326
    # bug though: Godot dies on collision with terrain blocker, so currently I can not do this:
    #var targets = []
    #while ray.is_colliding():
        #var target = ray.get_collider()
        #targets.append(target)
        #print("target is ", target)
        #ray.add_exception(target)
        #ray.force_raycast_update()
    #for target in targets:
        #ray.remove_exception(target)

    # something's there, find out what it is
    # signal that we collided with it
    var target = ray.get_collider()
    SignalBus.unit_collided.emit(self, target)

    # we might be able to move
    # but that's up to the world logic now
    # so we are done here

func enter_city(city):
    city.occupy_with(self)
    in_city = city
    $Sprite2D.scale = Vector2(0.05, 0.05)
    # TODO: derive these from sprite/size properties instead of hard coding -10, etc
    $Sprite2D.position = Vector2(-10, 10)
    #$Sprite2D.centered = false

func leave_city(city):
    city.vacated_by(self)
    in_city = null
    # TODO: read this from resource, instead of hard coding here
    $Sprite2D.scale = Vector2(0.07, 0.07)
    $Sprite2D.position = Vector2(0, 0)
    #$Sprite2D.centered = true

func face_toward(direction):
    if(direction == "right"):
        $Sprite2D.flip_h = false
        return
    if(direction == "left"):
        $Sprite2D.flip_h = true
        return

func move_to_requested():
    if(requested_direction == null):
        print("Error! Avoiding move towards undefined direction")
        return
    move(requested_direction)

func move(direction):
    $Sounds.play_move()
    face_toward(direction)

    var tween = create_tween()
    tween.tween_property(self, "position",
        position +
        inputs[direction] *
        Global.tile_size,
        1.0/move_animation_speed
        ).set_trans(Tween.TRANS_SINE)
    moving = true
    $Cursor.deactivate()
    await tween.finished
    $Cursor/CooldownTimer.start()
    moving = false

    if(in_city != null):
        if(position != in_city.position):
            leave_city(in_city)

    moves_remaining -= 1

func _on_mouse_entered():
    mouse_is_over_me = true

func _on_mouse_exited():
    mouse_is_over_me = false

func assign_groups():
    modulate = Global.team_colors[my_team]
    add_to_group(my_team)
    add_to_group("Units")

func on_my_team():
    # TODO: look for a better way to implement debugging overrides
    if Global.debug_select_any or my_team == Global.human_team:
        return true
    return false

func deny_move():
    $Sounds.play_denied()

func select_me():
    $Sounds.play_ready()
    selected = true
    $Cursor.activate()

func deselect_me():
    $Sounds.stop_all()
    selected = false
    $Cursor.deactivate()

func has_more_moves():
    if is_sleeping(): return false
    return moves_remaining > 0

func reset_moves():
    moves_remaining = moves_per_turn


func _on_cooldown_timer_timeout():
    if selected:
        $Cursor.activate()

func disband():
    queue_free()
