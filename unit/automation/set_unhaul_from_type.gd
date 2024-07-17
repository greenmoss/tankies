extends ActionLeaf


func tick(_actor, blackboard):
    blackboard.set_value("unhaul_to_region_closest_path", null)
    blackboard.set_value("unhaul_to_region_closest_region", null)

    var city_path = blackboard.get_value("unhaul_to_city_path")
    var city_region = blackboard.get_value("unhaul_to_city_region")
    var city_valid = (city_region != null) and (city_path != null)

    var unit_path = blackboard.get_value("unhaul_to_unit_path")
    var unit_region = blackboard.get_value("unhaul_to_unit_region")
    var unit_valid = (unit_region != null) and (unit_path != null)

    if city_valid:
        if unit_valid:
            var unit_path_shorter = (unit_path.size() < city_path.size())

            if unit_path_shorter:
                blackboard.set_value("unhaul_to_region_closest_path", unit_path)
                blackboard.set_value("unhaul_to_region_closest_region", unit_region)
                #print("unit: unit and city valid, unit path shorter")
                return SUCCESS

            else: # city path shorter
                blackboard.set_value("unhaul_to_region_closest_path", city_path)
                blackboard.set_value("unhaul_to_region_closest_region", city_region)
                #print("city: unit and city valid, city path shorter")
                return SUCCESS

        else: # unit invalid
            blackboard.set_value("unhaul_to_region_closest_path", city_path)
            blackboard.set_value("unhaul_to_region_closest_region", city_region)
            #print("city: city valid, unit invalid")
            return SUCCESS

    else: # city invalid

        if unit_valid:
            blackboard.set_value("unhaul_to_region_closest_path", unit_path)
            blackboard.set_value("unhaul_to_region_closest_region", unit_region)
            #print("unit: unit valid, city invalid")
            return SUCCESS

        else: # unit invalid
            #print("none: unit invalid, city invalid")
            return FAILURE
