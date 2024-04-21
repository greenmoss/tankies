extends Area2D

class_name Unit

#REF
#var inputs = {
#    "right": Vector2.RIGHT,
#    "left": Vector2.LEFT,
#    "up": Vector2.UP,
#    "down": Vector2.DOWN,
#    }
#var move_animation_speed = 10
#var fighting = false
#var moving = false
#var requested_direction = null
var facing = 0 # default/right
var in_city = null
var sleep_turns = 0
#REF
#var movement_tween: Tween

# if we are running this scene as an instantiated child, this is false
# set to true for debugging, e.g. to test cursor input
var standalone: bool

# path-finding
var _path = PackedVector2Array()

#REF
#signal finished_fighting
#signal finished_movement

var moves_remaining: int
var attack_strength = 4
var defense_strength = 2
var look_direction = Vector2.RIGHT

@export var moves_per_turn = 2
@export var my_team = "NoTeam"

@onready var inactive = $Inactive
@onready var ray = $RayCast2D
@onready var sounds = $Sounds
@onready var sprite = $Sprite2D
@onready var state = $state

func _on_mouse_entered():
    SignalBus.mouse_entered_unit.emit(self)

func _on_mouse_exited():
    SignalBus.mouse_exited_unit.emit(self)

# when we are debugging, e.g. in a standalone scene
# assume all input is for us, since there's no cursor
func _unhandled_input(event):
    if not standalone: return
    handle_cursor_input_event(event)

# the cursor chooses who gets the events
# thus, we do not use _unhandled_input() here
func handle_cursor_input_event(event):
    state.handle_cursor_input(event)

    #REF
    #if moving or fighting: return

    #for direction in inputs.keys():
    #    if event.is_action_pressed(direction):
    #        await request_move(direction)
    #        return

    #if event.is_action_pressed('sleep'):
    #    await toggle_sleep()
    #    return


func _ready():
    # when debugging, we are the root scene
    if get_parent() == get_tree().root:
        standalone = true
        position = Vector2(80,80)

    moves_per_turn = 2
    sleep_turns = 0
    position = position.snapped(Vector2.ONE * Global.tile_size / 2)
    await refill_moves()
    await assign_groups()
    _path.clear()


