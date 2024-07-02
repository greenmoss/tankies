extends Area2D
class_name Unit

var in_city:City = null
var sleep_turns = 0

# if we are running this scene as an instantiated child, this is false
# set to true for debugging, e.g. to test cursor input
var standalone:bool

var automation:BTUnitAutomation
var fuel_remaining:int
var moves_remaining:int
var look_direction = Vector2.RIGHT

var attack_strength:int
var build_time:int
var defense_strength:int
var moves_per_turn:int
var vision_distance:int
# to enable fuel/refuel mechanic, set to positive int
var fuel_capacity = 0
# to allow units to capture cities, set to true
var can_capture = false

@export var my_team = "NoTeam"

@onready var blackboard = $Blackboard
@onready var collision = $CollisionShape2D
@onready var display = $display
@onready var plan = $plan
@onready var ray = $RayCast2D
@onready var sounds = $Sounds
@onready var state = $state
@onready var vision = $vision


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


func _ready():
    # when debugging, we are the root scene
    if get_parent() == get_tree().root:
        standalone = true
        position = Vector2(80,80)

    # We assigned a unique BT/automation node name
    # So find it below
    for child in get_children():
        if '_class_name' in child:
            if child._class_name == 'BehaviorTree':
                automation = child
                break

    vision.set_distance(vision_distance)

    sleep_turns = 0
    position = position.snapped(Vector2.ONE * Global.tile_size / 2)
    await refill_moves()
    await assign_groups()


func get_colliders() -> int:
    return ray.collision_mask


func get_team() -> String:
    return my_team


func get_texture() -> Texture:
    return display.icon.texture


func get_world_position() -> Vector2i:
    var world_position = vision.convert_from_world_position(position)
    # TODO: fix another off-by-one error
    # for now, just subtrace one from x/y
    world_position.x -= 1
    world_position.y -= 1
    return world_position


func has_fuel() -> bool:
    return fuel_capacity > 0


func is_in_city() -> bool:
    return in_city != null


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

    state.switch_to('scout')


func assign_groups():
    if my_team != null:
        display.icon.modulate = Global.team_colors[my_team]
        add_to_group(my_team)
    add_to_group("Units")


func select_me():
    sounds.play_ready()


func set_automatic():
    automation.enabled = true


func set_in_city(city:City):
    in_city = city
    display.set_from_city()


func set_manual():
    automation.enabled = false


# TODO: find a way to use `new_team:Team`.
# We can not right now due to error with circular dependency.
func set_team(new_team:Node):
    my_team = new_team.name


func refill_moves():
    moves_remaining = moves_per_turn
    state.rotate()


func refuel():
    if not has_fuel():
        push_warning("can not refuel a unit that does not use fuel; ignoring refuel request")
    moves_remaining -= 1
    if moves_remaining < 0:
        moves_remaining = 0
    fuel_remaining = fuel_capacity


func disband():
    queue_free()
    # are we an invalid reference?
    # If not, perhaps a listener can benefit from knowing what we were
    SignalBus.unit_disbanded.emit(self)
