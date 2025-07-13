extends Node2D
class_name World

var music_tween:Tween
var music_fade_time = 0.25
var start_epoch = Time.get_unix_time_from_system()
var regions = []

@onready var battle = $battle
@onready var cities = $Map/cities
@onready var map = $Map
@onready var music = $Music
@onready var obstacles = $obstacles
@onready var teams = $teams
@onready var terrain = $Map/Terrain
@onready var tint = $tint
@onready var turns = $turns

@onready var fresh = true
@onready var music_default_volume = music.volume_db


func _ready():
    Global.set_z(tint, 'tint')
    # if we are the root scene, we are debugging/standalone so start now
    #TODO: switch to @tool to save new scenarios
    # to save a scenario, uncomment this line and comment the if/else
    #start()
    if get_parent() == get_tree().root:
        start()
    else:
        stop()


func _physics_process(_delta):
    var winner = check_winner()
    if(winner != null):
        win(winner)


func check_winner():
    var units_tally = teams.tally_units()
    var cities_tally = cities.tally_owners()

    var unit_winner = get_tally_winner(units_tally)
    var city_winner = get_tally_winner(cities_tally)

    if city_winner != unit_winner:
        return null

    return(city_winner)


func get_tally_winner(team_tallies):
    # We invoke this function to check both city and unit tallies
    var remaining_team_tallies = []
    for team in team_tallies.keys():
        if team_tallies[team] == 0: continue
        remaining_team_tallies.append(team)

    var remaining_count = remaining_team_tallies.size()

    # One team remains, thus that team is the winner
    if(remaining_count == 1):
        return remaining_team_tallies[0]

    if(remaining_count == 2):
        var remaining_teams = team_tallies.keys()

        # If AI and neutral remain, AI is the winner
        if (Global.ai_team in remaining_teams) and (Global.neutral_team in remaining_teams):
            return(Global.ai_team)

        # If human and neutral remain, human must eliminate neutral, thus no winner
        return null

    # No team is the winner
    return null


func get_team_by_name(team_name:String) -> Team:
    return teams.get_by_name(team_name)


func is_fresh():
    return fresh


func restore(data):
    cities.restore(data.cities)
    teams.restore(data.teams)
    terrain.restore(data.terrain)
    map.set_regions()


func save(data):
    cities.save(data)
    teams.save(data)
    terrain.save(data)


func start():
    fresh = false
    tint.visible = false
    start_epoch = Time.get_unix_time_from_system()
    cities.initialize(map)

    obstacles.set_from_cities(cities)
    for team in teams.get_children():
        obstacles.set_from_units(team.units)

    turns.enable()
    music.volume_db = music_default_volume
    music.play()
    set_physics_process(true)


func stop():
    turns.stop()
    set_physics_process(false)
    # remove everything to prevent stale state on load
    cities.clear()
    teams.reset()

    # fade music to silent and stop
    if music.playing:
        music_tween = create_tween()
        music_tween.tween_property(music, "volume_db", -80, music_fade_time)
        await music_tween.finished
        music.stop()

    fresh = true


func win(winner):
    var elapsed_seconds = Time.get_unix_time_from_system() - start_epoch
    var team_summary = teams.summarize()
    var fade_tween = create_tween()
    tint.modulate.a = 0.0
    tint.visible = true
    fade_tween.tween_property(tint, "modulate:a", 1.0, 1.0)
    await fade_tween.finished
    tint.visible = false
    stop()

    SignalBus.team_won.emit(winner, turns.turn_number, team_summary, elapsed_seconds)
