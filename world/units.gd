extends Node

var unit_scene = preload("res://unit/unit.tscn")

func make_team_queue(team_name):
    var team_queue = []
    for unit in get_children():
        if unit.my_team != team_name: continue
        unit.reset_moves()
        team_queue.append(unit)
    return(team_queue)
    #turn_queues[team_name] = team_queue

func create(team_name, coordinates):
    var new_unit = unit_scene.instantiate()
    new_unit.my_team = team_name
    new_unit.position = coordinates
    add_child(new_unit)
