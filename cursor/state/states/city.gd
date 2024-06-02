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

var tween_speed = 7.5
var alpha_tween:Tween
var position_tween:Tween

var default_tooltip_text = "Turns until built: "


func enter():
    if marked == null:
        emit_signal("next_state", "none")
        return

    icon.modulate = marked.icon.modulate
    build_progress.modulate = marked.icon.modulate

    build_progress_min = (float(marked.build_duration) - float(marked.build_remaining)) / float(marked.build_duration) * 100.0
    build_progress_max = (float(marked.build_duration) - float(marked.build_remaining) + 1.0) / float(marked.build_duration) * 100.0
    build_turns_remaining.text = str(marked.build_remaining)
    build_progress.tooltip_text = default_tooltip_text+str(marked.build_remaining)
    build_turns_remaining.tooltip_text = default_tooltip_text+str(marked.build_remaining)

    owner.position = Vector2(marked.position.x - Global.half_tile_size, marked.position.y - Global.half_tile_size)

    var right_extent = owner.position.x + lists.size.x
    var bottom_extent = owner.position.y + lists.size.y
    var updated_x = detail.position.x
    var updated_y = detail.position.y

    if right_extent > get_viewport().size.x:
        updated_x = detail.position.x - lists.size.x + Global.tile_size

    if bottom_extent > get_viewport().size.y:
        updated_y = detail.position.y - lists.size.y + Global.tile_size

    detail.modulate.a = 0.0
    detail.visible = true

    # fade in the panel
    alpha_tween = create_tween()
    alpha_tween.tween_property(detail, "modulate:a",
        1.0,
        1.0/tween_speed
        ).set_trans(Tween.TRANS_SINE)

    # if panel would be offscreen, slide it onscreen
    if (updated_x != owner.position.x) or (updated_y != owner.position.y):
        position_tween = create_tween()
        position_tween.tween_property(detail, "position",
            Vector2(updated_x, updated_y),
            1.0/tween_speed
            ).set_trans(Tween.TRANS_SINE)


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
