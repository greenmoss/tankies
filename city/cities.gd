extends Node

func build_units():
    # only human cities build units for now
    for city in make_team_queue(Global.human_team):
        city.build_unit()

func make_team_queue(team_name):
    var team_queue = []
    for city in get_children():
        if city.my_team != team_name: continue
        team_queue.append(city)
    return(team_queue)

func tally_owners():
    var team_owners = {}
    for city in get_children():
        if team_owners.get(city.my_team) == null:
            team_owners[city.my_team] = 0
        team_owners[city.my_team] += 1
    return(team_owners)
