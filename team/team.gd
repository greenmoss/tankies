extends Node
class_name Team

@onready var state = $state
@onready var vision = $vision

@export var color:Color
@export var controller:Global.Controllers
@export var enemy_team:Team
# for path finding, we require terrain variable
@export var terrain:TileMap
# for finding cities, we require cities variable
@export var cities:Cities

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
    set_world_vars()


func get_my_cities() -> Array:
    if cities == null:
        return []
    return cities.get_from_team(name)


func get_my_valid_units() -> Array:
    if units == null:
        return []
    return units.get_all_valid()


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
        vision.update()


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
        return


func build_unit_in(city:City):
    var new_unit:Unit = $units.create(city.my_team, city.position)
    name_counter += 1
    new_unit.name = name+"_unit"+str(name_counter)
    new_unit.set_in_city(city)


func is_done() -> bool:
    return state.is_named('end')


func begin():
    state.switch_to('begin')


func move():
    state.switch_to('plan')


func summarize() -> String:
    var summary_template = "{name}: won battles - {battles_won}; lost battles - {battles_lost}"
    return summary_template.format({'name': name, 'battles_won': battles_won, 'battles_lost': battles_lost})


func restore(saved_team):
    var saved_units: Array = saved_team.saved_units
    units.restore(saved_units)


func save(saved: SavedWorld):
    units.save(saved)


func tally_units() -> int:
    # includes units being freed
    return units.get_children().size()
