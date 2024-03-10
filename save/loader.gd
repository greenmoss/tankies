extends Node
class_name Loader

@export var world: Node2D

@onready var cities = world.cities
@onready var teams = world.teams
@onready var terrain = world.terrain

func get_full_path(save_name) -> String:
    # TODO: figure out how to use this instead:
    #get_script().resource_path
    # currently returns
    #res://save/loader.gd
    # but we want
    #res://save
    return 'res://save/scenarios/'+save_name+'.tres'

func restore(save_name:String) -> SavedWorld:
    var full_save_path = get_full_path(save_name)
    var data = load(full_save_path)

    cities.restore(data.cities)
    teams.restore(data.teams)
    terrain.restore(data.terrain)

    return data

func save(save_name:String):
    var data = SavedWorld.new()

    cities.save(data)
    teams.save(data)
    terrain.save(data)

    var full_save_path = get_full_path(save_name)
    # clear any existing save file
    # overwrites without asking!
    ResourceSaver.save(data, full_save_path)
