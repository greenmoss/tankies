extends ColorRect

func done_moving():
    $SleepBackground.hide()
    show()

func sleep_infinity():
    $SleepBackground.show()
    $SleepBackground/SleepTurns.text = "∞"
    show()

func awaken():
    hide()
