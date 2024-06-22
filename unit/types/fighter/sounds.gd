extends UnitSounds


func play_descend():
    SoundManager.tween_channel_volume("unit_moved", -80, 0.25)

    # play here instead of audio manager
    # allows us to block until the sound has completed playing
    $Descend.play()
    await $Descend.finished
