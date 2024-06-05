extends "../common/unit.gd"

var marked:City

@onready var background = $detail/background
@onready var build = $detail/build
@onready var detail = $detail

var tween_speed = 7.5
var alpha_tween:Tween
var position_tween:Tween


func enter():
    if marked == null:
        emit_signal("next_state", "none")
        return

    build.set_from_city(marked)

    detail.visible = true


func exit():
    detail.visible = false
    detail.position = Vector2.ZERO
    build.exit()
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
