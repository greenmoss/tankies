extends Node

var unit_scene = preload("res://unit/unit.tscn")

## for every team, track which unit moved last
var team_prior_unit = {}

func _ready():
    SignalBus.city_requested_unit.connect(_city_requested_unit)

func _city_requested_unit(city):
    var new_unit = create(city.my_team, city.position)
    new_unit.enter_city(city)

func make_team_queue(team_name):
    if team_prior_unit.has(team_name):
        var prior_unit = team_prior_unit[team_name]
        if is_instance_valid(prior_unit):
          move_child(prior_unit, 0)

    var team_queue = []
    for unit in get_children():
        if unit.my_team != team_name: continue
        unit.reset_moves()
        team_queue.append(unit)
    return(team_queue)

func create(team_name, coordinates):
    var new_unit = unit_scene.instantiate()
    new_unit.my_team = team_name
    new_unit.position = coordinates
    add_child(new_unit)
    return(new_unit)

func select_first(team_queue):
    if team_queue.is_empty(): return
    for unit in team_queue:
        if not is_instance_valid(unit): continue
        if unit.is_sleeping(): continue
        if not unit.has_more_moves(): continue
        unit.select_me()
        break
