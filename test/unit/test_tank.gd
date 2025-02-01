extends GutTest

var tank

func before_each():
    var tank_scene = preload("res://unit/types/tank/tank.tscn")
    tank = tank_scene.instantiate()
    get_tree().current_scene.add_child(tank)

func after_each():
    tank.queue_free()

func test_can_capture():
    assert_eq(tank.can_capture, true, "tanks can capture cities")
