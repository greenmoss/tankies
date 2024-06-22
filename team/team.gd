extends Node
class_name Team

@onready var fog = $fog
@onready var stack_lids = $stack_lids
@onready var state = $state
@onready var vision = $vision

@export var color:Color
@export var controller:Global.Controllers
@export var enemy_team:Team
# for path finding, we require terrain variable
@export var terrain:TileMap
# for finding cities, we require cities variable
@export var cities:Cities
@export var show_fog:bool

# these two are only set if we're within a world
var units:Units = null
var enemy_units:Units = null

var battles_won:int = 0
var battles_lost:int = 0

var standalone:bool = false

# use this to make friendlier team names which helps with debugging
var name_counter = 0


func _ready():
    SignalBus.battle_finished.connect(_battle_finished)
    SignalBus.cursor_marked_unit.connect(_cursor_marked_unit)
    SignalBus.unit_moved_from_position.connect(_moved_from_position)
    SignalBus.unit_moved_to_position.connect(_moved_to_position)

    set_world_vars()
    set_units_in_cities()
    stack_lids.set_from_units(units)


# winner is always a Unit
# however if we set "winner:Unit", we get error
# `Cannot convert argument 1 from Object to Object.`
func _battle_finished(winner, loser):
    if loser.is_in_group("Cities"): return
    if winner.my_team == name:
        battles_won += 1
        return
    if loser.my_team == name:
        battles_lost += 1
        stack_lids.remove_from_stack(loser.position, loser)
        return


func _cursor_marked_unit(unit:Unit):
    if unit.my_team != name: return
    stack_lids.set_stack(units.get_at_position(unit.position))
    stack_lids.promote_unit(unit)


func _moved_from_position(unit:Unit, old_position:Vector2):
    if unit.my_team != name: return
    stack_lids.remove_from_stack(old_position, unit)


func _moved_to_position(unit:Unit, _new_position:Vector2):
    if unit.my_team != name: return
    stack_lids.set_stack(units.get_at_position(unit.position))
    stack_lids.promote_unit(unit)


func get_my_cities() -> Array:
    if cities == null:
        return []
    return cities.get_from_team(name)


func get_my_valid_units() -> Array:
    if units == null:
        return []
    return units.get_all_valid()


func get_units_in_city(city:City) -> Array[Unit]:
    var found_units:Array[Unit] = []
    for unit in get_my_valid_units():
        if unit.in_city != city: continue
        found_units.append(unit)
    return found_units


func reset():
    units.reset()
    stack_lids.reset()
    vision.reset(terrain)


# if a unit is at same position as a city
# set that unit to be inside that city
func set_units_in_cities():
    for city in get_my_cities():
        for unit in get_my_valid_units():
            if unit.position != city.position: continue
            unit.set_in_city(city)


# if we are an instance in the world, set up all variables connected to the world
# otherwise, we are only a scene without units, terrain, etc
func set_world_vars():
    if terrain == null:
        standalone = true

    if enemy_team == null:
        standalone = true
    else:
        enemy_units = enemy_team.units

    units = find_child('units', false)
    if units == null:
        standalone = true
    else:
        stack_lids.reset()
        vision.reset(terrain)


func build_unit_in(city:City):
    name_counter += 1
    var unit_type = city.build_type
    var unit_name = name+"_"+unit_type+str(name_counter)
    var new_unit:Unit = units.create(unit_type, city.position, unit_name)
    new_unit.set_in_city(city)


func is_done() -> bool:
    return state.is_named('end')


func begin():
    state.switch_to('begin')


func move():
    state.switch_to('plan')


func summarize() -> String:
    var exploration = vision.tally_explored()
    var total_tiles = exploration['explored'] + exploration['unexplored']
    var percent_explored = 0.0
    if total_tiles > 0:
        percent_explored = float(exploration['explored']) / float(total_tiles) * 100.0

    var total_battles = battles_won + battles_lost
    var percent_won = 0.0
    if total_battles > 0:
        percent_won = float(battles_won) / float(total_battles) * 100.0

    var summary_template = "{name}: won battles - {percent_won}%; exploration: {percent_explored}%"
    return summary_template.format({'name': name, 'percent_won': '%0.0f'%percent_won, 'percent_explored': '%0.0f'%percent_explored})


func restore(saved_team):
    reset()
    var saved_units: Array = saved_team.saved_units
    units.restore(saved_units)


func save(saved: SavedWorld):
    units.save(saved)


func tally_units() -> int:
    # includes units being freed
    return units.get_children().size()
