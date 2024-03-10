extends Node2D
class_name Lobby

@onready var loader = $Loader
@onready var world = $World

func _ready():
    #loader.save('1-2-1')
    var saved_world = loader.restore('0-1-0')
    $Introduction.set_message(saved_world.objective)

func _on_introduction_visibility_changed():
    world.show()