#REF
#func attack(defender):
#    if(defender.my_team == my_team):
#        print(
#            "Warning: refusing to attack unit ",
#            defender,
#            " already owned by, ",
#            my_team)
#        return
#    SignalBus.unit_attacked_unit.emit(self, defender)
#    await SignalBus.battle_finished
#
#func start_fighting():
#    fighting = true
#
#func stop_fighting():
#    fighting = false
#    finished_fighting.emit()
#
#func awaken():
#    sleep_turns = 0
#    if has_more_moves():
#        $Inactive.awaken()
#    else:
#        $Inactive.done_moving()
#
#func go_to_sleep():
#    deselect_me()
#    sleep_turns = -1
#    $Inactive.sleep_infinity()
#    SignalBus.unit_completed_moves.emit(my_team)
#
#func toggle_sleep():
#    if is_sleeping():
#        await awaken()
#    else:
#        await go_to_sleep()
#
#func is_awake() -> bool:
#    return (sleep_turns == 0)
#
#func is_done() -> bool:
#    if has_more_moves(): return false
#    if is_active(): return false
#    return true
#
#func is_active() -> bool:
#    return is_fighting() or is_moving()
#
#func is_fighting() -> bool:
#    return fighting
#
#func is_moving() -> bool:
#    return moving
#
#func is_sleeping() -> bool:
#    return (sleep_turns != 0)
#
#func request_move(direction):
#    if is_active():
#        return
#
#    if not has_more_moves():
#        await deny_move()
#        return
#
#    requested_direction = direction
#    ray.target_position = inputs[direction] * Global.tile_size
#    ray.force_raycast_update()
#
#    # nothing's there, free to move
#    if not(ray.is_colliding()):
#        await move_to_requested()
#        return
#
#    # get all ray collision targets
#    # units can be inside other units or in cities, so ray can collide with multiple
#    # technique from https://forum.godotengine.org/t/27326
#    var targets = []
#    while ray.is_colliding():
#        var target = ray.get_collider()
#        targets.append(target)
#
#        if target is TileMap:
#            await deny_move()
#            return
#
#        ray.add_exception(target)
#        ray.force_raycast_update()
#
#    var target_city : Area2D = null
#    var target_unit : Area2D = null
#    for target in targets:
#        ray.remove_exception(target)
#        if target.is_in_group("Cities"): target_city = target
#        if target.is_in_group("Units"): target_unit = target
#
#    if target_unit != null:
#        await request_move_into_unit(target_unit)
#        return
#
#    if target_city != null:
#        await request_move_into_city(target_city)
#        return
#
#    # fallback case
#    await deny_move()
#
#func request_move_into_city(city):
#    if city.is_open_to_team(my_team):
#        await move_to_requested()
#        await enter_city(city)
#        return
#
#    await city.attacked_by(self)
#
#func request_move_into_unit(unit):
#    if unit.my_team == my_team:
#        await move_to_requested()
#        return
#
#    await attack(unit)
#    await reduce_moves()
#
#func enter_city(city):
#    await city.occupy_by(self)
#    in_city = city
#    $Sprite2D.scale = Vector2(0.05, 0.05)
#    # TODO: derive these from sprite/size properties instead of hard coding -10, etc
#    $Sprite2D.position = Vector2(-10, 10)
#    #$Sprite2D.centered = false
#
#func leave_city():
#    in_city = null
#    # TODO: read this from resource, instead of hard coding here
#    $Sprite2D.scale = Vector2(0.07, 0.07)
#    $Sprite2D.position = Vector2(0, 0)
#    #$Sprite2D.centered = true
#
#func face_toward(direction):
#    if(direction == "right"):
#        $Sprite2D.flip_h = false
#        return
#    if(direction == "left"):
#        $Sprite2D.flip_h = true
#        return
#
#func move_to_requested():
#    if(requested_direction == null):
#        print("Error! Avoiding move towards undefined direction")
#        return
#    await move(requested_direction)
#
#func move(direction):
#    $Sounds.play_move()
#    face_toward(direction)
#
#    movement_tween = create_tween()
#    movement_tween.tween_property(self, "position",
#        position +
#        inputs[direction] *
#        Global.tile_size,
#        1.0/move_animation_speed
#        ).set_trans(Tween.TRANS_SINE)
#    moving = true
#    await movement_tween.finished
#    finished_movement.emit()
#    moving = false
#
#    if(in_city != null):
#        if(position != in_city.position):
#            await leave_city()
#
#    await reduce_moves()
#
#func reduce_moves():
#    moves_remaining -= 1
#    if not has_more_moves():
#        SignalBus.unit_completed_moves.emit(my_team)
#        await deselect_me()
#        $Inactive.done_moving()
#
#func end_moves():
#    # ignore any remaining moves
#    # humans use "sleep", ai uses this instead
#    #REF
#    #print("in unit, checking state ",state.current_state, "; signal is ",state.current_state.next_state)
#    state.current_state.next_state.emit('end')

func move_toward(new_position):
    # NOTE: this makes no attempt at real path finding
    # consequently, this is best used to move to a neighboring coordinate/position
    var move_direction: Vector2 = (position - new_position).normalized()

    if(move_direction[0] > 0):
        look_direction = Vector2.LEFT
    elif(move_direction[1] > 0):
        look_direction = Vector2.UP
    elif(move_direction[0] < 0):
        look_direction = Vector2.RIGHT
    else:
        look_direction = Vector2.DOWN

    state.current_state.next_state.emit('pre_move')

func assign_groups():
    if my_team != null:
        modulate = Global.team_colors[my_team]
        add_to_group(my_team)
    add_to_group("Units")

func on_my_team() -> bool:
    # TODO: look for a better way to implement debugging overrides
    if Global.debug_select_any or my_team == Global.human_team:
        return true
    return false

func select_me():
    print("handling select")

#REF
#func deny_move():
#    $Sounds.play_denied()
#
#func select_me():
#    if is_sleeping():
#        awaken()
#    if has_more_moves():
#        $Sounds.play_ready()
#    else:
#        deny_move()
#
#func deselect_me():
#    $Sounds.stop_all()
#
#func has_more_moves():
#    if is_sleeping(): return false
#    return moves_remaining > 0

func refill_moves():
    moves_remaining = moves_per_turn
    state.rotate()
#REF
#    if is_awake():
#        $Inactive.awaken()

func disband():
    queue_free()
    # are we an invalid reference?
    # If not, perhaps a listener can benefit from knowing what we were
    SignalBus.unit_disbanded.emit(self)
