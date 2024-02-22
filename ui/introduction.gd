extends CanvasLayer

@export var won = false

func _ready():
    SignalBus.team_won.connect(_team_won)
    won = false

func _team_won(winning_team, turn_number):
    $Button.hide()
    $Label.text = "Victory!\n\nThe winner is\n\n"+winning_team+"\n\nOn turn "+str(turn_number)
    self.show()

func _on_button_pressed():
    if not won: self.hide()
