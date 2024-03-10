extends Node2D

@onready var loader = $Loader
@onready var world = $World

func _ready():
    var saved_world = loader.restore('1-2-1')
    $Introduction.set_message(saved_world.objective)

func _on_introduction_visibility_changed():
    world.show()
