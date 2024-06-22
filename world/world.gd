extends Node2D
class_name World

var music_tween: Tween
var music_fade_time = 0.25
var start_epoch = Time.get_unix_time_from_system()

@onready var cities = $Map/cities
@onready var music = $Music
@onready var teams = $teams
@onready var terrain = $Map/Terrain
@onready var tint = $tint
@onready var turns = $turns

@onready var fresh = true
@onready var music_default_volume = music.volume_db


func _ready():
    # if we are the root scene, we are debugging/standalone so start now
    if get_parent() == get_tree().root:
        start()
    else:
        stop()


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


func get_team_by_name(team_name:String) -> Team:
    return teams.get_by_name(team_name)


func check_winner():
    var unit_winner = get_remaining_team(teams.tally_units())
    var city_winner = get_remaining_team(cities.tally_owners())

    if city_winner != unit_winner:
        return null

    return(city_winner)


func is_fresh():
    return fresh


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


func start():
    fresh = false
    tint.visible = false
    start_epoch = Time.get_unix_time_from_system()
    turns.enable()
    music.volume_db = music_default_volume
    music.play()
    set_physics_process(true)


func stop():
    turns.stop()
    set_physics_process(false)
    # remove everything to prevent stale state on load
    cities.reset()
    teams.reset()

    # fade music to silent and stop
    if music.playing:
        music_tween = create_tween()
        music_tween.tween_property(music, "volume_db", -80, music_fade_time)
        await music_tween.finished
        music.stop()

    fresh = true
