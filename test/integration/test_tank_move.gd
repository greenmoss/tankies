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

func test_ai_takes_city_with_transport():
    loader.restore('000_test-ocean.tres')
    var world = loader.world
    world.start()

    action_event.action = "next"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(0.5).timeout

    var tally = world.cities.tally_owners()
    assert_eq( tally['GreenTeam'], 1,
        "at start, Green has one city" )
    assert_eq( tally['RedTeam'], 1,
        "at start, Red has one city" )

    world.battle.override_winner(Battle.Sides.Attacker)

    action_event.action = "skip"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(3).timeout

    tally = world.cities.tally_owners()
    assert_eq( tally['RedTeam'], 2,
        "after ai move, Red has two cities" )

func test_one_turn_human_and_ai():
    loader.restore('04_1-2-1.tres')
    loader.world.start()
    var ai_units = loader.world.teams.ai_team.units.get_children()
    var human_units = loader.world.teams.human_team.units.get_children()
    var ai_unit = ai_units[0]
    var human_unit = human_units[0]

    assert_eq( ai_unit.get_world_position(), Vector2i(21,11),
        "at start, ai position matches starting point" )
    assert_eq( human_unit.get_world_position(), Vector2i(2,2),
        "at start, human position matches starting point" )
    assert_eq( loader.world.turns.turn_number, 1,
        "at start, we are on turn 1" )

    action_event.action = "next"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(0.5).timeout

    assert_eq( ai_unit.get_world_position(), Vector2i(21,11),
        "after human unit select, ai position matches starting point" )
    assert_eq( human_unit.get_world_position(), Vector2i(2,2),
        "after human unit select, human position matches starting point" )
    assert_eq( loader.world.turns.turn_number, 1,
        "after human unit select, we are on turn 1" )

    action_event.action = "right"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(0.5).timeout

    assert_eq( ai_unit.get_world_position(), Vector2i(21,11),
        "after one human move, ai position matches starting point" )
    assert_eq( human_unit.get_world_position(), Vector2i(3,2),
        "after one human move, human has moved one position right" )
    assert_eq( loader.world.turns.turn_number, 1,
        "after one human move, we are on turn 1" )

    action_event.action = "skip"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(1).timeout

    assert_eq( ai_unit.get_world_position(), Vector2i(20,10),
        "after human skips remaining, ai has moved up and left" )
    assert_eq( human_unit.get_world_position(), Vector2i(3,2),
        "human skips remaining, human is still one position right" )
    assert_eq( loader.world.turns.turn_number, 2,
        "human skips remaining, we are on turn 2" )
