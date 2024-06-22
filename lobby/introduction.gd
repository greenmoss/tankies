extends CanvasLayer

@export var selected_icon:Texture2D
@export var deselected_icon:Texture2D

var bg_tween : Tween
var music_tween : Tween
var fade_out_time = 0.25
var fade_in_time = 1.0
var scenario_information = []

signal faded_out


func _ready():
    SignalBus.team_won.connect(_team_won)


func _on_choose_button_pressed():
    $Background/start_button.hide()
    $Background/or_text.hide()
    $Background/choose_button.hide()
    $Background/scenario_chooser.show()


func _on_scenario_chooser_item_selected(index):
    $Background/start_button.show()
    $Background/or_text.show()
    $Background/choose_button.show()
    $Background/scenario_chooser.hide()
    set_current_scenario(index)


func _on_start_button_pressed():
    #TODO: figure out how to have the button press emit a global signal
    SignalBus.introduction_pressed_start.emit()
    fade_out()


func _team_won(winning_team, turn_number, teams_summary, elapsed_seconds):
    var game_over_template = '''
    Game over!

    The winner is {winner}

    Turns: {turn_count}
    Time Spent (HH:MM:SS): {elapsed}

    Teams:
    {teams_summary}
    '''
    var game_over_message = game_over_template.format(
        {'winner': winning_team, 'turn_count': turn_number, 'elapsed': Time.get_time_string_from_unix_time(elapsed_seconds), 'teams_summary': "\n".join(teams_summary)}
    )
    fade_in(game_over_message)


func fade_in(message):
    $Background/start_button.hide()
    $Background/or_text.hide()
    set_message(message)
    # start with transparent background
    $Background.modulate.a = 0.0

    show()

    # fade in to opaque background
    bg_tween = create_tween()
    bg_tween.tween_property($Background, "modulate:a", 1.0, fade_out_time)
    await bg_tween.finished

    $Music.volume_db = 0
    $Music.play()


func fade_out():
    # if music is playing start fading it to silent
    if $Music.playing:
        music_tween = create_tween()
        music_tween.tween_property($Music, "volume_db", -80, fade_out_time)

    # then fade intro to transparent
    bg_tween = create_tween()
    bg_tween.tween_property($Background, "modulate:a", 0.0, fade_out_time)
    await bg_tween.finished

    hide()
    $Music.stop()

    faded_out.emit()


func set_current_scenario(scenario_number):
    if scenario_number >= scenario_information.size():
        push_warning("Testing? scenario number ",scenario_number," is missing from scenario information; ignoring")
        return

    set_message(scenario_information[scenario_number]['objective'])
    for scenario_id in scenario_information.size():
        if scenario_number == scenario_id:
            $Background/scenario_chooser.set_item_icon(scenario_id, selected_icon)
            continue
        $Background/scenario_chooser.set_item_icon(scenario_id, deselected_icon)
    SignalBus.introduction_selected_scenario.emit(scenario_information[scenario_number]['file_name'])


func set_message(message):
    $Background/objective.text = message


func set_scenarios(scenarios):
    $Background/scenario_chooser.clear()
    for scenario_id in scenarios.size():
        var information: Dictionary = scenarios[scenario_id].get_information()
        $Background/scenario_chooser.add_item(information['name'])
        $Background/scenario_chooser.set_item_tooltip(scenario_id, information['objective'])
        scenario_information.append(information)
    set_current_scenario(0)
