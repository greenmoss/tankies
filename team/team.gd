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
    SignalBus.want_next_unit.connect(_handle_next_unit_signals)
    SignalBus.unit_completed_moves.connect(_handle_next_unit_signals)
    SignalBus.city_captured.connect(_city_captured)
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

func _city_captured(city):
    if city.my_team != name: return
    await move_next_unit()

func _handle_next_unit_signals(wanted_team):
    if wanted_team != name: return
    await move_next_unit()

func build_unit_in(city):
    var new_unit = $units.create(city.my_team, city.position)
    await new_unit.enter_city(city)

func is_done():
    return units.are_done()

func refill_moves():
    await units.refill_moves()

func move_next_unit():
    print("WARNING: ignoring stub call to move_next_unit for team ", self)

func summarize() -> String:
    var summary_template = "{name}: won battles - {battles_won}; lost battles - {battles_lost}"
    return summary_template.format({'name': name, 'battles_won': battles_won, 'battles_lost': battles_lost})
