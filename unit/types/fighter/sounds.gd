extends UnitSounds

var audio_tween_down:Tween

func play_descend():
    if $Move.playing:
        audio_tween_down = create_tween()
        audio_tween_down.tween_property($Move, "volume_db", -80, fade_in_time)

    $Descend.play()
    await $Descend.finished
