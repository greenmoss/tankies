extends Node

var audio_tween:Tween
var fade_in_time = 0.25

var move_full_volume:float


func _ready():
    move_full_volume = $Move.volume_db


func play_denied():
    stop_all()
    $Denied.play()


func play_move():
    if not ($Move.playing):
        $Move.volume_db = move_full_volume - 10
        $Move.play()
        audio_tween = create_tween()
        audio_tween.tween_property($Move, "volume_db", move_full_volume, fade_in_time)


func play_ready():
    if not ($Ready.playing):
        $Ready.play()


func stop_all():
    for child in get_children():
        child.stop()
