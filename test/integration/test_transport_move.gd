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
    var obstacles = world.obstacles

    var ocean_path = terrain.find_path(transport.position, Vector2(1560, 520), transport.navigation)
    assert_eq( Vector2(1000, 520), ocean_path[1],
        "an ocean path should intersect a neutral port city")
    assert_eq( 17, ocean_path.size(),
        "an ocean path should contain 17 hops")

    var transport_path = transport.find_path_to(Vector2(1560, 520), terrain, obstacles)
    assert_false( Vector2(1000, 520) in transport_path,
        "a transport path should not intersect a neutral city")
    assert_eq( 17, transport_path.size(),
        "a transport path should contain 17 hops")


func test_transport_unload_small_island():
    loader.restore('999_gut-forlorn-transport.tres')
    var world = loader.world
    world.start()

    world.teams.human_team.units.create('tank', Vector2(40, 40), 'tank')

    var position1 = Vector2(600, 200)
    world.teams.ai_team.units.create('transport', position1, 'transport1')
    world.teams.ai_team.units.create('tank', position1, 'tank1')

    var ai_units = world.teams.ai_team.units.get_children()
    var transport1 = ai_units[0]
    transport1.haul_unit(ai_units[1])

    action_event.action = "next"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(0.5).timeout

    action_event.action = "skip"
    action_event.pressed = true
    Input.parse_input_event(action_event)

    # wait for next turn, thus AI completed its moves
    while world.turns.turn_number == 1:
        await get_tree().process_frame

    assert_eq( ai_units[1].get_position(), Vector2(680,280),
        "after transport unhauled to small island, tank unhauled and explored" )


func test_transport_unload_adjacent_city():
    loader.restore('999_gut-forlorn-transport.tres')
    var world = loader.world
    world.start()

    world.teams.human_team.units.create('tank', Vector2(40, 40), 'tank')

    var position2 = Vector2(920, 520)
    world.teams.ai_team.units.create('transport', position2, 'transport2')
    world.teams.ai_team.units.create('tank', position2, 'tank2')

    var ai_units = world.teams.ai_team.units.get_children()

    var transport2 = ai_units[0]
    transport2.haul_unit(ai_units[1])

    action_event.action = "next"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(0.5).timeout

    action_event.action = "skip"
    action_event.pressed = true
    Input.parse_input_event(action_event)

    # wait for next turn, thus AI completed its moves
    while world.turns.turn_number == 1:
        await get_tree().process_frame

    assert_eq( ai_units[1].get_position(), Vector2(760, 360),
        "transport adjacent to neutral city moves to accessible land to unhaul its tank" )
