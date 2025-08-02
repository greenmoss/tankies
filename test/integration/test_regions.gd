extends GutTest

var _sender = InputSender.new(Input)
var loader_script = preload("res://save/loader.gd")
var world_scene = preload("res://world/world.tscn")
var loader = null
var action_event = InputEventAction.new()


func before_each():
    loader = loader_script.new()
    loader.world_scene = world_scene
    get_tree().current_scene.add_child(loader)


func after_each():
    loader.queue_free()
    _sender.release_all()
    _sender.clear()


func test_region_approaches():
    loader.restore('000_test-forlorn-transport.tres')
    var world = loader.world
    world.start()

    var approaches = world.map.regions.get_by_id(6).approaches

    assert_true( Vector2i(13, 0) in approaches,
        "Region 6 approach on mixed map includes top left border with map edge")

    assert_true( Vector2i(17, 0) in approaches,
        "Region 6 approach on mixed map includes top right border with map edge")

    assert_true( Vector2i(11, 5) in approaches,
        "Region 6 approach on mixed map includes straight approach to land, diagonal to port city")

    assert_false( Vector2i(11, 6) in approaches,
        "Region 6 approach on mixed map excludes point that is only adjacent to port city")
