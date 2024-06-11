extends "../common/unit.gd"

var marked:City

@onready var background = $detail/background
@onready var detail = $detail
@onready var default_size_y = $detail.size.y

#var build_options:Array[Node2D] = []
#var build:Node2D = null

var tween_speed = 7.5
var alpha_tween:Tween
var position_tween:Tween

var build_scene:PackedScene = preload("res://cursor/build.tscn")


func enter():
    if marked == null:
        emit_signal("next_state", "none")
        return

    var build:Node2D = build_scene.instantiate()
    detail.add_child(build)
    build.set_from_city(marked)
    #build.progress_animation_time = ???.build.progress_animation_time

    #print("cursor states build unit type object ",UnitTypeUtilities.types)
    #for iterator in [0]:
    for unit_type_name in UnitTypeUtilities.get_types():
        if unit_type_name == marked.build_type: continue
        build = build_scene.instantiate()
        detail.add_child(build)
        build.set_from_type(marked.icon.modulate, unit_type_name)
        build.position.y = background.size.y
        # expand background to frame additional unit build line
        detail.size.y += default_size_y
        background.size.y += default_size_y

    detail.visible = true


func exit():
    detail.visible = false
    detail.position = Vector2.ZERO
    detail.size.y = default_size_y
    background.size.y = default_size_y
    #build.exit()
    for child in background.get_children():
        child.queue_free()
    marked = null


func handle_input(event):
    if event.is_action_pressed("click"):
        var clicked_city:City = get_first_city_under_mouse()
        if clicked_city != null:
            owner.state.mark_city(clicked_city)
            return

        var clicked_unit:Unit = get_first_unit_under_mouse()
        if clicked_unit != null:
            owner.state.mark_unit(clicked_unit)
            return

        if clicked_city == null:
            emit_signal("next_state", "none")
            return

    if event.is_action_pressed("escape"):
        emit_signal("next_state", "none")
        return

    if event.is_action_pressed('next'):
        owner.state.find_unit.nearby = null
        emit_signal("next_state", "find_unit")
        return
