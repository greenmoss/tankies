extends Node
class_name Loader

@export var world: Node2D

@onready var cities = world.cities
@onready var teams = world.teams
@onready var terrain = world.terrain

func get_full_path(save_name) -> String:
    return 'res://save/scenarios/'+save_name+'.tres'

func restore(save_name:String) -> SavedWorld:
    var full_save_path = get_full_path(save_name)
    var data = load(full_save_path)

    cities.restore(data.cities)
    teams.restore(data.teams)

    return data

func save(save_name:String):
    var data = SavedWorld.new()
    var full_save_path = get_full_path(save_name)
    # clear any existing save file
    # overwrites without asking!
    ResourceSaver.save(data, full_save_path)

    cities.save(data)
    teams.save(data)

    var tile_map_layers = []
    for layer_number in terrain.get_layers_count():
        tile_map_layers.append(terrain.get("layer_"+str(layer_number)+"/tile_data"))
    data.terrain = tile_map_layers

    ResourceSaver.save(data, full_save_path)
