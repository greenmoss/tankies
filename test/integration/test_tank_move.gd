#extends Node
extends GutTest
#extends GUT.TestSuite

var world

func before_each():
    var world_scene = preload("res://world/world.tscn")
    world = world_scene.instantiate()
    get_tree().current_scene.add_child(world)

func after_each():
    world.queue_free()

func test_fake():
    print(world.teams.human_team.units.get_children())
    print(world.teams.ai_team.units.get_children())
    assert_eq(true, true, "a ridiculous test")
