extends Node
class_name Team

@export var color : Color
@export var controller: Global.Controllers

@export var enemy_team: Team
@export var terrain: TileMap

var units : Node = null
var enemy_units: Node = null

var battles_won: int = 0
var battles_lost: int = 0

func _ready():
    SignalBus.battle_finished.connect(_battle_finished)
    # if we are an instance in the world, find our units
    # otherwise, we are only a scene without units
    units = find_child('units', false)
    if enemy_team != null:
        enemy_units = enemy_team.units


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
    new_unit.set_in_city(city)


func is_done() -> bool:
    return units.are_done()


func refill_moves():
    await units.refill_moves()


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
