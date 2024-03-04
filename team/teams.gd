extends Node

var teams = []
var teams_by_name = {}
var human_team : Node = null
var ai_team : Node = null

func _ready():
    SignalBus.city_requested_unit.connect(_city_requested_unit)
    teams = get_children()
    for team in teams:
        teams_by_name[team.name] = team
        if team.name == Global.human_team:
            # TODO: verify only one human team?
            human_team = team
            continue
        if team.name == Global.ai_team:
            # TODO: verify only one ai team?
            ai_team = team
            continue

func _city_requested_unit(city):
    teams_by_name[city.my_team].build_unit_in(city)

func are_done():
    if human_team.is_done():
        if ai_team.is_done():
            return true
        else:
            ai_team.move()
    return false

func start():
    await ai_team.pause()
    await ai_team.refill_moves()
    await human_team.refill_moves()
    human_team.move()

func summarize() -> Array:
    return [human_team.summarize(), ai_team.summarize()]
