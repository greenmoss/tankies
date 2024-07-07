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
# to allow this unit to hold units, set to positive int
var haul_unit_capacity = 0
# also set what type of unit can haul; uses same set of values as `navigation`
var haul_unit_type = ''
var hauled_in:Unit = null
var hauled_units:Array[Unit] = []
# to enable fuel/refuel mechanic, set to positive int
var fuel_capacity = 0
# to allow units to capture cities, set to true
var can_capture = false
# will be set as one of "air", "land", "ocean"
var navigation:String

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


func _ready():
    # when debugging, we are the root scene
    if get_parent() == get_tree().root:
        standalone = true
        position = Vector2(40,40)

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
    set_navigation()


# when we are debugging, e.g. in a standalone scene
# assume all input is for us, since there's no cursor
func _unhandled_input(event):
    if not standalone: return
    handle_cursor_input_event(event)


func assign_groups():
    if my_team != null:
        display.icon.modulate = Global.team_colors[my_team]
        add_to_group(my_team)
    add_to_group("Units")


func can_attack() -> bool:
    return attack_strength > 0


func can_haul(hauled_unit:Unit) -> bool:
    if hauled_unit.my_team != my_team: return false
    if haul_unit_capacity < 1: return false
    if hauled_unit.navigation != haul_unit_type: return false
    if hauled_units.size() >= haul_unit_capacity: return false
    return true


func disband():
    queue_free()
    # are we an invalid reference?
    # If not, perhaps a listener can benefit from knowing what we were
    SignalBus.unit_disbanded.emit(self)


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


# the cursor chooses who gets the events
# thus, we do not use _unhandled_input() here
func handle_cursor_input_event(event):
    state.handle_cursor_input(event)


func has_fuel() -> bool:
    return fuel_capacity > 0


func haul_to(new_position:Vector2):
    SignalBus.unit_moved_from_position.emit(self, position)
    position = new_position
    SignalBus.unit_moved_to_position.emit(self, position)


func haul_unit(hauled_unit:Unit):
    if not can_haul(hauled_unit):
        push_warning("unable to haul unit ",hauled_unit,"; ignoring")
        return
    hauled_units.append(hauled_unit)
    hauled_unit.set_hauled_in(self)


func haul_units_here():
    if not is_hauling(): return
    for hauled_unit in hauled_units:
        hauled_unit.haul_to(position)


func is_hauled() -> bool:
    return hauled_in != null


func is_hauling() -> bool:
    return not hauled_units.is_empty()


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


func refill_moves():
    moves_remaining = moves_per_turn
    state.rotate()


func select_me():
    sounds.play_ready()


func set_automatic():
    automation.enabled = true


func set_hauled_in(hauler_unit:Unit):
    hauled_in = hauler_unit


func set_in_city(city:City):
    in_city = city
    display.set_from_city()


func set_manual():
    automation.enabled = false


func set_navigation():
    match ray.collision_mask:
        1:
            navigation = 'air'
        3:
            navigation = 'ocean'
        5:
            navigation = 'land'


# TODO: find a way to use `new_team:Team`.
# We can not right now due to error with circular dependency.
func set_team(new_team:Node):
    my_team = new_team.name


func set_unhauled():
    # TODO: verify this unit is on navigable tile?
    if not is_hauled(): return
    if self in hauled_in.hauled_units:
        hauled_in.unhaul_unit(self)
    hauled_in = null


func unhaul_unit(hauled_unit:Unit):
    if hauled_unit not in hauled_units:
        push_warning("unable to unhaul unit ",hauled_unit,"; ignoring")
        return
    if is_in_city():
        hauled_unit.set_in_city(in_city)
    hauled_units.erase(hauled_unit)
    hauled_unit.set_unhauled()


func unhaul_units():
    if not is_hauling(): return
    # do not use foreach here
    # unhauling unit erase, which messes up foreach
    while hauled_units.size() > 0:
        unhaul_unit(hauled_units[0])


func refuel():
    if not has_fuel():
        push_warning("can not refuel a unit that does not use fuel; ignoring refuel request")
    moves_remaining -= 1
    if moves_remaining < 0:
        moves_remaining = 0
    fuel_remaining = fuel_capacity
