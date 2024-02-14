extends Area2D

class_name Unit

var inputs = {
    "right": Vector2.RIGHT,
    "left": Vector2.LEFT,
    "up": Vector2.UP,
    "down": Vector2.DOWN,
    }
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

func _on_mouse_entered():
    SignalBus.mouse_entered_unit.emit(self)

func _on_mouse_exited():
    SignalBus.mouse_exited_unit.emit(self)

func handle_cursor_input_event(event):
    if moving: return

    if event.is_action_pressed("click"):
        if on_my_team():
            select_me()
            if is_sleeping():
                awaken()

            return

        $Sounds.play_denied()
        return

    for direction in inputs.keys():
        if event.is_action_pressed(direction):
            request_move(direction)
            return

    if event.is_action_pressed('sleep'):
        toggle_sleep()
        return

    if event.is_action_pressed('next'):
        SignalBus.want_next_unit.emit(self.my_team)
        return

func _ready():
    moves_per_turn = 2
    sleep_turns = 0
    position = position.snapped(Vector2.ONE * Global.tile_size / 2)
    refill_moves()
    assign_groups()

func attack(defender):
    if(defender.my_team == my_team):
        print(
            "Warning: refusing to attack unit ",
            defender,
            " already owned by, ",
            my_team)
        return

    # TBD: play battle animation
    # TBD: roll dice
    # TBD: pop up message
    defender.disband()

func awaken():
    sleep_turns = 0
    if has_more_moves():
        $Inactive.awaken()
    else:
        $Inactive.done_moving()

func go_to_sleep():
    deselect_me()
    sleep_turns = -1
    $Inactive.sleep_infinity()
    SignalBus.unit_completed_moves.emit(my_team)

func toggle_sleep():
    if is_sleeping():
        awaken()
    else:
        go_to_sleep()

func is_awake() -> bool:
    return (sleep_turns == 0)

func is_moving() -> bool:
    return moving

func is_sleeping() -> bool:
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

    if target.is_in_group("Cities"):
        request_move_city(target)
        return

    # fallback case
    deny_move()

func request_move_city(city):
    if city.is_open_to_team(my_team):
        move_to_requested()
        enter_city(city)
        return

    city.attack_with(self)

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
    await tween.finished
    moving = false

    if(in_city != null):
        if(position != in_city.position):
            leave_city(in_city)

    moves_remaining -= 1
    if not has_more_moves():
        SignalBus.unit_completed_moves.emit(my_team)
        deselect_me()
        $Inactive.done_moving()

func assign_groups():
    modulate = Global.team_colors[my_team]
    add_to_group(my_team)
    add_to_group("Units")

func on_my_team() -> bool:
    # TODO: look for a better way to implement debugging overrides
    if Global.debug_select_any or my_team == Global.human_team:
        return true
    return false

func deny_move():
    $Sounds.play_denied()

func select_me():
    $Sounds.play_ready()

func deselect_me():
    $Sounds.stop_all()

func has_more_moves():
    if is_sleeping(): return false
    return moves_remaining > 0

func refill_moves():
    moves_remaining = moves_per_turn
    if is_awake():
        $Inactive.awaken()

func disband():
    queue_free()
