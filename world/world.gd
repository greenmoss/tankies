extends Node2D
class_name World

@export var auto_start : bool

var music_tween : Tween
var fade_out_time = 0.25
var start_epoch: float = 0.0
var elapsed_seconds: float = 0.0

@onready var cities = $Map/cities
@onready var teams = $teams
@onready var terrain = $Map/Terrain

func _ready():
    if(auto_start): start()

func _physics_process(_delta):
    var winner = check_winner()
    if(winner != null):
        win(winner)

func get_remaining_team(team_tallies):
    var remaining_team_tallies = []
    for team in team_tallies.keys():
        if team_tallies[team] == 0: continue
        remaining_team_tallies.append(team)
    if(remaining_team_tallies.size() != 1):
        return null
    return(remaining_team_tallies[0])

func check_winner():
    var unit_winner = get_remaining_team(teams.tally_units())
    var city_winner = get_remaining_team(cities.tally_owners())

    if city_winner != unit_winner:
        return null

    return(city_winner)

func win(winner):
    elapsed_seconds = Time.get_unix_time_from_system() - start_epoch

    $turns.stop()
    set_physics_process(false)

    # fade music to silent and stop
    if $Music.playing:
        music_tween = create_tween()
        music_tween.tween_property($Music, "volume_db", -80, fade_out_time)
        await music_tween.finished
        $Music.stop()

    SignalBus.team_won.emit(winner, $turns.turn_number, teams.summarize(), elapsed_seconds)

func start():
    start_epoch = Time.get_unix_time_from_system()
    $turns.enable()
    $Music.play()
    set_physics_process(true)
