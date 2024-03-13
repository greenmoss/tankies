extends Node2D
class_name Lobby

@onready var introduction = $Introduction
@onready var loader = $Loader
@onready var world = $World

var selected_scenario_name: String

func _ready():
    SignalBus.introduction_pressed_start.connect(_introduction_pressed_start)
    SignalBus.introduction_selected_scenario.connect(_introduction_selected_scenario)
    introduction.set_scenarios(loader.scenarios)

func _introduction_selected_scenario(scenario_name):
    selected_scenario_name = scenario_name

func _introduction_pressed_start():
    loader.restore(selected_scenario_name)

func _on_introduction_faded_out():
    world.start()
