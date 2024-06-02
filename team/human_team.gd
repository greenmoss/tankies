extends 'team.gd'
class_name HumanTeam

@onready var cursor:Cursor = $cursor

var skipped_next_units = {}


func _ready():
    super._ready()
    cursor.set_controller_team(name)


# find an active unit with moves, nearest to the given position
func _on_cursor_want_nearest_unit(position:Vector2):
    var unit:Unit = units.get_cardinal_closest_active(position)
    if unit != null:
        unit.select_me()
        cursor.state.mark_unit(unit)


# find an active unit with moves, nearest to a unit
# try not to select the same unit
# try not to select a previously-selected unit
# if all are done, don't select anything
# if none match, select the previous unit
func _on_cursor_want_next_unit(previous_unit:Unit):
    var next_unit = null
    var nearby = units.get_all_by_cardinal_distance(previous_unit.position)
    var distances = nearby.keys()
    distances.sort()

    var nearby_units_count = 0
    for distance in distances:
        nearby_units_count += nearby[distance].size()
    if skipped_next_units.size() >= nearby_units_count:
        skipped_next_units = {previous_unit: 1}

    for distance in distances:

        for unit in nearby[distance]:
            if unit in skipped_next_units.keys():
                continue

            if unit == previous_unit:
                skipped_next_units[unit] = 1
                continue

            if not is_instance_valid(unit):
                skipped_next_units[unit] = 1
                continue

            if unit.is_queued_for_deletion():
                skipped_next_units[unit] = 1
                continue

            if unit.state.is_done():
                skipped_next_units[unit] = 1
                continue

            # selecting, since it is not the previous, nor in skipped
            skipped_next_units[unit] = 1
            next_unit = unit
            break

        if next_unit != null:
            break

    # didn't find any, so clear the skipped list, and re-select the previous
    if next_unit == null:
        skipped_next_units = {previous_unit: 1}
        # all units sleeping, and it's end of turn
        if previous_unit.state.is_done():
            return
        previous_unit.select_me()
        cursor.state.mark_unit(previous_unit)
        return

    # found new unselected, so select it
    skipped_next_units[next_unit] = 1
    next_unit.select_me()
    cursor.state.mark_unit(next_unit)
