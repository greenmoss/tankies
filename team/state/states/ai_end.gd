extends "begin.gd"


func activate_units():
    '''
    awaken all units in haul state that are not currently hauled
    '''

    var units = owner.units.get_all_valid()

    for unit in units:
        print("checking unit: ",unit)

        if not unit.state.is_named('haul'): continue

        if unit.is_hauled(): continue

        print("unhauling unit on land")

        unit.state.unhaul()
