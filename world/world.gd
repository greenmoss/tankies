extends Node2D

func _ready():
    SignalBus.unit_collided.connect(_unit_collided)

func _physics_process(_delta):
    var winner = check_winner()
    if(winner != null):
        SignalBus.team_won.emit(winner)
        $turns.stop()
        set_physics_process(false)

func _unit_collided(unit, target):
    '''
    What does the unit do when it hits something?

    For a friendly city: move inside
    For a neutral or hostile city: attack
    For a hostile unit: attack
    '''
    if target.is_in_group("Cities"):
        unit.move_to_requested()
        unit.enter_city(target)
        return

    unit.deny_move()

func check_winner():
    var teams_with_cities = []
    var city_owners = $cities.tally_owners()
    for team in city_owners.keys():
        if city_owners[team] == 0: continue
        teams_with_cities.append(team)
    if(teams_with_cities.size() != 1):
        return null
    return(teams_with_cities[0])
