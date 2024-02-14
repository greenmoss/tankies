extends Node2D

func _physics_process(_delta):
    var winner = check_winner()
    if(winner != null):
        SignalBus.team_won.emit(winner)
        $turns.stop()
        set_physics_process(false)

func check_winner():
    var teams_with_cities = []
    var city_owners = $cities.tally_owners()
    for team in city_owners.keys():
        if city_owners[team] == 0: continue
        teams_with_cities.append(team)
    if(teams_with_cities.size() != 1):
        return null
    return(teams_with_cities[0])
