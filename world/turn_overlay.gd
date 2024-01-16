extends CanvasLayer

var done_turn_text = "Done with turn "
var start_turn_text = "Starting turn "

func display(done_turn, start_turn):
    if done_turn < 1: return

    $DoneTurnLabel.text = done_turn_text + str(done_turn)
    $StartTurnLabel.text = start_turn_text + str(start_turn)
    show()
    $CoolDownTimer.start()

func _on_cool_down_timer_timeout():
    hide()
