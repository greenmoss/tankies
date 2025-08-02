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

func test_ai_destroys_transport_and_conquers_city():
    loader.restore('000_test-forlorn-transport.tres')
    var world = loader.world
    world.start()

    world.teams.human_team.units.create('transport', Vector2(440, 120), 'transport')
    world.teams.ai_team.units.create('tank', Vector2(440, 200), 'tank')

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

    # ai destroys transport
    await SignalBus.battle_finished
    # ai attacks city
    await SignalBus.battle_finished
    # ai conquers city
    await SignalBus.city_updated_vision

    assert_eq( world.check_winner(), 'RedTeam',
        "after ai attack and conquer, Red is the winner" )

func test_ai_conquers_city_but_human_continues():
    loader.restore('000_test-forlorn-transport.tres')
    var world = loader.world
    world.start()

    world.teams.human_team.units.create('tank', Vector2(120, 120), 'human_tank')
    world.teams.ai_team.units.create('tank', Vector2(440, 200), 'ai_tank')

    action_event.action = "next"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(0.5).timeout

    world.battle.override_winner(Battle.Sides.Attacker)
    assert_null(world.check_winner(), "before ai conquered the city, winner is not set")

    action_event.action = "skip"
    action_event.pressed = true
    Input.parse_input_event(action_event)

    await SignalBus.city_updated_vision

    assert_null(world.check_winner(), "after ai conquered the city, human team still has one tank so winner is still not set")

func test_one_turn_human_and_ai():
    loader.restore('000_test-land.tres')
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

    # wait for next turn, thus AI completed its moves
    while loader.world.turns.turn_number == 1:
        await get_tree().process_frame

    assert_eq( ai_unit.get_world_position(), Vector2i(20,10),
        "after human skips remaining, ai has moved up and left" )
    assert_eq( human_unit.get_world_position(), Vector2i(3,2),
        "human skips remaining, human is still one position right" )
    assert_eq( loader.world.turns.turn_number, 2,
        "human skips remaining, we are on turn 2" )
