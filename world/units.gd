extends Node

var turn_queues = {}

var taking_turn = false

func set_team_queue(team_name):
    var team_queue = []
    for unit in get_children():
        if unit.my_team != team_name: continue
        unit.reset_moves()
        team_queue.append(unit)
    turn_queues[team_name] = team_queue

func end_turn():
    taking_turn = false

func start_turn():
    taking_turn = true

    set_team_queue(Global.human_team)
    set_team_queue(Global.ai_team)

func run_turn_loop():
    var humans_done = true
    for unit in turn_queues[Global.human_team]:
        # this happens when we remove a unit
        if not is_instance_valid(unit): continue

        if unit.has_more_moves():
            humans_done = false
            break

    var ai_done = true
    if(humans_done and ai_done):
        end_turn()
