extends "../common/unit.gd"

var marked:City

@onready var background = $detail/background
@onready var build = $detail/build
@onready var detail = $detail
@onready var icon = $detail/icon
@onready var units1 = $detail/units1
@onready var units2 = $detail/units2
@onready var units3 = $detail/units3
@onready var unit_slots = [
    $detail/unit0,
    $detail/units1/unit1,
    $detail/units1/unit2,
    $detail/units1/unit3,
    $detail/units2/unit1,
    $detail/units2/unit2,
    $detail/units2/unit3,
    $detail/units2/unit4,
    $detail/units2/unit5,
    $detail/units2/unit6,
    $detail/units3/unit1,
    $detail/units3/unit2,
    $detail/units3/unit3,
    $detail/units3/unit4,
    $detail/units3/unit5,
    $detail/units3/unit6,
    # if there are more units than this, we do not display them
    ]

var tween_speed = 7.5
var alpha_tween:Tween
var position_tween:Tween

@onready var default_size_y = $detail/background.size.y

var units:Array[Unit]


func _on_unit_pressed(slot_index:int):
    activate_unit(slot_index)


func _on_selector_pressed():
    owner.state.build.marked = marked
    #owner.state.build.build.progress_animation_time = build.progress_animation_time
    emit_signal("next_state", "build")
    return


func activate_unit(unit_number:int):
    var unit_count = units.size()
    # ignore buttons without an attached unit
    if unit_number >= unit_count:
        return
    owner.state.mark_unit(units[unit_number])


func enter():
    if marked == null:
        emit_signal("next_state", "none")
        return

    icon.modulate = marked.icon.modulate
    build.set_from_city(marked)

    units = []
    for unit in marked.get_units():
        if unit == null: continue
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        units.append(unit)
    units.reverse()

    for slot_index in unit_slots.size():
        if slot_index >= units.size():
            break
        unit_slots[slot_index].texture_normal = units[slot_index].display.icon.texture
        unit_slots[slot_index].modulate = units[slot_index].display.icon.modulate
        unit_slots[slot_index].flip_h = units[slot_index].display.icon.flip_h
        unit_slots[slot_index].pressed.connect(_on_unit_pressed.bind(slot_index))

    # row 1 of displayed units, plus one unit displayed over the city
    if units.size() > (units1.get_children().size() + 1):
        units2.visible = true
        units3.visible = true
        detail.size.y += default_size_y / 2
        background.size.y += default_size_y / 2

    owner.position = Vector2(marked.position.x - Global.half_tile_size, marked.position.y - Global.half_tile_size)

    var right_extent = owner.position.x + detail.size.x
    var bottom_extent = owner.position.y + detail.size.y
    var updated_x = detail.position.x
    var updated_y = detail.position.y

    if right_extent > get_viewport().size.x:
        updated_x = detail.position.x - detail.size.x + Global.tile_size

    if bottom_extent > get_viewport().size.y:
        updated_y = detail.position.y - detail.size.y + Global.tile_size

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
    detail.size.y = default_size_y
    background.size.y = default_size_y
    build.set_idle()
    units2.visible = false
    units3.visible = false

    for slot in unit_slots:
        slot.texture_normal = null
    marked = null

    # disconnect any unit button signals
    for slot_index in unit_slots.size():
        if not unit_slots[slot_index].pressed.is_connected(_on_unit_pressed): continue
        unit_slots[slot_index].pressed.disconnect(_on_unit_pressed)


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
