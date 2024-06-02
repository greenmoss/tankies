extends "../common/unit.gd"

var marked:City

@onready var build_progress = $detail/build_progress
@onready var build_turns_remaining = $detail/build_turns_margin/build_turns_remaining
@onready var detail = $detail
@onready var icon = $detail/icon
@onready var lists = $detail/lists

var build_progress_max:float
var build_progress_min:float
var build_progress_animation_time = 0.0
var build_progress_animation_duration = 0.75
var build_progress_animation_pause = 0.5


func enter():
    if marked == null:
        emit_signal("next_state", "none")
        return

    icon.modulate = marked.icon.modulate
    build_progress.modulate = marked.icon.modulate

    build_progress_min = (float(marked.build_duration) - float(marked.build_remaining)) / float(marked.build_duration) * 100.0
    build_progress_max = (float(marked.build_duration) - float(marked.build_remaining) + 1.0) / float(marked.build_duration) * 100.0
    build_turns_remaining.text = str(marked.build_remaining)

    owner.position = Vector2(marked.position.x - Global.half_tile_size, marked.position.y - Global.half_tile_size)

    var right_extent = owner.position.x + lists.size.x
    if right_extent > get_viewport().size.x:
        detail.position.x -= lists.size.x - Global.tile_size

    var bottom_extent = owner.position.y + lists.size.y
    if bottom_extent > get_viewport().size.y:
        detail.position.y -= lists.size.y - Global.tile_size

    detail.visible = true


func exit():
    detail.visible = false
    detail.position = Vector2.ZERO
    build_progress_animation_time = 0.0


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


func update(delta):
    build_progress_animation_time += delta
    if build_progress_animation_time > (build_progress_animation_duration + build_progress_animation_pause):
       build_progress_animation_time = 0.0

    if build_progress_animation_time <= build_progress_animation_duration:
        build_progress.value = lerp(build_progress_min, build_progress_max, build_progress_animation_time / build_progress_animation_duration)
    else:
        build_progress.value = build_progress_max
