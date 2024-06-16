extends Node

var default = 'tank'
var scenes = {}
var types = {}
var unit_types_path:String = get_script().resource_path.get_base_dir()


func _ready():
    for type_directory in DirAccess.get_directories_at(unit_types_path):
        load_unit_type_scene(type_directory)


func get_scene(type:String) -> PackedScene:
    return scenes[type]


func get_type(type:String) -> Unit:
    return types[type]


func get_type_from_unit(unit:Unit) -> String:
    return unit.scene_file_path.get_file().get_basename()


func get_types() -> Array:
    return types.keys()


func load_unit_type_scene(type_directory:String):
    var unit_scene:PackedScene = load(unit_types_path + '/' + type_directory + '/' + type_directory + '.tscn')
    scenes[type_directory] = unit_scene
    var unit:Unit = unit_scene.instantiate()
    types[type_directory] = unit
    unit.visible = false
    unit.position = Vector2(-100,-100)
    unit.monitoring = false
    unit.monitorable = false
    add_child(unit)
    unit.collision.disabled = true
