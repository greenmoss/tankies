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

func test_transport_finds_path_past_neutral_city():
    loader.restore('999_gut-forlorn-transport.tres')
    var world = loader.world
    world.start()

    world.teams.human_team.units.create('transport', Vector2(920, 520), 'transport')
    await get_tree().create_timer(.5).timeout
    var human_units = world.teams.human_team.units.get_children()
    var transport = human_units[0]
    var terrain = world.terrain

    var ocean_path = terrain.find_path(transport.position, Vector2(1560, 520), transport.navigation)
    assert_eq( Vector2(1000, 520), ocean_path[1],
        "an ocean path should intersect a neutral city")

    var transport_path = transport.find_path_to(Vector2(1560, 520), world)
    assert_false( Vector2(1000, 520) in transport_path,
        "a transport path should not intersect a neutral city")
    #breakpoint
