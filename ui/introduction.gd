extends CanvasLayer

@export var won = false
func _ready():
    SignalBus.team_won.connect(_team_won)
    won = false

func _team_won(winning_team):
    $Button.hide()
    $Label.text = "Victory!\n\nThe winner is\n\n"+winning_team
    self.show()

func _on_button_pressed():
    if not won: self.hide()
