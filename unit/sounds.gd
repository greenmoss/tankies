extends Node

func stop_all():
    for child in get_children():
        child.stop()

func play_denied():
    stop_all()
    $Denied.play()

func play_move():
    if not ($Move.playing):
        $Move.play()

func play_ready():
    if not ($Ready.playing):
        $Ready.play()
