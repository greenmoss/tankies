extends Node
class_name Loader

@export var world_scene: PackedScene

# TODO: figure out how to use this instead:
#get_script().resource_path
# currently returns
#res://save/loader.gd
# but we want
#res://save
var scenarios_path = 'res://save/scenarios'

var scenarios = []

var world: World

func _ready():
    set_new_world()
    for scenario_file in DirAccess.get_files_at(scenarios_path):
        # exported resources get ".remap" suffix; workaround:
        # https://github.com/godotengine/godot/issues/66014#issuecomment-1832998685
        if scenario_file.ends_with(".remap"): scenario_file = scenario_file.trim_suffix(".remap")
        var scenario = load(get_full_path(scenario_file))
        scenarios.append(scenario)

func get_full_path(save_name) -> String:
    return scenarios_path+'/'+save_name

# if we run this multiple times with a new/fresh world:
# it will not instantiate a new world
# instead it will retain the same new/fresh world
func set_new_world():
    if world != null:
        if is_instance_valid(world):
            if world.is_fresh():
                return

            world.queue_free()

    world = world_scene.instantiate()
    add_child(world)

func restore(save_name:String):
    set_new_world()
    var full_save_path = get_full_path(save_name)
    var data = load(full_save_path)

    world.cities.restore(data.cities)
    world.teams.restore(data.teams)
    world.terrain.restore(data.terrain)

func save(save_name:String):
    var data = SavedWorld.new()

    world.cities.save(data)
    world.teams.save(data)
    world.terrain.save(data)

    var full_save_path = get_full_path(save_name)
    # clear any existing save file
    # overwrites without asking!
    ResourceSaver.save(data, full_save_path)
