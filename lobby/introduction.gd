extends CanvasLayer

var bg_tween : Tween
var music_tween : Tween
var fade_out_time = 0.25
var fade_in_time = 1.0

signal faded_out

func _ready():
    SignalBus.team_won.connect(_team_won)

func _team_won(winning_team, turn_number, teams_summary, elapsed_seconds):
    var game_over_template = '''
    Game over!

    The winner is {winner}

    Turns: {turn_count}
    Time Spent (HH:MM:SS): {elapsed}

    Teams:
    {teams_summary}
    '''
    var game_over_message = game_over_template.format(
        {'winner': winning_team, 'turn_count': turn_number, 'elapsed': Time.get_time_string_from_unix_time(elapsed_seconds), 'teams_summary': "\n".join(teams_summary)}
    )
    fade_in(game_over_message)

func _on_button_pressed():
    fade_out()

func fade_in(message):
    $Background/Button.hide()
    set_message(message)
    # start with transparent background
    $Background.modulate.a = 0.0

    show()

    # fade in to opaque background
    bg_tween = create_tween()
    bg_tween.tween_property($Background, "modulate:a", 1.0, fade_out_time)
    await bg_tween.finished

    $Music.volume_db = 0
    $Music.play()

func fade_out():
    # if music is playing start fading it to silent
    if $Music.playing:
        music_tween = create_tween()
        music_tween.tween_property($Music, "volume_db", -80, fade_out_time)

    # then fade intro to transparent
    bg_tween = create_tween()
    bg_tween.tween_property($Background, "modulate:a", 0.0, fade_out_time)
    await bg_tween.finished

    hide()
    $Music.stop()

    faded_out.emit()

func set_message(message):
    $Background/Label.text = message
