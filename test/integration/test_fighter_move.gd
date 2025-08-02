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

func test_fighter_destroys_tank_green_is_winner():
    loader.restore('999_gut-fighter.tres')
    var world = loader.world
    world.start()

    action_event.action = "next"
    action_event.pressed = true
    Input.parse_input_event(action_event)
    await get_tree().create_timer(0.5).timeout

    world.battle.override_winner(Battle.Sides.Attacker)
    assert_null(world.check_winner(), "before fighter attacked tank, winner is not set")

    action_event.action = "left"
    action_event.pressed = true
    Input.parse_input_event(action_event)

    # fighter destroys tank
    await SignalBus.battle_finished

    assert_eq( world.check_winner(), 'GreenTeam',
        "after fighter attacks and destroys tank, Green is the winner" )
