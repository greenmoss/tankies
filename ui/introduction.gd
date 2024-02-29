extends CanvasLayer

var bg_tween : Tween
var music_tween : Tween
var fade_out_time = 0.25
var fade_in_time = 1.0

signal faded_out

func _ready():
    SignalBus.team_won.connect(_team_won)

func _team_won(winning_team, turn_number):
    fade_in("Victory!\n\nThe winner is\n\n"+winning_team+"\n\nOn turn "+str(turn_number))

func _on_button_pressed():
    fade_out()

func fade_in(message):
    $Background/Button.hide()
    $Background/Label.text = message
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
