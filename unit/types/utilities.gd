extends Node

var default = 'tank'
var types = {}
var unit_types_path:String = get_script().resource_path.get_base_dir()


func _ready():
    for type_directory in DirAccess.get_directories_at(unit_types_path):
        load_unit_type_scene(type_directory)


func get_type(type:String) -> Unit:
    return types[type]


func get_types() -> Array:
    return types.keys()


func load_unit_type_scene(type_directory:String):
    var unit_scene:PackedScene = load(unit_types_path + '/' + type_directory + '/' + type_directory + '.tscn')
    types[type_directory] = unit_scene.instantiate()
    add_child(types[type_directory])
