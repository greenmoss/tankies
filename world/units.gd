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

func start_turn():
    taking_turn = true

    set_team_queue(Global.human_team)
    set_team_queue(Global.ai_team)

func run_turn_loop():
    var humans_done = true
    for unit in turn_queues[Global.human_team]:
        if unit.has_more_moves():
            humans_done = false
            break

    var ai_done = true
    if(humans_done and ai_done):
        taking_turn = false

func take_team_turn(team_name):
    print(turn_queues[team_name])
