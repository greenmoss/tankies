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

func test_obstacles_with_one_tank():
    loader.restore('999_gut-forlorn-transport.tres')
    var world = loader.world
    world.start()

    var obstacles = world.obstacles

    # TODO: derive total grid size from tile map?
    assert_eq( obstacles.points.size(), 336,
        "at start, there are expected number of obstacle points" )
    assert_eq( obstacles.objects.size(), 4,
        "at start, there are 4 obstacles, one for each city" )
    assert_eq( obstacles.get_filled_points().size(), 4,
        "at start, there are 4 filled points, one for each city" )

    world.teams.human_team.units.create('tank', Vector2(360, 120), 'green_tank1')
    await get_tree().create_timer(.5).timeout
    var human_units = world.teams.human_team.units.get_children()
    var tank = human_units[0]

    assert_eq( obstacles.objects.size(), 5,
        "after adding one unit, there are 5 obstacles" )
    assert_eq( obstacles.get_filled_points().size(), 5,
        "after adding one unit, there are 5 filled points" )

    action_event.action = "next"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(0.5).timeout

    action_event.action = "right"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(0.5).timeout

    assert_eq( obstacles.objects.size(), 5,
        "after moving tank right, there are 5 obstacles" )
    assert_eq( obstacles.get_filled_points().size(), 4,
        "after moving tank right, tank is in city so there are 4 filled points" )
