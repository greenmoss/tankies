extends Node2D
class_name UnitStack

@onready var unit1 = $unit1
@onready var unit2 = $unit2
@onready var unit3 = $unit3
@onready var unit4 = $unit4
@onready var unit_count = $unit_count

var units:Array[Unit]


func _ready():
    if units.size() < 2:
        # probably running scene by itself
        push_warning("stack has ",units.size()," unit/s; not configuring stack")
        return
    set_info()


func promote_unit(unit:Unit):
    var new_units:Array[Unit] = [unit]
    for previous_unit in units:
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        if unit == previous_unit: continue
        new_units.append(previous_unit)
    units = new_units
    set_info()


func set_info():
    var unit_color:Color = Global.team_colors[units[0].get_team()]
    unit1.modulate = unit_color
    unit2.modulate = unit_color
    unit3.modulate = unit_color
    unit4.modulate = unit_color
    unit1.texture = units[0].get_texture()
    unit2.texture = units[1].get_texture()

    var units_size = units.size()
    unit_count.text = str(units_size)

    if units_size == 2:
        unit3.visible = false
        unit4.visible = false
        return

    if units_size == 3:
        unit3.texture = units[2].get_texture()
        unit3.visible = true
        unit4.visible = false
        return

    if units_size >= 4:
        unit3.texture = units[2].get_texture()
        unit3.visible = true
        unit4.texture = units[3].get_texture()
        unit4.visible = true
        return


func set_units(stack_units:Array[Unit]):
    units = stack_units
    position = Vector2i(int(units[0].position.x), int(units[0].position.y))
