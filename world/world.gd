extends Node2D

@export var auto_start : bool

var music_tween : Tween
var fade_out_time = 0.25
var start_epoch: float = 0.0
var elapsed_seconds: float = 0.0

func _ready():
    if(auto_start): start()

func _on_introduction_faded_out():
    start()

func _physics_process(_delta):
    var winner = check_winner()
    if(winner != null):
        win(winner)

func check_winner():
    var teams_with_cities = []
    var city_owners = $cities.tally_owners()
    for team in city_owners.keys():
        if city_owners[team] == 0: continue
        teams_with_cities.append(team)
    if(teams_with_cities.size() != 1):
        return null
    return(teams_with_cities[0])

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

    SignalBus.team_won.emit(winner, $turns.turn_number, $teams.summarize(), elapsed_seconds)

func start():
    start_epoch = Time.get_unix_time_from_system()
    $turns.enable()
    $Music.play()
