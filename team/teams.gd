extends Node
class_name Teams

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

func restore(saved_teams):
    if(saved_teams.is_empty()): return

    for saved_team in saved_teams:
        for team in get_children():
            if saved_team.name != team.name: continue
            team.restore(saved_team)

func save(saved: SavedWorld):
    for team in get_children():
        saved.save_team(team)

func tally_units() -> Dictionary:
    var team_units = {}
    for team in get_children():
        team_units[team.name] = team.tally_units()
    return team_units
